<!-- i18n-source: README.md@dfd27954e8f8ed0c099ad2f5b125c87183212c58 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="Версия языка: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

FlutterForge — это два инструмента для разработчиков на Flutter в одном пакете Dart. `ForgeClient` — клиент JSON-over-HTTP на основе [`package:http`](https://pub.dev/packages/http): он повторяет запросы, кеширует ответы, обновляет bearer token, ограничивает время и размер ответа и отказывается следовать небезопасным редиректам. `forge` — команда, которая создаёт приложение на Flutter или добавляет в него новую функциональность: структуру feature-first, Riverpod, go_router, этот клиент и тесты для каждого слоя. Поэтому новый проект сразу начинается с кода, который уже проходит `flutter analyze` и `flutter test`. Клиентом можно пользоваться и без команды, а сгенерированное приложение — это обычный код на Flutter, который вы можете менять.

## Основные возможности

- **Один тип ошибки для обработки** — любая ошибка является запечатанным (sealed) `ApiException`, поэтому `switch` по нему проверяется компилятором, а его `toString` называет только метод и хост, но никогда не путь, query, заголовки или тело.
- **Повторы, которые безопасно повторять** — идемпотентные запросы повторяются после ошибок соединения, таймаутов и ответов `408`/`429`/`5xx` с отсрочкой (backoff) с jitter и с учётом `Retry-After`; `POST` и `PATCH` не повторяются, пока вы сами этого не потребуете.
- **Кеш, удобный без сети** — `networkFirst` возвращается к последнему ответу, когда устройство офлайн; `cacheFirst` перепроверяет ответ через `ETag` и `Last-Modified`. Кеш в памяти ограничен по числу записей и по байтам.
- **Токены остаются там, где им место** — bearer token отправляется только на origin API, одновременные ответы `401` используют одно общее обновление, а при редиректе на другой origin заголовки `Authorization` и `Cookie` отбрасываются (кроме веба, где редиректы выполняет браузер).
- **Ограничения по умолчанию** — лимит 30 с на попытку, лимит ответа 16 MiB, который останавливает и бесконечные тела, отмена, закрывающая соединение, и значения заголовков, в которые нельзя внедрить новую строку заголовка.
- **Генератор, вывод которого тестируется** — [пример приложения](example) — это в точности вывод `forge create`; CI анализирует и тестирует его, а если он расходится с шаблонами, тест падает.

## Быстрый старт

**1. Установите команду `forge`**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

Вам нужен [Flutter](https://docs.flutter.dev/install) 3.44 или новее, в который входит Dart. Если после этого терминал отвечает `forge: command not found`, добавьте в `PATH` папку, которую вывел Dart (`$HOME/.pub-cache/bin` в macOS и Linux, `%LOCALAPPDATA%\Pub\Cache\bin` в Windows), и откройте новый терминал.

**2. Создайте приложение**

```sh
forge create my_app
```

Команда запускает `flutter create` для папок Android и iOS, записывает приложение, его тесты и workflow GitHub Actions, который их проверяет, и выполняет `flutter pub get`. Добавьте `--org com.yourcompany`, чтобы задать идентификатор приложения, или `--platforms ios,android,web,macos`, чтобы включить больше платформ.

**3. Запустите его**

```sh
cd my_app
flutter run
```

Приложение открывается на главной странице с пунктом **Todos**; нажмите на него, чтобы загрузить список с `jsonplaceholder.typicode.com`. Выполните `flutter test`, чтобы увидеть, как проходят сгенерированные тесты, и `forge feature orders`, чтобы добавить второй экран с собственными тестами.

## Установка

Чтобы использовать только HTTP-клиент в существующем проекте на Flutter или Dart, добавьте пакет в `pubspec.yaml`:

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

Затем выполните `flutter pub get` (или `dart pub get`) и импортируйте его:

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

Пакет зависит только от `http`, `http_parser`, `args` и `path` и работает на Android, iOS, macOS, Windows, Linux, в вебе и на Dart VM. Он устанавливается из Git, потому что имя `flutter_forge` на pub.dev принадлежит другому, заброшенному пакету.

Версия 2.0.0 — это переписанный с нуля пакет: исходный код 1.0.0 не компилировался, и от его API ничего не осталось. Подробности — в [CHANGELOG.md](CHANGELOG.md).

## Использование

Каждый из примеров ниже есть и в [test/readme_test.dart](test/readme_test.dart): этот тест запускает их на поддельном сервере.

### Вызов API

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

Относительные пути добавляются к базовому URL. Всё, что выбрасывает `decode`, становится `DecodingException`.

### Обработка ошибок

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

`HttpStatusException.response` хранит тело, которое сервер прислал вместе с ошибкой.

### Сохранение последнего ответа для работы без сети

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

Используйте `CachePolicy.cacheFirst`, чтобы пропускать запрос, пока сохранённый ответ свежий, и вызывайте `cache.clear()`, когда меняется вошедший в систему пользователь.

### Отправка bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` сохраняет новый токен и возвращает его; если пользователю нужно войти заново, возвращает `null`.

### Тестирование без сервера

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

`MockClient` берётся из `package:http/testing.dart`.

### Добавление функциональности в сгенерированное приложение

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

Каждая команда записывает `lib/features/<name>/{domain,data,presentation}` и два файла с тестами, добавляет маршрут в `lib/app/router.dart`, добавляет экран на главную страницу и форматирует изменённое. Имена, с которыми код не скомпилируется, — например, функциональность, чья сущность называлась бы `Text`, — отклоняются до того, как что-либо будет записано.

## Скриншоты

Пример приложения на симуляторе iPhone 18 Pro (iOS 27) с живыми данными с `jsonplaceholder.typicode.com`:

| Главная | Todos | Todos, тёмная тема | Без сети |
| --- | --- | --- | --- |
| ![Главная страница, в списке которой есть экран Todos](docs/screenshots/home.png) | ![Список задач, загруженный из API](docs/screenshots/todos.png) | ![Список задач в тёмной теме](docs/screenshots/todos-dark.png) | ![Сообщение об отсутствии сети с кнопкой повтора](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) собирает пример и делает эти скриншоты. Чтобы запустить пример самостоятельно:

```sh
cd example
flutter run
```

## Документация

- [Справочник API и руководства](https://muhittincamdali.github.io/FlutterForge/) — собираются командой `dart doc` и публикуются на GitHub Pages из ветки `main`.
- Чтобы собрать их локально, выполните `dart doc --output build/doc` и откройте `build/doc/index.html`.
- `forge --help`, `forge create --help` и `forge feature --help` показывают все параметры.

## Руководства

- [Вызов API с помощью ForgeClient](doc/guides/calling-an-api.md) — типизированные запросы, ошибки, повторы, кеширование, токены, отмена, interceptor и тесты.
- [Создание приложения с помощью forge](doc/guides/creating-an-app.md) — создать приложение, разобраться в его структуре, добавить функциональность, направить его на ваш API и добавить поле.
- [От чего защищает клиент](doc/guides/security-model.md) — редиректы, внедрение заголовков, ограничения памяти, злонамеренные числа и то, что остаётся на вашей стороне.

## Требования

| Инструменты | Минимальная версия |
| --- | --- |
| Dart (библиотека и `forge`) | 3.12 |
| Flutter (сгенерированные приложения) | 3.44 |

Сгенерированные приложения используют Riverpod 3.4, go_router 18.1 и `http` 1.6. Пакет разрабатывается и тестируется на Flutter 3.47 и Dart 3.13; CI использует последний стабильный выпуск Flutter.

## Архитектура

- `lib/src/network/` — `ForgeClient` строит цепочку interceptor вокруг транспорта: ваши interceptor, затем `CacheInterceptor`, `RetryInterceptor` и `BearerAuthInterceptor`. Транспорт отправляет один запрос через `package:http` с отключёнными редиректами, сам следует редиректам, соблюдает лимит времени с помощью запросов `Abortable` и читает тело с ограничением в байтах. Запросы и ответы — неизменяемые (immutable) значения.
- `lib/src/cli/` — `forge` — это `CommandRunner` из `package:args`. Шаблоны — строковые константы Dart, которые обрабатывает строгая подстановка `{{key}}`: при отсутствии значения она завершается ошибкой; имена проверяются до обращения к любому файлу, а файлы записываются только внутри проекта.
- `example/` — вывод `forge create`; зависит от этой рабочей копии через `path: ..`.
- `test/` — модульные тесты клиента (с поддельным `http.Client`, поддерживающим отмену и потоковые тела), CLI (с поддельным process runner во временной папке), примеров из README и тест, который заново генерирует пример и сравнивает его файл за файлом.

Запустите проверки локально:

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## План развития

- Отображение прогресса загрузки и скачивания больших тел.
- Постоянный `ResponseCache` (файлы или SQLite) рядом с `MemoryResponseCache`.
- Больше шаблонов `forge`: локализация и build flavor для нового приложения.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
