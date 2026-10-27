/// One item of the Todos feature.
///
/// Add the fields your API returns, then read them in
/// `data/todo_json.dart`.
final class Todo {
  const Todo({required this.id, required this.title});

  final int id;
  final String title;

  @override
  bool operator ==(Object other) =>
      other is Todo && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);

  @override
  String toString() => 'Todo($id, $title)';
}
