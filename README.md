<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Latest version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Language version: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

FlutterForge is two tools for Flutter developers in one Dart package. `ForgeClient` is a
JSON-over-HTTP client built on [`package:http`](https://pub.dev/packages/http) that retries,
caches, refreshes bearer tokens, limits time and response size, and refuses unsafe redirects.
`forge` is a command that creates a Flutter app — or adds a feature to one — with a
feature-first layout, Riverpod, go_router, that client and tests for every layer, so a new
project starts with code that already passes `flutter analyze` and `flutter test`. You can use
the client without the command, and the generated app is plain Flutter code you can change.

## Highlights

- **One error type to handle** — every failure is a sealed `ApiException`, so a `switch` over
  it is checked by the compiler, and its `toString` names only the method and host, never the
  path, query, headers or body.
- **Retries that are safe to repeat** — idempotent requests are retried after connection errors,
  timeouts and `408`/`429`/`5xx` with jittered backoff and `Retry-After`; `POST` and `PATCH`
  are not, unless you ask.
- **Offline-friendly cache** — `networkFirst` falls back to the last answer when the device is
  offline; `cacheFirst` revalidates with `ETag` and `Last-Modified`. The memory cache is
  bounded by entries and bytes.
- **Tokens that stay where they belong** — the bearer token goes only to the API's origin,
  concurrent `401` answers share one refresh, and redirects to another origin drop
  `Authorization` and `Cookie` (outside the web, where the browser follows redirects).
- **Bounded by default** — a 30 s limit per attempt, a 16 MiB response limit that also stops
  endless bodies, cancellation that closes the connection, and header values that cannot inject
  a new header line.
- **A generator whose output is tested** — the [example app](example) is the exact output of
  `forge create`; CI analyzes and tests it, and a test fails if it drifts from the templates.

## Quick start

**1. Install the `forge` command**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

You need [Flutter](https://docs.flutter.dev/install) 3.44 or later, which includes
Dart. If your terminal then says `forge: command not found`, add the folder Dart printed
(`$HOME/.pub-cache/bin` on macOS and Linux, `%LOCALAPPDATA%\Pub\Cache\bin` on Windows) to your
`PATH` and open a new terminal.

**2. Create an app**

```sh
forge create my_app
```

This runs `flutter create` for the Android and iOS folders, writes the app, its tests and a
GitHub Actions workflow that checks them, and runs `flutter pub get`. Add `--org com.yourcompany` to set the app id, or
`--platforms ios,android,web,macos` for more platforms.

**3. Run it**

```sh
cd my_app
flutter run
```

The app opens on a home page with a **Todos** entry; tap it to load a list from
`jsonplaceholder.typicode.com`. Run `flutter test` to see the generated tests pass, and
`forge feature orders` to add a second screen with its own tests.

## Installation

To use only the HTTP client in an existing Flutter or Dart project, add the package to
`pubspec.yaml`:

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Then run `flutter pub get` (or `dart pub get`) and import it:

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

The package depends only on `http`, `http_parser`, `args` and `path`, and runs on Android, iOS,
macOS, Windows, Linux, the web and the Dart VM. It is installed from Git because the name
`flutter_forge` on pub.dev belongs to another, discontinued package.

Version 2.0.0 is a rewrite: the 1.0.0 sources did not compile, and none of their API exists any
more. [CHANGELOG.md](CHANGELOG.md) has the details.

## Usage

Every sample below is also in [test/readme_test.dart](test/readme_test.dart), which runs it
against a fake server.

### Call an API

```dart
final class Todo {
  const Todo({required this.id, required this.title});

  final int id;
  final String title;

  static Todo fromJson(Object? json) => switch (json) {
    {'id': final int id, 'title': final String title} => Todo(id: id, title: title),
    _ => throw const FormatException('Not a todo'),
  };

  static List<Todo> listFromJson(Object? json) => [for (final item in json! as List<Object?>) fromJson(item)];
}

final client = ForgeClient(baseUrl: 'https://jsonplaceholder.typicode.com');
final todo = await client.getJson('/todos/1', decode: Todo.fromJson);
print(todo.title); // delectus aut autem

final created = await client.postJson('/todos', json: {'title': 'Ship it'}, decode: (json) => json);
```

Relative paths are appended to the base URL. Anything `decode` throws becomes a
`DecodingException`.

### Handle failures

```dart
String messageFor(Object error) => switch (error) {
  ConnectionException() => 'You appear to be offline.',
  RequestTimeoutException() => 'The server took too long to answer.',
  HttpStatusException(statusCode: 404) => 'Not found.',
  HttpStatusException(:final statusCode) => 'The server answered $statusCode.',
  ApiException() => 'Something went wrong.',
  _ => 'Unexpected error: $error',
};

try {
  await client.getJson('/todos/999', decode: Todo.fromJson);
} on ApiException catch (error) {
  print(messageFor(error)); // Not found.
}
```

`HttpStatusException.response` keeps the body the server sent with the error.

### Keep the last answer for offline use

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Use `CachePolicy.cacheFirst` to skip the request while the stored answer is fresh, and call
`cache.clear()` when the signed-in user changes.

### Send a bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` stores the new token and returns it, or returns `null` when the user has to sign in
again.

### Test without a server

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  retry: RetryPolicy.none,
  httpClient: MockClient((request) async {
    expect(request.url.path, '/todos');
    return http.Response(jsonEncode([
      {'id': 1, 'title': 'Test'},
    ]), 200);
  }),
);

expect(await client.getJson('/todos', decode: Todo.listFromJson), hasLength(1));
```

`MockClient` comes from `package:http/testing.dart`.

### Add a feature to a generated app

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Each command writes `lib/features/<name>/{domain,data,presentation}` and two test files, adds
the route to `lib/app/router.dart`, adds the screen to the home page, and formats what it
changed. Names that would not compile, such as a feature whose entity would be called `Text`,
are refused before anything is written.

## Screenshots

The example app on an iPhone 18 Pro simulator (iOS 27), with live data from
`jsonplaceholder.typicode.com`:

| Home | Todos | Todos, dark | Offline |
| --- | --- | --- | --- |
| ![Home page listing the Todos screen](docs/screenshots/home.png) | ![Todo list loaded from the API](docs/screenshots/todos.png) | ![Todo list in dark appearance](docs/screenshots/todos-dark.png) | ![Offline message with a Try again button](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) builds the example and takes these
screenshots. To run the example yourself:

```sh
cd example
flutter run
```

## Documentation

- [API reference and guides](https://muhittincamdali.github.io/FlutterForge/) — built with
  `dart doc` and published to GitHub Pages from `main`.
- Build it locally with `dart doc --output build/doc` and open `build/doc/index.html`.
- `forge --help`, `forge create --help` and `forge feature --help` list every option.

## Guides

- [Calling an API with ForgeClient](doc/guides/calling-an-api.md) — typed requests, errors,
  retries, caching, tokens, cancellation, interceptors and tests.
- [Building an app with forge](doc/guides/creating-an-app.md) — create an app, read its layout,
  add a feature, point it at your API and add a field.
- [What the client guards against](doc/guides/security-model.md) — redirects, header injection,
  memory limits, hostile numbers, and what is left to you.

## Requirements

| Toolchain | Minimum version |
| --- | --- |
| Dart (library and `forge`) | 3.12 |
| Flutter (generated apps) | 3.44 |

Generated apps use Riverpod 3.4, go_router 18.1 and `http` 1.6. The package is developed and
tested with Flutter 3.47 and Dart 3.13; CI uses the latest stable Flutter release.

## Architecture

- `lib/src/network/` — `ForgeClient` builds a chain of interceptors around a transport: your
  interceptors, then `CacheInterceptor`, `RetryInterceptor` and `BearerAuthInterceptor`. The
  transport sends one request through `package:http` with redirects turned off, follows
  redirects itself, enforces the time limit with `Abortable` requests and reads the body with
  a byte limit. Requests and responses are immutable values.
- `lib/src/cli/` — `forge` is a `CommandRunner` from `package:args`. Templates are Dart string
  constants rendered by a strict `{{key}}` replacer that fails on a missing value; names are
  validated before any file is touched, and files are written only inside the project.
- `example/` — the output of `forge create`, depending on this checkout with `path: ..`.
- `test/` — unit tests for the client (with a fake `http.Client` that supports aborting and
  streamed bodies), the CLI (with a fake process runner in a temporary folder), the README
  samples, and a test that regenerates the example and compares it file by file.

Run the checks locally:

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## Roadmap

- Upload and download progress for large bodies.
- A persistent `ResponseCache` (files or SQLite) next to `MemoryResponseCache`.
- More `forge` templates: localization and build flavors for the new app.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
