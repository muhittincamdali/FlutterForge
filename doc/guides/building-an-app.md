# Building an app with forge

This guide creates an app, adds a feature, points it at a real API and adds a
field, with the tests passing at every step.

## 1. Install the command

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

Dart prints the folder that holds global commands. If `forge --version` is not
found afterwards, add that folder (`$HOME/.pub-cache/bin` on macOS and Linux,
`%LOCALAPPDATA%\Pub\Cache\bin` on Windows) to your `PATH`.

## 2. Create the app

```sh
forge create shop --org com.acme
cd shop
flutter run
```

`forge create` runs `flutter create` for the Android and iOS folders (choose
others with `--platforms ios,android,web,macos`), replaces `lib/` and `test/`
with its own files, formats them and runs `flutter pub get`. The app opens on a
home page with one entry, **Todos**, which loads a list from
`https://jsonplaceholder.typicode.com/todos`.

Check that everything works before changing anything:

```sh
flutter analyze
flutter test
```

## 3. Read the layout

```text
lib/
  main.dart            ProviderScope around App
  app/
    app.dart           MaterialApp.router with the light and dark theme
    theme.dart         ColorScheme.fromSeed(0xFF0A84FF)
    router.dart        go_router routes          (marker: // forge:routes)
    destinations.dart  entries of the home page  (marker: // forge:destinations)
  core/
    network.dart       the shared ForgeClient and API_BASE_URL
    error_message.dart ApiException -> sentence for the user
    widgets/error_view.dart
  features/
    home/home_page.dart
    todos/
      domain/          Todo, TodosRepository (no Flutter, no HTTP)
      data/            todoFromJson, HttpTodosRepository + its provider
      presentation/    TodosController (AsyncNotifier), TodosPage
```

The page watches the controller, the controller reads the repository through
its provider, and only `data/` imports `flutter_forge`. Tests replace the
repository with `todosRepositoryProvider.overrideWithValue(fake)`.

## 4. Add a feature

```sh
forge feature orders
```

The command writes eight files — the three layers and two test files — and
adds three lines to existing files: an import and a route in
`lib/app/router.dart` and an entry in `lib/app/destinations.dart`. It then runs
`dart format` on what it changed.

| Option                      | Default                                   | Meaning            |
| --------------------------- | ----------------------------------------- | ------------------ |
| `--entity`                  | singular of the name (`orders` → `Order`) | Class of one item  |
| `--api-path`                | `/<name>` with `-` for `_`                | The list endpoint  |
| `-C`, `--project-directory` | current folder                            | The app to change  |
| `--no-format`               |                                           | Skip `dart format` |

Names that would not compile are refused before anything is written: a
feature called `texts` would create a class `Text` that hides Flutter's
widget, so `forge` asks for `--entity Note` instead.

## 5. Point the app at your API

The base URL comes from a compile-time variable:

```sh
flutter run --dart-define=API_BASE_URL=https://api.acme.com
```

To keep it for every run, change the `defaultValue` in
`lib/core/network.dart`. A bearer token, a different cache size or extra
headers are constructor arguments of the `ForgeClient` in the same file; see
[Calling an API with ForgeClient](https://github.com/muhittincamdali/FlutterForge/blob/main/doc/guides/calling-an-api.md).

## 6. Add a field

Each generated entity has `id` and `title`. To add a price to `Order`:

1. Add `final double price;` and the constructor parameter in
   `lib/features/orders/domain/order.dart`, and include it in `==` and
   `hashCode`.
2. Read it in `lib/features/orders/data/order_json.dart`:

    ```dart
    if (json case {
      'id': final int id,
      'title': final String title,
      'price': final num price,
    }) {
      return Order(id: id, title: title, price: price.toDouble());
    }
    ```

3. Show it in `orders_page.dart`, for example as the `trailing` of the
   `ListTile`.
4. Add `'price': 9.5` to the JSON in
   `test/features/orders/data/http_orders_repository_test.dart` and the price
   to the expected `Order` values; then run `flutter test`.

## 7. Work on one screen

```sh
flutter run --dart-define=INITIAL_ROUTE=/orders
```

starts the app on the orders page, which saves a tap after every restart.

## 8. Keep the markers

`forge feature` looks for the comments `// forge:routes` and
`// forge:destinations`. Move them if you restructure the files; if they are
gone, the command still writes the feature and prints the lines to add by hand.
