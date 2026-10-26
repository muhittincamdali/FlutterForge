# Forge example

The FlutterForge example app: a todo list read from a JSON API.

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
