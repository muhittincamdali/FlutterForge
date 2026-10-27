import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_example/features/todos/data/http_todos_repository.dart';
import 'package:forge_example/features/todos/domain/todo.dart';

/// Loads the Todos list and reloads it on request.
class TodosController extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() => ref.watch(todosRepositoryProvider).fetchAll();

  /// Loads the list again, keeping the current one on screen meanwhile.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final todosControllerProvider =
    AsyncNotifierProvider<TodosController, List<Todo>>(TodosController.new);
