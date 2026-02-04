import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

void main() {
  runApp(const FlutterForgeExampleApp());
}

/// Example app demonstrating FlutterForge features.
class FlutterForgeExampleApp extends StatelessWidget {
  const FlutterForgeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterForge Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen showcasing FlutterForge components.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterForge Example'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Getting Started',
            description: 'FlutterForge provides production-ready templates and utilities.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Clean Architecture',
            description: 'Built with Riverpod, GoRouter, and clean architecture principles.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'CLI Tools',
            description: 'Generate features, screens, and repositories with the CLI.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String description}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
