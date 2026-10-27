import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The API the app talks to. Change it at build time with
/// `--dart-define=API_BASE_URL=https://api.example.com`.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://jsonplaceholder.typicode.com',
);

/// The one HTTP client of the app, shared by every repository.
final forgeClientProvider = Provider<ForgeClient>((ref) {
  final client = ForgeClient(baseUrl: apiBaseUrl, cache: MemoryResponseCache());
  ref.onDispose(client.close);
  return client;
});
