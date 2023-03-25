import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

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
      home: const MyHomePage(),
    );
  }
}

const names = [
  "anas",
  "owais",
  "ahmad",
];

extension RandomIterable<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

  void getRandomName() => emit(names.getRandomElement());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final NamesCubit namesCubit;

  @override
  void initState() {
    namesCubit = NamesCubit();
    super.initState();
  }

  @override
  void dispose() {
    namesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bloc Course"),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: namesCubit.stream,
              builder: (_, snabshot) {
                switch (snabshot.connectionState) {
                  case ConnectionState.none:
                    return const SizedBox.shrink();
                  case ConnectionState.waiting:
                    return const SizedBox.shrink();
                  case ConnectionState.active:
                    return Text(snabshot.data ?? '');
                  case ConnectionState.done:
                    return const SizedBox.shrink();
                }
              },
            ),
            ElevatedButton(
              onPressed: () => namesCubit.getRandomName(),
              child: const Text("Pick Random Names"),
            ),
          ],
        ),
      ),
    );
  }
}
