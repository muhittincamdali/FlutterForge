import 'dart:convert';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:forge_example/features/todos/data/http_todos_repository.dart';
import 'package:forge_example/features/todos/domain/todo.dart';

void main() {
  late List<http.Request> requests;

  HttpTodosRepository repositoryAnswering(int status, Object? body) {
    requests = [];
    final client = ForgeClient(
      baseUrl: 'https://api.example.com',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(jsonEncode(body), status);
      }),
      retry: RetryPolicy.none,
    );
    return HttpTodosRepository(client);
  }

  test('reads the list from /todos', () async {
    final repository = repositoryAnswering(200, [
      {'id': 1, 'title': 'First'},
      {'id': 2, 'title': 'Second'},
    ]);

    expect(await repository.fetchAll(), const [
      Todo(id: 1, title: 'First'),
      Todo(id: 2, title: 'Second'),
    ]);
    expect(requests.single.url.path, '/todos');
    expect(requests.single.url.queryParameters, {'_limit': '20'});
  });

  test('a server error becomes an HttpStatusException', () {
    final repository = repositoryAnswering(500, {'error': 'down'});
    expect(repository.fetchAll(), throwsA(isA<HttpStatusException>()));
  });

  test('an item without a title becomes a DecodingException', () {
    final repository = repositoryAnswering(200, [
      {'id': 1},
    ]);
    expect(repository.fetchAll(), throwsA(isA<DecodingException>()));
  });

  test('an object instead of a list becomes a DecodingException', () {
    final repository = repositoryAnswering(200, {'id': 1, 'title': 'x'});
    expect(repository.fetchAll(), throwsA(isA<DecodingException>()));
  });
}
