# Calling an API with ForgeClient

This guide builds a small repository class step by step: a client, a typed
request, error handling, retries, a cache, a bearer token and a test. Every
snippet uses the public API of `package:flutter_forge/flutter_forge.dart`.

## 1. Create one client

Create one `ForgeClient` per API and share it; it keeps the connection pool of
the underlying `http.Client`.

```dart
import 'package:flutter_forge/flutter_forge.dart';

final client = ForgeClient(baseUrl: 'https://api.example.com/v1');
```

Relative paths are appended to the base path, so `client.getJson('/todos', …)`
requests `https://api.example.com/v1/todos`. Call `client.close()` when the
client is no longer needed (in a Riverpod provider, from `ref.onDispose`).

The constructor refuses a base URL with a user name, a password, a query or a
fragment, and its error message does not repeat the URL, so a key in the URL
does not end up in a crash report.

## 2. Decode JSON into your own types

The `Json` methods take a `decode` function that receives the parsed JSON
(`Map`, `List`, `String`, `num`, `bool` or `null`):

```dart
final class Todo {
  const Todo({required this.id, required this.title});

  final int id;
  final String title;

  static Todo fromJson(Object? json) {
    if (json case {'id': final int id, 'title': final String title}) {
      return Todo(id: id, title: title);
    }
    throw const FormatException('Not a todo');
  }

  static List<Todo> listFromJson(Object? json) =>
      [for (final item in json! as List<Object?>) fromJson(item)];
}

final todos = await client.getJson('/todos', decode: Todo.listFromJson);
final created = await client.postJson(
  '/todos',
  json: {'title': 'Write the guide'},
  decode: Todo.fromJson,
);
```

Anything the decoder throws — a failed cast, a `FormatException`, a missing
key — becomes a `DecodingException`, so the caller handles one error type.

## 3. Handle errors with a switch

Every failure is an `ApiException`, a sealed class. A `switch` over it is
checked by the compiler:

```dart
String describe(ApiException error) => switch (error) {
      ConnectionException() => 'No connection.',
      RequestTimeoutException() => 'The server took too long.',
      RequestCancelledException() => 'Cancelled.',
      HttpStatusException(statusCode: 404) => 'Not found.',
      HttpStatusException(:final statusCode) => 'Server answered $statusCode.',
      DecodingException() => 'Unexpected data.',
      ResponseTooLargeException() => 'The answer was too large.',
      RedirectException() => 'Unsafe redirect.',
    };
```

`error.isTransient` tells whether sending the request again may help
(connection errors, timeouts, `408`, `429` and `5xx`).

`HttpStatusException.response` holds the full answer, including the body the
server sent with the error:

```dart
try {
  await client.postJson('/login', json: credentials, decode: Session.fromJson);
} on HttpStatusException catch (error) {
  final problem = error.response.json();
}
```

## 4. Tune retries

The client retries idempotent requests (`GET`, `HEAD`, `PUT`, `DELETE`,
`OPTIONS`) up to two more times after a connection error, a timeout, or a
`408`, `429`, `500`, `502`, `503` or `504` answer. The wait doubles from
300 ms, never exceeds 10 s, and is spread between half and all of that value so
clients that failed together do not retry together. A `Retry-After` header on
`429` and `503` sets the wait; when it asks for longer than `maxDelay`, the
answer is returned instead.

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  retry: const RetryPolicy(
    maxAttempts: 5,
    baseDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 5),
  ),
);

// Or turn retries off:
final once = ForgeClient(baseUrl: 'https://api.example.com', retry: RetryPolicy.none);
```

`POST` and `PATCH` are not repeated unless you set `retryNonIdempotent: true`,
because the server may already have acted on the first attempt.

## 5. Cache responses

Pass a `ResponseCache` to the client and choose a `CachePolicy` per request:

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  cache: MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024),
);

// Fresh copy without a request; once stale, revalidated with ETag / Last-Modified.
final profile = await client.getJson(
  '/me',
  decode: Profile.fromJson,
  cachePolicy: CachePolicy.cacheFirst,
);

// Always ask the network, but show the last answer when offline.
final feed = await client.getJson(
  '/feed',
  decode: Post.listFromJson,
  cachePolicy: CachePolicy.networkFirst,
);
```

`ForgeResponse.fromCache` tells which answer you got. The cache keeps only
`200` answers to `GET`, never stores `Cache-Control: no-store`, and keys
entries by URL, so clear it when the signed-in user changes:

```dart
final cache = MemoryResponseCache();
// …
cache.clear();
```

## 6. Send a bearer token

```dart
final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  auth: BearerAuth(
    readToken: () => tokenStore.accessToken,
    refreshToken: () async {
      final fresh = await authApi.refresh(tokenStore.refreshToken);
      tokenStore.accessToken = fresh; // store it before returning it
      return fresh;
    },
  ),
);
```

The token goes only to the origin of the base URL. On a `401` the client calls
`refreshToken` once — concurrent requests share that call — and sends the
request again with the new token. Return `null` from `refreshToken` when the
user has to sign in again; the caller then receives the `401`.

## 7. Cancel and limit

```dart
final token = CancelToken();
final search = client.getJson(
  '/search',
  query: {'q': text},
  decode: Result.listFromJson,
  cancelToken: token,
  timeout: const Duration(seconds: 5),
);
// When the user types again:
token.cancel();
```

Each attempt has a time limit (`timeout`, 30 s by default) that covers the
whole exchange, from sending to the last byte of the body. Bodies longer than
`maxResponseBytes` (16 MiB by default) fail with `ResponseTooLargeException`
without being read to the end.

## 8. Add your own interceptor

An interceptor sees every request on its way out and every response on its
way back:

```dart
final versionHeader = Interceptor.from(
  (request, next) => next(request.withHeaders(add: {'x-app-version': '4.2.0'})),
);

final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  interceptors: [versionHeader],
);
```

Your interceptors run outside the cache, the retry policy and the token, so
they see the final answer once, not every attempt.

## 9. Test without a server

Pass a `MockClient` from `package:http/testing.dart`:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final client = ForgeClient(
  baseUrl: 'https://api.example.com',
  retry: RetryPolicy.none,
  httpClient: MockClient((request) async {
    expect(request.url.path, '/todos');
    return http.Response(jsonEncode([{'id': 1, 'title': 'Test'}]), 200);
  }),
);
```

A client you pass in is not closed by `ForgeClient.close`, so one mock can serve
several clients.

## 10. Use a platform HTTP stack

`ForgeClient` works with any `package:http` client. To use the system network
stacks, which respect VPN and proxy settings, pass `CupertinoClient` from
[cupertino_http](https://pub.dev/packages/cupertino_http) on iOS and macOS or
`CronetClient` from [cronet_http](https://pub.dev/packages/cronet_http) on
Android as `httpClient`.
