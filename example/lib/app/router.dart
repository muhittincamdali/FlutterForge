import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forge_example/features/home/home_page.dart';
import 'package:forge_example/features/todos/presentation/todos_page.dart';

/// The screen the app opens on. `--dart-define=INITIAL_ROUTE=/todos` starts
/// on another one, which helps while working on a single screen.
const String initialRoute = String.fromEnvironment(
  'INITIAL_ROUTE',
  defaultValue: '/',
);

/// The routes of the app. `forge feature` adds new routes above the marker
/// line.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/todos', builder: (context, state) => const TodosPage()),
      // forge:routes
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
