import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_example/app/app.dart';
import 'package:forge_example/app/destinations.dart';
import 'package:forge_example/features/todos/data/http_todos_repository.dart';
import 'package:forge_example/features/todos/domain/todo.dart';
import 'package:forge_example/features/todos/domain/todos_repository.dart';

final class _StaticTodos implements TodosRepository {
  @override
  Future<List<Todo>> fetchAll() async => const [Todo(id: 1, title: 'Hello')];
}

void main() {
  testWidgets('the home page lists every destination and opens one', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todosRepositoryProvider.overrideWithValue(_StaticTodos())],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    for (final destination in destinations) {
      expect(find.text(destination.title), findsOneWidget);
    }

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
