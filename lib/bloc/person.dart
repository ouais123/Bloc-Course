import 'package:flutter/foundation.dart' show immutable;

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
