import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc Course',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => PersonBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}

enum PersonUrl {
  person1,
  person2,
}

extension PersonUrlExtension on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return "http://127.0.0.1:5500/api/person1.json";
      case PersonUrl.person2:
        return "http://127.0.0.1:5500/api/person2.json";
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? '',
        age = map['age'] ?? 0;
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((res) => res.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromMap(e)));

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final PersonUrl personUrl;
  const LoadPersonAction({required this.personUrl});
}

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isCashed;

  const FetchResult({
    required this.persons,
    required this.isCashed,
  });
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> cashe = {};

  PersonBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final url = event.personUrl;
      if (cashe.containsKey(url)) {
        final persons = cashe[url]!;
        final fetchResult = FetchResult(
          persons: persons,
          isCashed: true,
        );
        emit(fetchResult);
      } else {
        final persons = await getPersons(url.urlString);
        cashe[url] = persons;
        final fetchResult = FetchResult(
          persons: persons,
          isCashed: false,
        );
        emit(fetchResult);
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bloc Course"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.read<PersonBloc>().add(
                        const LoadPersonAction(
                          personUrl: PersonUrl.person1,
                        ),
                      ),
                  child: const Text("Load Persons 1#"),
                ),
                ElevatedButton(
                  onPressed: () => context.read<PersonBloc>().add(
                        const LoadPersonAction(
                          personUrl: PersonUrl.person2,
                        ),
                      ),
                  child: const Text("Load Persons 2#"),
                ),
              ],
            ),
            BlocBuilder<PersonBloc, FetchResult?>(
              buildWhen: (previous, current) {
                return previous?.persons != current?.persons;
              },
              builder: (_, fetchResult) {
                final persons = fetchResult?.persons;
                if (persons == null) return const SizedBox.shrink();

                return Expanded(
                  child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (_, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                        subtitle: Text(person.age.toString()),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
