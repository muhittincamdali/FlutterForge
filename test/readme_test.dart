// The Usage section of README.md, run against a fake server. When a sample in
// the README changes, change it here too.
import 'dart:convert';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

// README: Call an API
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

// README: Handle failures
String messageFor(Object error) => switch (error) {
  ConnectionException() => 'You appear to be offline.',
  RequestTimeoutException() => 'The server took too long to answer.',
  HttpStatusException(statusCode: 404) => 'Not found.',
  HttpStatusException(:final statusCode) => 'The server answered $statusCode.',
  ApiException() => 'Something went wrong.',
  _ => 'Unexpected error: $error',
};

final class TokenStore {
  String? accessToken = 'expired';
  Future<String?> refresh() async => accessToken = 'fresh';
}

void main() {
  late List<http.Request> seen;

  http.Client server(http.Response Function(http.Request request) answer) {
    seen = [];
    return MockClient((request) async {
      seen.add(request);
      return answer(request);
    });
  }

  test('Call an API', () async {
    final fake = server((_) => http.Response(jsonEncode({'id': 1, 'title': 'delectus aut autem'}), 200));

    // README: Call an API
    final client = ForgeClient(baseUrl: 'https://jsonplaceholder.typicode.com', httpClient: fake);
    final todo = await client.getJson('/todos/1', decode: Todo.fromJson);
    print(todo.title); // delectus aut autem

    final created = await client.postJson('/todos', json: {'title': 'Ship it'}, decode: (json) => json);
    // end

    expect(todo.title, 'delectus aut autem');
    expect(created, isNotNull);
    expect(seen.last.body, '{"title":"Ship it"}');
  });

  test('Handle failures', () async {
    final client = ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: server((_) => http.Response('', 404)),
      retry: RetryPolicy.none,
    );

    // README: Handle failures
    try {
      await client.getJson('/todos/999', decode: Todo.fromJson);
    } on ApiException catch (error) {
      print(messageFor(error)); // Not found.
    }
    // end

    await expectLater(client.getJson('/todos/999', decode: Todo.fromJson), throwsA(isA<HttpStatusException>()));
    expect(messageFor(HttpStatusException(http404(client))), 'Not found.');
  });

  test('Keep the last answer for offline use', () async {
    var offline = false;
    final fake = server(
      (_) => offline
          ? throw http.ClientException('offline')
          : http.Response(
              jsonEncode([
                {'id': 1, 'title': 'Cached'},
              ]),
              200,
            ),
    );

    // README: Keep the last answer for offline use
    final cache = MemoryResponseCache(maxEntries: 200, maxBytes: 4 * 1024 * 1024);
    final client = ForgeClient(baseUrl: 'https://api.example.com', cache: cache, httpClient: fake);

    final todos = await client.getJson(
      '/todos',
      decode: Todo.listFromJson,
      cachePolicy: CachePolicy.networkFirst, // the network, or the last answer when offline
    );
    // end

    offline = true;
    final again = await client.getJson('/todos', decode: Todo.listFromJson, cachePolicy: CachePolicy.networkFirst);
    expect(todos.single.title, 'Cached');
    expect(again.single.title, 'Cached');
  });

  test('Send a bearer token', () async {
    final tokenStore = TokenStore();
    final fake = server(
      (request) => request.headers['authorization'] == 'Bearer fresh'
          ? http.Response(jsonEncode({'id': 7, 'title': 'Mine'}), 200)
          : http.Response('', 401),
    );

    // README: Send a bearer token
    final client = ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: fake,
      auth: BearerAuth(
        readToken: () => tokenStore.accessToken,
        refreshToken: tokenStore.refresh, // called once on 401, shared by parallel requests
      ),
    );
    // end

    final mine = await client.getJson('/me', decode: Todo.fromJson);
    expect(mine.title, 'Mine');
    expect(seen.map((r) => r.headers['authorization']), ['Bearer expired', 'Bearer fresh']);
  });

  test('Test without a server', () async {
    // README: Test without a server
    final client = ForgeClient(
      baseUrl: 'https://api.example.com',
      retry: RetryPolicy.none,
      httpClient: MockClient((request) async {
        expect(request.url.path, '/todos');
        return http.Response(
          jsonEncode([
            {'id': 1, 'title': 'Test'},
          ]),
          200,
        );
      }),
    );

    expect(await client.getJson('/todos', decode: Todo.listFromJson), hasLength(1));
    // end
  });
}

ForgeResponse http404(ForgeClient client) => ForgeResponse(
  statusCode: 404,
  request: ForgeRequest(method: 'GET', uri: client.resolve('/todos/999')),
);
