import '../template.dart';

/// The files of a new app, apart from its features.
///
/// Keys: `project`, `title`, `description`, `forgeDependency`.
const List<TemplateFile> appTemplates = [
  TemplateFile('pubspec.yaml', r'''
name: {{project}}
description: "{{description}}"
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.12.0
  flutter: ">=3.44.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_forge:
{{forgeDependency}}
  flutter_riverpod: ^3.4.3
  go_router: ^18.1.1
  http: ^1.6.0

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
'''),
  TemplateFile('analysis_options.yaml', r'''
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
    - linux/**
    - macos/**
    - windows/**
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - always_use_package_imports
    - prefer_final_locals
    - prefer_single_quotes
    - unawaited_futures
'''),
  TemplateFile('README.md', r'''
# {{title}}

{{description}}

Created with [FlutterForge](https://github.com/muhittincamdali/FlutterForge).

## Run it

```sh
flutter run
```

The app reads its API from `https://jsonplaceholder.typicode.com` until you
point it at your own server:

```sh
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

`--dart-define=INITIAL_ROUTE=/todos` opens the app on another screen.

## Check it

```sh
flutter analyze
flutter test
```

`.github/workflows/ci.yml` runs the same checks, and `dart format`, on GitHub
for every push to `main` and every pull request.

## How the code is organised

```text
lib/
  main.dart                   starts the app inside a ProviderScope
  app/                        MaterialApp, theme, routes, home destinations
  core/                       the shared ForgeClient and error messages
  features/<name>/
    domain/                   entities and the repository interface
    data/                     JSON parsing and the HTTP repository
    presentation/             the Riverpod controller and the page
test/                         the same folders, one test file per layer
```

Each feature depends on `core/` and never on another feature. The page talks
to its controller, the controller to the repository interface, and only the
data layer knows about HTTP, so tests replace the repository with a fake.

## Add a feature

```sh
forge feature orders
```

This writes `lib/features/orders/` and its tests, adds the `/orders` route and
puts it on the home screen.
'''),
  TemplateFile('.github/workflows/ci.yml', r'''
# Checks every push to main and every pull request: formatting, analysis
# and tests. The actions are pinned to commits; Dependabot can update them.
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  test:
    name: Format, analyze and test
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false

      - uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2.23.0
        with:
          channel: stable
          cache: true

      - name: Dependencies
        run: flutter pub get

      - name: Format
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test
'''),
  TemplateFile('.github/dependabot.yml', r'''
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly
    groups:
      github-actions:
        patterns: ["*"]
  - package-ecosystem: pub
    directory: /
    schedule:
      interval: monthly
    groups:
      pub:
        patterns: ["*"]
'''),
  TemplateFile('lib/main.dart', r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project}}/app/app.dart';

void main() {
  // ForgeClient already retries failed requests, so Riverpod's own automatic
  // retry of failed providers is turned off.
  runApp(ProviderScope(retry: (retryCount, error) => null, child: const App()));
}
'''),
  TemplateFile('lib/app/app.dart', r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project}}/app/router.dart';
import 'package:{{project}}/app/theme.dart';

/// The root widget.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '{{title}}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
'''),
  TemplateFile('lib/app/theme.dart', r'''
import 'package:flutter/material.dart';

/// The light and dark themes, both derived from one seed colour.
abstract final class AppTheme {
  static const Color seed = Color(0xFF0A84FF);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );
}
'''),
  TemplateFile('lib/app/destinations.dart', r'''
/// A screen listed on the home page.
class Destination {
  const Destination({required this.title, required this.path});

  final String title;
  final String path;
}

/// The screens listed on the home page. `forge feature` adds new features
/// above the marker line.
const List<Destination> destinations = [
  Destination(title: 'Todos', path: '/todos'),
  // forge:destinations
];
'''),
  TemplateFile('lib/app/router.dart', r'''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project}}/features/home/home_page.dart';
import 'package:{{project}}/features/todos/presentation/todos_page.dart';

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
'''),
  TemplateFile('lib/features/home/home_page.dart', r'''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project}}/app/destinations.dart';

/// Lists every destination of the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{title}}')),
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
'''),
  TemplateFile('lib/core/network.dart', r'''
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
'''),
  TemplateFile('lib/core/error_message.dart', r'''
import 'package:flutter_forge/flutter_forge.dart';

/// A sentence for the user that explains [error].
String errorMessage(Object error) => switch (error) {
  ConnectionException() =>
    'You appear to be offline. Check your connection and try again.',
  RequestTimeoutException() => 'The server took too long to answer.',
  RequestCancelledException() => 'The request was cancelled.',
  HttpStatusException(statusCode: 401 || 403) =>
    'You are not allowed to see this. Sign in and try again.',
  HttpStatusException(statusCode: 404) => 'This could not be found.',
  HttpStatusException(:final statusCode) when statusCode >= 500 =>
    'The server had a problem. Try again later.',
  HttpStatusException(:final statusCode) =>
    'The server answered with status $statusCode.',
  DecodingException() => 'The server sent data this app cannot read.',
  ResponseTooLargeException() => 'The answer from the server was too large.',
  RedirectException() => 'The server sent the request to an unsafe address.',
  _ => 'Something went wrong. Try again.',
};
'''),
  TemplateFile('lib/core/widgets/error_view.dart', r'''
import 'package:flutter/material.dart';

/// A message with a button that tries again.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
'''),
  TemplateFile('test/app_test.dart', r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project}}/app/app.dart';
import 'package:{{project}}/app/destinations.dart';
import 'package:{{project}}/features/todos/data/http_todos_repository.dart';
import 'package:{{project}}/features/todos/domain/todo.dart';
import 'package:{{project}}/features/todos/domain/todos_repository.dart';

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
'''),
  TemplateFile('test/core/error_message_test.dart', r'''
import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project}}/core/error_message.dart';

void main() {
  final request = ForgeRequest(
    method: 'GET',
    uri: Uri.parse('https://api.example.com/items'),
  );

  ForgeResponse response(int status) => ForgeResponse(
    statusCode: status,
    request: request,
    bodyBytes: Uint8List(0),
  );

  test('explains each kind of failure', () {
    expect(errorMessage(ConnectionException(request)), contains('offline'));
    expect(
      errorMessage(RequestTimeoutException(request, Duration.zero)),
      contains('too long'),
    );
    expect(
      errorMessage(HttpStatusException(response(401))),
      contains('Sign in'),
    );
    expect(
      errorMessage(HttpStatusException(response(404))),
      contains('not be found'),
    );
    expect(
      errorMessage(HttpStatusException(response(503))),
      contains('server had a problem'),
    );
    expect(errorMessage(HttpStatusException(response(418))), contains('418'));
    expect(errorMessage(StateError('bug')), 'Something went wrong. Try again.');
  });
}
'''),
];
