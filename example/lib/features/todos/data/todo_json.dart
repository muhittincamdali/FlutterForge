import 'package:forge_example/features/todos/domain/todo.dart';

/// Reads one [Todo] from its JSON object.
///
/// Throws a [FormatException] when a field is missing or has another type;
/// `ForgeClient` turns it into a `DecodingException`.
Todo todoFromJson(Object? json) {
  if (json case {'id': final int id, 'title': final String title}) {
    return Todo(id: id, title: title);
  }
  throw const FormatException('Expected an object with an int id and a title.');
}

/// Reads a JSON array of [Todo] objects.
List<Todo> todoListFromJson(Object? json) => switch (json) {
  final List<Object?> items => [for (final item in items) todoFromJson(item)],
  _ => throw const FormatException('Expected a JSON array.'),
};
