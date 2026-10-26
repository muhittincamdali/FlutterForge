<!-- i18n-source: README.md@bd6de8e9a9d78d66fc0db6a6e9edbb03acfd83f6 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/banner-light.svg" alt="FlutterForge: An HTTP client and an app generator for Flutter: retries, caching, tokens and a tested feature-first layout."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/FlutterForge/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/FlutterForge/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/pubspec.yaml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Dart 3.12+"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/FlutterForge/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/FlutterForge/tree/main/example"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/FlutterForge/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

FlutterForge は、Flutter 開発者向けの 2 つのツールを 1 つの Dart パッケージにまとめたものです。`ForgeClient` は [`package:http`](https://pub.dev/packages/http) をベースにした JSON-over-HTTP クライアントで、リトライ、キャッシュ、bearer token の更新、時間とレスポンスサイズの制限を行い、安全でないリダイレクトを拒否します。`forge` は Flutter アプリを作成する（または既存のアプリに機能を追加する）コマンドで、feature-first の構成、Riverpod、go_router、このクライアント、そして各レイヤーのテストを備えたコードを生成します。そのため、新しいプロジェクトは最初から `flutter analyze` と `flutter test` に通るコードで始まります。コマンドを使わずにクライアントだけを使うこともでき、生成されたアプリは自由に変更できる通常の Flutter コードです。

## 主な特長

- **処理するエラーの型は 1 つ** — すべての失敗は sealed な `ApiException` になるため、それに対する `switch` はコンパイラが網羅性を検査します。`toString` に含まれるのはメソッドとホストだけで、パス、クエリ、ヘッダー、ボディは含まれません。
- **繰り返しても安全なリトライ** — べき等なリクエストは、接続エラー、タイムアウト、`408`/`429`/`5xx` の後に、ジッター付きのバックオフと `Retry-After` に従って再試行されます。`POST` と `PATCH` は、指定しない限り再試行されません。
- **オフラインでも使えるキャッシュ** — `networkFirst` は端末がオフラインのときに直近のレスポンスへフォールバックし、`cacheFirst` は `ETag` と `Last-Modified` で再検証します。メモリキャッシュはエントリ数とバイト数の両方で上限が設けられています。
- **トークンは本来の場所にだけ送られる** — bearer token は API の origin にだけ送られ、同時に発生した `401` は 1 回の更新を共有し、別の origin へのリダイレクトでは `Authorization` と `Cookie` が破棄されます（Web を除きます。Web ではブラウザーがリダイレクトを処理します）。
- **デフォルトで上限あり** — 1 回の試行あたり 30 秒の時間制限、終わりのないボディも止める 16 MiB のレスポンス上限、接続を閉じるキャンセル、新しいヘッダー行を注入できないヘッダー値。
- **出力がテストされるジェネレーター** — [サンプルアプリ](example)は `forge create` の出力そのものです。CI がこれを解析・テストし、テンプレートからずれるとテストが失敗します。

## クイックスタート

**1. `forge` コマンドをインストールします**

```sh
dart pub global activate --source git https://github.com/muhittincamdali/FlutterForge.git --git-ref v2.0.0
```

[Flutter](https://docs.flutter.dev/install) 3.44 以降が必要です（Dart は Flutter に含まれています）。その後ターミナルで `forge: command not found` と表示された場合は、Dart が表示したフォルダー（macOS と Linux では `$HOME/.pub-cache/bin`、Windows では `%LOCALAPPDATA%\Pub\Cache\bin`）を `PATH` に追加し、新しいターミナルを開いてください。

**2. アプリを作成します**

```sh
forge create my_app
```

このコマンドは、Android と iOS のフォルダーのために `flutter create` を実行し、アプリ本体、そのテスト、テストを実行する GitHub Actions workflow を書き出し、`flutter pub get` を実行します。アプリ ID を設定するには `--org com.yourcompany` を、他のプラットフォームを加えるには `--platforms ios,android,web,macos` を追加してください。

**3. 実行します**

```sh
cd my_app
flutter run
```

アプリはホーム画面で起動し、**Todos** という項目が表示されます。タップすると `jsonplaceholder.typicode.com` からリストを読み込みます。`flutter test` を実行すると生成されたテストが通ることを確認でき、`forge feature orders` を実行すると、専用のテスト付きの 2 つ目の画面を追加できます。

## インストール

既存の Flutter または Dart プロジェクトで HTTP クライアントだけを使うには、パッケージを `pubspec.yaml` に追加します。

```yaml
dependencies:
  flutter_forge:
    git:
      url: https://github.com/muhittincamdali/FlutterForge.git
      ref: v2.0.0
```

その後 `flutter pub get`（または `dart pub get`）を実行して、インポートします。

```dart
import 'package:flutter_forge/flutter_forge.dart';
```

このパッケージが依存しているのは `http`、`http_parser`、`args`、`path` だけで、Android、iOS、macOS、Windows、Linux、Web、Dart VM で動作します。pub.dev の `flutter_forge` という名前は、開発が終了した別のパッケージのものなので、Git からインストールします。

バージョン 2.0.0 は書き直しです。1.0.0 のソースはコンパイルできず、その API は現在まったく残っていません。詳細は [CHANGELOG.md](CHANGELOG.md) を参照してください。

## 使い方

以下のサンプルはすべて [test/readme_test.dart](test/readme_test.dart) にも含まれており、このテストがダミーのサーバーに対して実行します。

### API を呼び出す

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

相対パスはベース URL の後ろに追加されます。`decode` が throw したものはすべて `DecodingException` になります。

### 失敗を処理する

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

`HttpStatusException.response` は、サーバーがエラーと一緒に返したボディを保持します。

### 直近のレスポンスをオフライン用に保持する

```dart
final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache);

final todos = await client.getJson(
  '/todos',
  decode: Todo.listFromJson,
  cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
);
```

保存済みのレスポンスが新しい間はリクエストを省略したい場合は `CachePolicy.cacheFirst` を使い、サインインしているユーザーが変わったら `cache.clear()` を呼び出してください。

### bearer token を送信する

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
  ),
);
```

`refresh` は新しいトークンを保存して返します。ユーザーが再度サインインする必要がある場合は `null` を返します。

### サーバーなしでテストする

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

`MockClient` は `package:http/testing.dart` に含まれています。

### 生成したアプリに機能を追加する

```sh
forge feature orders                                   # Order, GET /orders
forge feature order_items --api-path /v2/order-items   # OrderItem
forge feature news --entity Article                    # when the singular is not obvious
```

各コマンドは `lib/features/<name>/{domain,data,presentation}` にファイルと 2 つのテストファイルを書き出し、`lib/app/router.dart` にルートを、ホーム画面に画面を追加して、変更したファイルをフォーマットします。エンティティ名が `Text` になる機能のように、コンパイルできない名前は、何も書き込まれる前に拒否されます。

## スクリーンショット

iPhone 18 Pro シミュレーター（iOS 27）上のサンプルアプリです。データは `jsonplaceholder.typicode.com` のライブデータです。

| ホーム | Todos | Todos（ダーク） | オフライン |
| --- | --- | --- | --- |
| ![Todos 画面が一覧に表示されたホーム画面](docs/screenshots/home.png) | ![API から読み込んだ Todo の一覧](docs/screenshots/todos.png) | ![ダークモードでの Todo の一覧](docs/screenshots/todos-dark.png) | ![再試行ボタン付きのオフライン時のメッセージ](docs/screenshots/offline.png) |

[`scripts/screenshots.sh`](scripts/screenshots.sh) は、サンプルをビルドしてこれらのスクリーンショットを撮影します。サンプルを自分で実行するには次のようにします。

```sh
cd example
flutter run
```

## ドキュメント

- [API リファレンスとガイド](https://muhittincamdali.github.io/FlutterForge/) — `dart doc` で生成し、`main` から GitHub Pages に公開しています。
- ローカルでビルドするには、`dart doc --output build/doc` を実行して `build/doc/index.html` を開きます。
- `forge --help`、`forge create --help`、`forge feature --help` で、すべてのオプションを確認できます。

## ガイド

- [ForgeClient で API を呼び出す](doc/guides/calling-an-api.md) — 型付きリクエスト、エラー、リトライ、キャッシュ、トークン、キャンセル、interceptor、テスト。
- [forge でアプリを作る](doc/guides/creating-an-app.md) — アプリの作成、構成の読み方、機能の追加、自分の API への接続、フィールドの追加。
- [クライアントが防ぐもの](doc/guides/security-model.md) — リダイレクト、ヘッダーインジェクション、メモリ制限、悪意のある数値、そしてあなたに任されている部分。

## 動作要件

| ツールチェーン | 最小バージョン |
| --- | --- |
| Dart（ライブラリと `forge`） | 3.12 |
| Flutter（生成されるアプリ） | 3.44 |

生成されるアプリは Riverpod 3.4、go_router 18.1、`http` 1.6 を使用します。このパッケージは Flutter 3.47 と Dart 3.13 で開発・テストされており、CI では最新の stable の Flutter を使います。

## アーキテクチャ

- `lib/src/network/` — `ForgeClient` は、トランスポートの周りに interceptor のチェーンを組み立てます。順に、あなたの interceptor、`CacheInterceptor`、`RetryInterceptor`、`BearerAuthInterceptor` です。トランスポートはリダイレクトを無効にした状態で `package:http` を通じて 1 つのリクエストを送り、リダイレクトは自分で追跡し、時間制限は `Abortable` なリクエストで実施し、ボディはバイト数の上限付きで読み取ります。リクエストとレスポンスはイミュータブルな値です。
- `lib/src/cli/` — `forge` は `package:args` の `CommandRunner` です。テンプレートは Dart の文字列定数で、値が欠けていると失敗する厳格な `{{key}}` 置換で描画されます。名前はファイルに触れる前に検証され、ファイルはプロジェクトの内側にのみ書き込まれます。
- `example/` — `forge create` の出力で、`path: ..` によってこのチェックアウトに依存しています。
- `test/` — クライアントの単体テスト（中断とストリーミングボディに対応したダミーの `http.Client` を使用）、CLI のテスト（一時フォルダー内のダミーの process runner を使用）、README のサンプル、そしてサンプルを再生成してファイルごとに比較するテストです。

チェックをローカルで実行します。

```sh
dart analyze && dart test
cd example && flutter analyze && flutter test
```

## ロードマップ

- 大きなボディのアップロードとダウンロードの進捗。
- `MemoryResponseCache` に加えて、永続的な `ResponseCache`（ファイルまたは SQLite）。
- `forge` のテンプレートの追加：新しいアプリ向けのローカライズとビルド flavor。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/FlutterForge/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
