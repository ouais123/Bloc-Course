import 'dart:convert';
import 'dart:io';

import 'package:bloc_course/bloc/bloc_actions.dart';
import 'package:bloc_course/bloc/person.dart';
import 'package:bloc_course/bloc/person_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}


Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((res) => res.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromMap(e)));

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
                          url: person1Url,
                          loader: getPersons,
                        ),
                      ),
                  child: const Text("Load Persons 1#"),
                ),
                ElevatedButton(
                  onPressed: () => context.read<PersonBloc>().add(
                        const LoadPersonAction(
                          url: person2Url,
                          loader: getPersons,
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
