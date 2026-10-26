import 'package:forge_example/features/todos/domain/todo.dart';

/// Where the Todos feature reads its data from.
///
/// The presentation layer only knows this interface, so tests and previews
/// can pass a fake.
abstract interface class TodosRepository {
  Future<List<Todo>> fetchAll();
}
