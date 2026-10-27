<!-- i18n-source: README.md@dfd27954e8f8ed0c099ad2f5b125c87183212c58 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

FlutterForge sind zwei Werkzeuge für Flutter-Entwickler in einem Dart-Paket. `ForgeClient` ist ein JSON-over-HTTP-Client auf Basis von [`package:http`](https://pub.dev/packages/http): Er wiederholt Anfragen, cacht Antworten, erneuert Bearer-Tokens, begrenzt Zeit und Antwortgröße und lehnt unsichere Weiterleitungen ab. `forge` ist ein Befehl, der eine Flutter-App erstellt – oder einer bestehenden App ein Feature hinzufügt – mit einem Feature-first-Layout, Riverpod, go_router, diesem Client und Tests für jede Schicht. Ein neues Projekt startet so mit Code, der `flutter analyze` und `flutter test` bereits besteht. Du kannst den Client auch ohne den Befehl verwenden, und die generierte App ist normaler Flutter-Code, den du frei ändern kannst.

## Highlights

- **Ein einziger Fehlertyp zum Behandeln** – jeder Fehler ist eine versiegelte (sealed) `ApiException`, ein `switch` darüber wird also vom Compiler geprüft. Ihr `toString` nennt nur Methode und Host, nie Pfad, Query, Header oder Body.
- **Wiederholungen, die sich gefahrlos wiederholen lassen** – idempotente Anfragen werden nach Verbindungsfehlern, Timeouts und `408`/`429`/`5xx` mit Backoff samt Jitter und unter Beachtung von `Retry-After` wiederholt; `POST` und `PATCH` nicht, es sei denn, du verlangst es.
- **Cache für den Offline-Betrieb** – `networkFirst` greift auf die letzte Antwort zurück, wenn das Gerät offline ist; `cacheFirst` validiert mit `ETag` und `Last-Modified` neu. Der Speichercache ist nach Einträgen und Bytes begrenzt.
- **Tokens bleiben dort, wo sie hingehören** – das Bearer-Token geht nur an den Origin der API, gleichzeitige `401`-Antworten teilen sich eine einzige Erneuerung, und bei Weiterleitungen zu einem anderen Origin werden `Authorization` und `Cookie` verworfen (außer im Web, wo der Browser die Weiterleitungen verfolgt).
- **Standardmäßig begrenzt** – ein Limit von 30 s pro Versuch, ein Antwortlimit von 16 MiB, das auch endlose Bodys stoppt, ein Abbruch, der die Verbindung schließt, und Header-Werte, die keine neue Header-Zeile einschleusen können.
- **Ein Generator, dessen Ausgabe getestet wird** – die [Beispiel-App](example) ist exakt die Ausgabe von `forge create`; die CI analysiert und testet sie, und ein Test schlägt fehl, wenn sie von den Templates abweicht.

## Schnellstart

**1. Den Befehl `forge` installieren**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

Du brauchst [Flutter](https://docs.flutter.dev/install) 3.44 oder neuer, das Dart enthält. Wenn dein Terminal danach `forge: command not found` meldet, füge den Ordner, den Dart ausgegeben hat (`$HOME/.pub-cache/bin` unter macOS und Linux, `%LOCALAPPDATA%\Pub\Cache\bin` unter Windows), zu deinem `PATH` hinzu und öffne ein neues Terminal.

**2. Eine App erstellen**

```sh
forge create my_app
```

Das führt `flutter create` für die Android- und iOS-Ordner aus, schreibt die App, ihre Tests und einen GitHub-Actions-Workflow, der sie prüft, und führt `flutter pub get` aus. Mit `--org com.yourcompany` legst du die App-ID fest, mit `--platforms ios,android,web,macos` ergänzt du weitere Plattformen.

**3. Starten**

```sh
cd my_app
flutter run
```

Die App öffnet sich mit einer Startseite, die einen Eintrag **Todos** enthält; tippe darauf, um eine Liste von `jsonplaceholder.typicode.com` zu laden. Mit `flutter test` siehst du, dass die generierten Tests bestehen, und mit `forge feature orders` fügst du einen zweiten Bildschirm mit eigenen Tests hinzu.

## Installation

Um nur den HTTP-Client in einem bestehenden Flutter- oder Dart-Projekt zu verwenden, füge das Paket zu `pubspec.yaml` hinzu:

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Führe dann `flutter pub get` (oder `dart pub get`) aus und importiere es:

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

Das Paket hängt nur von `http`, `http_parser`, `args` und `path` ab und läuft unter Android, iOS, macOS, Windows, Linux, im Web und auf der Dart VM. Es wird über Git installiert, weil der Name `flutter_forge` auf pub.dev zu einem anderen, eingestellten Paket gehört.

Version 2.0.0 ist eine Neuentwicklung: Der Quellcode von 1.0.0 ließ sich nicht kompilieren, und von seiner API existiert nichts mehr. Details stehen in [CHANGELOG.md](CHANGELOG.md).

## Verwendung

Jedes der folgenden Beispiele steht auch in [test/readme_test.dart](test/readme_test.dart); dieser Test führt sie gegen einen Fake-Server aus.

### Eine API aufrufen

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

Relative Pfade werden an die Basis-URL angehängt. Alles, was `decode` wirft, wird zu einer `DecodingException`.

### Fehler behandeln

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

`HttpStatusException.response` behält den Body, den der Server mit dem Fehler gesendet hat.

### Die letzte Antwort für die Offline-Nutzung behalten

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Verwende `CachePolicy.cacheFirst`, um die Anfrage zu überspringen, solange die gespeicherte Antwort frisch ist, und rufe `cache.clear()` auf, wenn der angemeldete Nutzer wechselt.

### Ein Bearer-Token senden

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` speichert das neue Token und gibt es zurück, oder gibt `null` zurück, wenn sich der Nutzer erneut anmelden muss.

### Ohne Server testen

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

`MockClient` stammt aus `package:http/testing.dart`.

### Einer generierten App ein Feature hinzufügen

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Jeder Befehl schreibt `lib/features/<name>/{domain,data,presentation}` und zwei Testdateien, trägt die Route in `lib/app/router.dart` ein, fügt den Bildschirm zur Startseite hinzu und formatiert, was er geändert hat. Namen, die sich nicht kompilieren ließen – etwa ein Feature, dessen Entity `Text` heißen würde –, werden abgelehnt, bevor etwas geschrieben wird.

## Screenshots

Die Beispiel-App im iPhone-18-Pro-Simulator (iOS 27), mit Live-Daten von `jsonplaceholder.typicode.com`:

| Start | Todos | Todos, dunkel | Offline |
| --- | --- | --- | --- |
| ![Startseite mit dem Bildschirm Todos](docs/screenshots/home.png) | ![Von der API geladene Todo-Liste](docs/screenshots/todos.png) | ![Todo-Liste im dunklen Erscheinungsbild](docs/screenshots/todos-dark.png) | ![Offline-Meldung mit einer Schaltfläche zum erneuten Versuchen](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) baut das Beispiel und erstellt diese Screenshots. So führst du das Beispiel selbst aus:

```sh
cd example
flutter run
```

## Dokumentation

- [API-Referenz und Anleitungen](https://muhittincamdali.github.io/FlutterForge/) – mit `dart doc` erzeugt und von `main` auf GitHub Pages veröffentlicht.
- Lokal erzeugst du sie mit `dart doc --output build/doc`; öffne dann `build/doc/index.html`.
- `forge --help`, `forge create --help` und `forge feature --help` listen alle Optionen auf.

## Anleitungen

- [Eine API mit ForgeClient aufrufen](doc/guides/calling-an-api.md) – typisierte Anfragen, Fehler, Wiederholungen, Caching, Tokens, Abbruch, Interceptors und Tests.
- [Eine App mit forge bauen](doc/guides/creating-an-app.md) – eine App erstellen, ihr Layout verstehen, ein Feature hinzufügen, sie auf deine API ausrichten und ein Feld ergänzen.
- [Wovor der Client schützt](doc/guides/security-model.md) – Weiterleitungen, Header-Injection, Speichergrenzen, feindliche Zahlen und was dir überlassen bleibt.

## Voraussetzungen

| Toolchain | Mindestversion |
| --- | --- |
| Dart (Bibliothek und `forge`) | 3.12 |
| Flutter (generierte Apps) | 3.44 |

Generierte Apps verwenden Riverpod 3.4, go_router 18.1 und `http` 1.6. Das Paket wird mit Flutter 3.47 und Dart 3.13 entwickelt und getestet; die CI nutzt das aktuelle stabile Flutter-Release.

## Architektur

- `lib/src/network/` – `ForgeClient` baut um einen Transport eine Kette von Interceptors: zuerst deine Interceptors, dann `CacheInterceptor`, `RetryInterceptor` und `BearerAuthInterceptor`. Der Transport sendet eine Anfrage über `package:http` mit abgeschalteten Weiterleitungen, folgt Weiterleitungen selbst, erzwingt das Zeitlimit mit `Abortable`-Anfragen und liest den Body mit einem Byte-Limit. Anfragen und Antworten sind unveränderliche (immutable) Werte.
- `lib/src/cli/` – `forge` ist ein `CommandRunner` aus `package:args`. Templates sind Dart-String-Konstanten, die ein strikter `{{key}}`-Replacer rendert und der bei einem fehlenden Wert fehlschlägt; Namen werden validiert, bevor eine Datei angefasst wird, und Dateien werden nur innerhalb des Projekts geschrieben.
- `example/` – die Ausgabe von `forge create`, die über `path: ..` von diesem Checkout abhängt.
- `test/` – Unit-Tests für den Client (mit einem Fake-`http.Client`, der Abbruch und gestreamte Bodys unterstützt), für die CLI (mit einem Fake-Process-Runner in einem temporären Ordner), für die README-Beispiele sowie ein Test, der das Beispiel neu generiert und Datei für Datei vergleicht.

Die Prüfungen lokal ausführen:

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## Roadmap

- Upload- und Download-Fortschritt für große Bodys.
- Ein persistenter `ResponseCache` (Dateien oder SQLite) neben `MemoryResponseCache`.
- Weitere `forge`-Templates: Lokalisierung und Build-Flavors für die neue App.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
