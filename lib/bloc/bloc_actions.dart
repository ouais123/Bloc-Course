import 'package:bloc_course/bloc/person.dart';
import 'package:flutter/foundation.dart';

const String person1Url = "http://127.0.0.1:5500/api/person1.json";
const String person2Url = "http://127.0.0.1:5500/api/person2.json";

typedef PersonLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final String url;
  final PersonLoader loader;

  const LoadPersonAction({
    required this.url,
    required this.loader,
  });
}
