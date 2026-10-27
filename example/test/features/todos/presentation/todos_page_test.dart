import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_example/features/todos/data/http_todos_repository.dart';
import 'package:forge_example/features/todos/domain/todo.dart';
import 'package:forge_example/features/todos/domain/todos_repository.dart';
import 'package:forge_example/features/todos/presentation/todos_page.dart';

/// Answers with the next result in [results] on each call.
final class _FakeTodosRepository implements TodosRepository {
  _FakeTodosRepository(this.results);

  final List<Object> results;
  int calls = 0;

  @override
  Future<List<Todo>> fetchAll() async {
    final result = results[calls++];
    if (result is List<Todo>) return result;
    throw result;
  }
}

Future<void> _show(WidgetTester tester, TodosRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [todosRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: TodosPage()),
    ),
  );
}

void main() {
  final offline = ConnectionException(
    ForgeRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
  );

  testWidgets('shows the items', (tester) async {
    await _show(
      tester,
      _FakeTodosRepository([
        const [Todo(id: 1, title: 'First'), Todo(id: 2, title: 'Second')],
      ]),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('says so when the list is empty', (tester) async {
    await _show(tester, _FakeTodosRepository([const <Todo>[]]));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet.'), findsOneWidget);
  });

  testWidgets('explains an error and loads again on Try again', (tester) async {
    final repository = _FakeTodosRepository([
      offline,
      const [Todo(id: 3, title: 'Back online')],
    ]);
    await _show(tester, repository);
    await tester.pumpAndSettle();
    expect(find.textContaining('offline'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Back online'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
