<!-- i18n-source: README.md@bd6de8e9a9d78d66fc0db6a6e9edbb03acfd83f6 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="语言版本: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

FlutterForge 在一个 Dart 包里为 Flutter 开发者提供两个工具。`ForgeClient` 是基于 [`package:http`](https://pub.dev/packages/http) 构建的 JSON-over-HTTP 客户端，支持重试、缓存、刷新 bearer token、限制耗时和响应大小，并拒绝不安全的重定向。`forge` 是一个命令行工具，用来创建 Flutter 应用，或为已有应用添加功能：生成的代码采用 feature-first 目录结构，使用 Riverpod、go_router 和上述客户端，并为每一层附带测试，因此新项目一开始的代码就能通过 `flutter analyze` 和 `flutter test`。你可以只使用客户端而不用命令行工具，生成的应用也是普通的 Flutter 代码，可以随意修改。

## 亮点

- **只需处理一种错误类型**：每个失败都是密封（sealed）的 `ApiException`，对它做 `switch` 时由编译器检查是否完整；它的 `toString` 只包含方法和主机，绝不包含路径、查询参数、请求头或请求体。
- **可以放心重复的重试**：幂等请求在连接错误、超时以及 `408`/`429`/`5xx` 之后会重试，采用带抖动的退避并遵循 `Retry-After`；`POST` 和 `PATCH` 默认不会重试，除非你要求。
- **支持离线的缓存**：`networkFirst` 在设备离线时回退到上一次的响应；`cacheFirst` 使用 `ETag` 和 `Last-Modified` 重新验证。内存缓存同时按条目数和字节数设置上限。
- **令牌只去该去的地方**：bearer token 只会发送到 API 所在的 origin，并发的 `401` 响应共用一次刷新；重定向到其他 origin 时会丢弃 `Authorization` 和 `Cookie`（Web 平台除外，那里由浏览器处理重定向）。
- **默认就有边界**：每次尝试 30 秒的时间限制，16 MiB 的响应大小限制（同时能终止无休止的响应体），取消时会关闭连接，并且请求头的值无法注入新的头部行。
- **输出经过测试的生成器**：[示例应用](example)就是 `forge create` 的原样输出；CI 会对它做分析和测试，一旦它与模板不一致，就会有测试失败。

## 快速开始

**1. 安装 `forge` 命令**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

你需要 [Flutter](https://docs.flutter.dev/install) 3.44 或更高版本，其中已包含 Dart。如果终端随后提示 `forge: command not found`，请把 Dart 打印出的文件夹（macOS 和 Linux 上是 `$HOME/.pub-cache/bin`，Windows 上是 `%LOCALAPPDATA%\Pub\Cache\bin`）加入 `PATH`，然后打开一个新的终端。

**2. 创建应用**

```sh
forge create my_app
```

该命令会运行 `flutter create` 生成 Android 和 iOS 目录，写入应用代码、测试以及用于检查它们的 GitHub Actions workflow，并运行 `flutter pub get`。添加 `--org com.yourcompany` 可设置应用 ID，添加 `--platforms ios,android,web,macos` 可支持更多平台。

**3. 运行**

```sh
cd my_app
flutter run
```

应用启动后显示一个主页，其中有一个 **Todos** 入口；点击它即可从 `jsonplaceholder.typicode.com` 加载列表。运行 `flutter test` 可以看到生成的测试通过；运行 `forge feature orders` 则会再添加一个带有自己测试的页面。

## 安装

如果只想在已有的 Flutter 或 Dart 项目中使用 HTTP 客户端，把这个包添加到 `pubspec.yaml`：

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

然后运行 `flutter pub get`（或 `dart pub get`）并导入：

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

这个包只依赖 `http`、`http_parser`、`args` 和 `path`，可运行在 Android、iOS、macOS、Windows、Linux、Web 和 Dart VM 上。它需要通过 Git 安装，因为 pub.dev 上的 `flutter_forge` 这个名称属于另一个已停止维护的包。

2.0.0 版本是一次重写：1.0.0 的源码无法编译，其中的 API 已全部移除。详情见 [CHANGELOG.md](CHANGELOG.md)。

## 使用方法

下面的每个示例也都在 [test/readme_test.dart](test/readme_test.dart) 中，该测试会针对一个模拟服务器运行它们。

### 调用 API

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

相对路径会追加到 base URL 之后。`decode` 中抛出的任何异常都会变成 `DecodingException`。

### 处理失败

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

`HttpStatusException.response` 保留了服务器随错误一起返回的响应体。

### 保留上一次的响应以便离线使用

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

在已存储的响应仍然新鲜时，使用 `CachePolicy.cacheFirst` 可以跳过请求；当已登录的用户发生变化时，请调用 `cache.clear()`。

### 发送 bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` 会保存新的令牌并返回它；如果用户需要重新登录，则返回 `null`。

### 无需服务器的测试

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

`MockClient` 来自 `package:http/testing.dart`。

### 为生成的应用添加功能

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

每条命令都会在 `lib/features/<name>/{domain,data,presentation}` 下写入文件和两个测试文件，把路由添加到 `lib/app/router.dart`，把该页面添加到主页，并格式化所修改的文件。无法通过编译的名称（例如实体会叫作 `Text` 的功能）会在写入任何内容之前被拒绝。

## 截图

示例应用运行在 iPhone 18 Pro 模拟器（iOS 27）上，数据来自 `jsonplaceholder.typicode.com` 的实时响应：

| 主页 | Todos | Todos（深色） | 离线 |
| --- | --- | --- | --- |
| ![列出 Todos 页面的主页](docs/screenshots/home.png) | ![从 API 加载的待办列表](docs/screenshots/todos.png) | ![深色外观下的待办列表](docs/screenshots/todos-dark.png) | ![带有“重试”按钮的离线提示](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) 会构建示例并截取这些截图。如果想自己运行示例：

```sh
cd example
flutter run
```

## 文档

- [API 参考与指南](https://muhittincamdali.github.io/FlutterForge/)：由 `dart doc` 生成，并从 `main` 分支发布到 GitHub Pages。
- 在本地构建：运行 `dart doc --output build/doc`，然后打开 `build/doc/index.html`。
- `forge --help`、`forge create --help` 和 `forge feature --help` 会列出所有选项。

## 指南

- [用 ForgeClient 调用 API](doc/guides/calling-an-api.md)：类型化请求、错误、重试、缓存、令牌、取消、interceptor 与测试。
- [用 forge 构建应用](doc/guides/creating-an-app.md)：创建应用、了解其目录结构、添加功能、指向你自己的 API，以及添加字段。
- [客户端防范了什么](doc/guides/security-model.md)：重定向、请求头注入、内存限制、恶意数字，以及留给你自己处理的部分。

## 系统要求

| 工具链 | 最低版本 |
| --- | --- |
| Dart（库和 `forge`） | 3.12 |
| Flutter（生成的应用） | 3.44 |

生成的应用使用 Riverpod 3.4、go_router 18.1 和 `http` 1.6。本包使用 Flutter 3.47 和 Dart 3.13 开发与测试；CI 使用最新的稳定版 Flutter。

## 架构

- `lib/src/network/`：`ForgeClient` 围绕传输层构建一条 interceptor 链：先是你自己的 interceptor，然后是 `CacheInterceptor`、`RetryInterceptor` 和 `BearerAuthInterceptor`。传输层在关闭自动重定向的情况下通过 `package:http` 发送单个请求，自行跟随重定向，用 `Abortable` 请求实施时间限制，并按字节上限读取响应体。请求和响应都是不可变的值。
- `lib/src/cli/`：`forge` 是 `package:args` 中的一个 `CommandRunner`。模板是 Dart 字符串常量，由严格的 `{{key}}` 替换器渲染，缺少值时会直接失败；名称在触碰任何文件之前就已校验，文件只会写入项目目录内部。
- `example/`：`forge create` 的输出，通过 `path: ..` 依赖当前这份检出的代码。
- `test/`：客户端的单元测试（使用支持中止和流式响应体的模拟 `http.Client`）、CLI 的测试（在临时文件夹中使用模拟的 process runner）、README 示例，以及一个重新生成示例并逐文件比较的测试。

在本地运行这些检查：

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## 路线图

- 大型请求体和响应体的上传与下载进度。
- 在 `MemoryResponseCache` 之外，提供持久化的 `ResponseCache`（基于文件或 SQLite）。
- 更多 `forge` 模板：为新应用提供本地化和 build flavor。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
