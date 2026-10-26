import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_example/core/error_message.dart';
import 'package:forge_example/core/widgets/error_view.dart';
import 'package:forge_example/features/todos/presentation/todos_controller.dart';

/// Shows the Todos list.
class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosControllerProvider);
    final controller = ref.read(todosControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: switch (todos) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: controller.reload,
          child: value.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Nothing here yet.'),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(child: Text('${value[index].id}')),
                    title: Text(value[index].title),
                  ),
                ),
        ),
        AsyncValue(:final error?) => ErrorView(
          message: errorMessage(error),
          onRetry: controller.reload,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
