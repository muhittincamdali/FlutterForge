import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forge_example/app/destinations.dart';

/// Lists every destination of the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forge example')),
      body: ListView.separated(
        itemCount: destinations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return ListTile(
            title: Text(destination.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(destination.path),
          );
        },
      ),
    );
  }
}
