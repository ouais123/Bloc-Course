import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:bloc_course/bloc/bloc_actions.dart';
import 'package:bloc_course/bloc/person.dart';
import 'package:bloc_course/bloc/person_bloc.dart';

const mockedPersons1 = [
  Person(
    name: "Foo 1",
    age: 23,
  ),
  Person(
    name: "Bar 1",
    age: 37,
  ),
  Person(
    name: "Baz 1",
    age: 46,
  ),
];

const mockedPersons2 = [
  Person(
    name: "Foo 2",
    age: 23,
  ),
  Person(
    name: "Bar 2",
    age: 37,
  ),
  Person(
    name: "Baz 2",
    age: 46,
  ),
];

Future<Iterable<Person>> getPersons1(String _) => Future.value(mockedPersons1);
Future<Iterable<Person>> getPersons2(String _) => Future.value(mockedPersons2);

void main() {
  group("Testing Person Bloc", () {
    late PersonBloc personBloc;

    setUp(() {
      personBloc = PersonBloc();
    });

    blocTest<PersonBloc, FetchResult?>(
      "Test initial state",
      build: () => personBloc,
      verify: (personBloc) => expect(personBloc.state, null),
    );

    blocTest<PersonBloc, FetchResult?>(
      "Test Mock retrieving person from first iterable",
      build: () => personBloc,
      act: (personBloc) {
        personBloc.add(
          const LoadPersonAction(
            url: "dummy_url_1",
            loader: getPersons1,
          ),
        );

        personBloc.add(
          const LoadPersonAction(
            url: "dummy_url_1",
            loader: getPersons1,
          ),
        );
      },
      expect: () => const [
        FetchResult(
          persons: mockedPersons1,
          isCashed: false,
        ),
        FetchResult(
          persons: mockedPersons1,
          isCashed: true,
        ),
      ],
    );

    blocTest<PersonBloc, FetchResult?>(
      "Test Mock retrieving persons from second iterable",
      build: () => personBloc,
      act: (personBloc) {
        personBloc.add(
          const LoadPersonAction(
            url: "dummy_url_2",
            loader: getPersons2,
          ),
        );

        personBloc.add(
          const LoadPersonAction(
            url: "dummy_url_2",
            loader: getPersons2,
          ),
        );
      },
      expect: () => const [
        FetchResult(
          persons: mockedPersons2,
          isCashed: false,
        ),
        FetchResult(
          persons: mockedPersons2,
          isCashed: true,
        ),
      ],
    );
  });
}
