import 'package:bloc_course/bloc/bloc_actions.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:bloc/bloc.dart';
import 'package:bloc_course/bloc/person.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  // list 1 [a b c]
// list 2 [b c d]
//intersection [b c] == length
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isCashed;

  const FetchResult({
    required this.persons,
    required this.isCashed,
  });

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isCashed == other.isCashed;

  @override
  int get hashCode => Object.hash(persons, isCashed);
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> cashe = {};

  PersonBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final url = event.url;
      if (cashe.containsKey(url)) {
        final persons = cashe[url]!;
        final fetchResult = FetchResult(
          persons: persons,
          isCashed: true,
        );
        emit(fetchResult);
      } else {
        final loader = event.loader;
        final persons = await loader(url);
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
