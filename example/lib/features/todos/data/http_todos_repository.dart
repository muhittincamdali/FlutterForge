import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_example/core/network.dart';
import 'package:forge_example/features/todos/data/todo_json.dart';
import 'package:forge_example/features/todos/domain/todo.dart';
import 'package:forge_example/features/todos/domain/todos_repository.dart';

/// Reads Todos from `/todos` on the app's API.
final class HttpTodosRepository implements TodosRepository {
  HttpTodosRepository(this._client);

  final ForgeClient _client;

  @override
  Future<List<Todo>> fetchAll() => _client.getJson(
    '/todos',
    query: {'_limit': 20},
    decode: todoListFromJson,
    // Shows the last list that was loaded when the device is offline.
    cachePolicy: CachePolicy.networkFirst,
  );
}

/// The repository the app uses. Tests replace it with
/// `todosRepositoryProvider.overrideWithValue(...)`.
final todosRepositoryProvider = Provider<TodosRepository>(
  (ref) => HttpTodosRepository(ref.watch(forgeClientProvider)),
);
