import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_example/app/app.dart';

void main() {
  // ForgeClient already retries failed requests, so Riverpod's own automatic
  // retry of failed providers is turned off.
  runApp(ProviderScope(retry: (retryCount, error) => null, child: const App()));
}
