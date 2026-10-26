<!-- i18n-source: README.md@dfd27954e8f8ed0c099ad2f5b125c87183212c58 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="언어 버전: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

FlutterForge는 Flutter 개발자를 위한 두 가지 도구를 하나의 Dart 패키지로 제공합니다. `ForgeClient`는 [`package:http`](https://pub.dev/packages/http) 위에 만든 JSON-over-HTTP 클라이언트로, 요청을 재시도하고, 응답을 캐시하고, bearer token을 갱신하고, 시간과 응답 크기를 제한하며, 안전하지 않은 리디렉션을 거부합니다. `forge`는 Flutter 앱을 만들거나 기존 앱에 기능을 추가하는 명령입니다. feature-first 구조, Riverpod, go_router, 이 클라이언트, 그리고 모든 계층의 테스트를 갖춘 코드를 생성하므로, 새 프로젝트가 이미 `flutter analyze`와 `flutter test`를 통과하는 코드로 시작합니다. 명령 없이 클라이언트만 사용할 수도 있으며, 생성된 앱은 자유롭게 수정할 수 있는 평범한 Flutter 코드입니다.

## 주요 기능

- **처리할 오류 타입은 하나** — 모든 실패는 sealed `ApiException`이므로 이에 대한 `switch`를 컴파일러가 검사합니다. `toString`은 메서드와 호스트만 보여 주며, 경로, 쿼리, 헤더, 본문은 절대 포함하지 않습니다.
- **반복해도 안전한 재시도** — 멱등(idempotent) 요청은 연결 오류, 타임아웃, `408`/`429`/`5xx` 이후에 지터가 있는 백오프와 `Retry-After`에 따라 재시도됩니다. `POST`와 `PATCH`는 요청하지 않는 한 재시도하지 않습니다.
- **오프라인에 강한 캐시** — `networkFirst`는 기기가 오프라인일 때 마지막 응답으로 대체하고, `cacheFirst`는 `ETag`와 `Last-Modified`로 재검증합니다. 메모리 캐시는 항목 수와 바이트 수로 제한됩니다.
- **토큰은 있어야 할 곳에만** — bearer token은 API의 origin에만 전송되고, 동시에 발생한 `401` 응답은 하나의 갱신을 공유하며, 다른 origin으로의 리디렉션에서는 `Authorization`과 `Cookie`를 제거합니다(웹은 제외이며, 웹에서는 브라우저가 리디렉션을 처리합니다).
- **기본적으로 제한됨** — 시도당 30초 제한, 끝없는 본문도 중단시키는 16 MiB 응답 제한, 연결을 닫는 취소, 새 헤더 줄을 주입할 수 없는 헤더 값.
- **출력이 테스트되는 생성기** — [예제 앱](example)은 `forge create`의 출력 그대로입니다. CI가 이를 분석하고 테스트하며, 템플릿과 달라지면 테스트가 실패합니다.

## 빠른 시작

**1. `forge` 명령 설치**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

[Flutter](https://docs.flutter.dev/install) 3.44 이상이 필요하며, Dart가 함께 포함되어 있습니다. 이후 터미널에서 `forge: command not found`라고 나오면, Dart가 출력한 폴더(macOS와 Linux에서는 `$HOME/.pub-cache/bin`, Windows에서는 `%LOCALAPPDATA%\Pub\Cache\bin`)를 `PATH`에 추가하고 새 터미널을 여세요.

**2. 앱 만들기**

```sh
forge create my_app
```

이 명령은 Android와 iOS 폴더를 위해 `flutter create`를 실행하고, 앱과 테스트, 그리고 테스트를 검사하는 GitHub Actions workflow를 작성한 다음 `flutter pub get`을 실행합니다. 앱 ID를 지정하려면 `--org com.yourcompany`를, 더 많은 플랫폼을 지원하려면 `--platforms ios,android,web,macos`를 추가하세요.

**3. 실행하기**

```sh
cd my_app
flutter run
```

앱은 **Todos** 항목이 있는 홈 화면으로 시작합니다. 항목을 누르면 `jsonplaceholder.typicode.com`에서 목록을 불러옵니다. `flutter test`를 실행하면 생성된 테스트가 통과하는 것을 볼 수 있고, `forge feature orders`를 실행하면 자체 테스트가 딸린 두 번째 화면이 추가됩니다.

## 설치

기존 Flutter 또는 Dart 프로젝트에서 HTTP 클라이언트만 사용하려면 `pubspec.yaml`에 패키지를 추가하세요.

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

그런 다음 `flutter pub get`(또는 `dart pub get`)을 실행하고 import하세요.

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

이 패키지는 `http`, `http_parser`, `args`, `path`에만 의존하며 Android, iOS, macOS, Windows, Linux, 웹, Dart VM에서 실행됩니다. pub.dev의 `flutter_forge`라는 이름은 개발이 중단된 다른 패키지의 것이므로 Git에서 설치합니다.

2.0.0 버전은 처음부터 다시 작성한 것입니다. 1.0.0 소스는 컴파일되지 않았고, 그 API는 더 이상 하나도 남아 있지 않습니다. 자세한 내용은 [CHANGELOG.md](CHANGELOG.md)를 참고하세요.

## 사용법

아래 예제는 모두 [test/readme_test.dart](test/readme_test.dart)에도 있으며, 이 테스트가 가짜 서버를 상대로 예제를 실행합니다.

### API 호출하기

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

상대 경로는 base URL 뒤에 붙습니다. `decode`가 던지는 모든 예외는 `DecodingException`이 됩니다.

### 실패 처리하기

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

`HttpStatusException.response`는 서버가 오류와 함께 보낸 본문을 보관합니다.

### 오프라인용으로 마지막 응답 유지하기

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

저장된 응답이 최신인 동안 요청을 건너뛰려면 `CachePolicy.cacheFirst`를 사용하고, 로그인한 사용자가 바뀌면 `cache.clear()`를 호출하세요.

### bearer token 보내기

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh`는 새 토큰을 저장하고 반환하며, 사용자가 다시 로그인해야 하면 `null`을 반환합니다.

### 서버 없이 테스트하기

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

`MockClient`는 `package:http/testing.dart`에 있습니다.

### 생성된 앱에 기능 추가하기

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

각 명령은 `lib/features/<name>/{domain,data,presentation}` 아래에 파일과 테스트 파일 두 개를 작성하고, `lib/app/router.dart`에 라우트를 추가하고, 홈 화면에 해당 화면을 추가하며, 변경한 파일을 포맷합니다. 엔티티 이름이 `Text`가 되는 기능처럼 컴파일되지 않는 이름은 아무것도 쓰기 전에 거부됩니다.

## 스크린샷

iPhone 18 Pro 시뮬레이터(iOS 27)에서 실행한 예제 앱이며, `jsonplaceholder.typicode.com`의 실시간 데이터를 사용합니다.

| 홈 | Todos | Todos, 다크 | 오프라인 |
| --- | --- | --- | --- |
| ![Todos 화면이 표시된 홈 화면](docs/screenshots/home.png) | ![API에서 불러온 할 일 목록](docs/screenshots/todos.png) | ![다크 모드의 할 일 목록](docs/screenshots/todos-dark.png) | ![다시 시도 버튼이 있는 오프라인 메시지](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh)가 예제를 빌드하고 이 스크린샷을 촬영합니다. 예제를 직접 실행하려면 다음과 같이 하세요.

```sh
cd example
flutter run
```

## 문서

- [API 레퍼런스와 가이드](https://muhittincamdali.github.io/FlutterForge/) — `dart doc`으로 생성되며 `main`에서 GitHub Pages로 게시됩니다.
- 로컬에서 빌드하려면 `dart doc --output build/doc`을 실행하고 `build/doc/index.html`을 여세요.
- `forge --help`, `forge create --help`, `forge feature --help`가 모든 옵션을 보여 줍니다.

## 가이드

- [ForgeClient로 API 호출하기](doc/guides/calling-an-api.md) — 타입이 있는 요청, 오류, 재시도, 캐시, 토큰, 취소, interceptor, 테스트.
- [forge로 앱 만들기](doc/guides/creating-an-app.md) — 앱 생성, 구조 읽기, 기능 추가, 내 API에 연결하기, 필드 추가.
- [클라이언트가 막아 주는 것](doc/guides/security-model.md) — 리디렉션, 헤더 인젝션, 메모리 제한, 악의적인 숫자, 그리고 직접 처리해야 하는 부분.

## 요구 사항

| 툴체인 | 최소 버전 |
| --- | --- |
| Dart(라이브러리와 `forge`) | 3.12 |
| Flutter(생성된 앱) | 3.44 |

생성된 앱은 Riverpod 3.4, go_router 18.1, `http` 1.6을 사용합니다. 이 패키지는 Flutter 3.47과 Dart 3.13으로 개발하고 테스트하며, CI는 최신 stable Flutter를 사용합니다.

## 아키텍처

- `lib/src/network/` — `ForgeClient`는 전송 계층(transport) 주위에 interceptor 체인을 구성합니다. 먼저 사용자의 interceptor가, 그다음 `CacheInterceptor`, `RetryInterceptor`, `BearerAuthInterceptor`가 실행됩니다. 전송 계층은 리디렉션을 끈 채로 `package:http`를 통해 요청을 하나 보내고, 리디렉션은 직접 따라가며, 시간 제한은 `Abortable` 요청으로 적용하고, 본문은 바이트 제한을 두고 읽습니다. 요청과 응답은 불변(immutable) 값입니다.
- `lib/src/cli/` — `forge`는 `package:args`의 `CommandRunner`입니다. 템플릿은 Dart 문자열 상수이며, 값이 없으면 실패하는 엄격한 `{{key}}` 치환기로 렌더링됩니다. 이름은 어떤 파일에 손대기 전에 검증되고, 파일은 프로젝트 내부에만 기록됩니다.
- `example/` — `forge create`의 출력이며, `path: ..`로 이 체크아웃에 의존합니다.
- `test/` — 클라이언트 단위 테스트(중단과 스트리밍 본문을 지원하는 가짜 `http.Client` 사용), CLI 테스트(임시 폴더에서 가짜 process runner 사용), README 예제, 그리고 예제를 다시 생성해 파일 단위로 비교하는 테스트.

로컬에서 검사를 실행하세요.

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## 로드맵

- 큰 본문의 업로드 및 다운로드 진행률.
- `MemoryResponseCache`와 함께 쓸 영구 `ResponseCache`(파일 또는 SQLite).
- 더 많은 `forge` 템플릿: 새 앱을 위한 현지화와 빌드 flavor.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
