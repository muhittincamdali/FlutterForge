import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../support/fake_http.dart';

final class Todo {
  Todo(this.id, this.title);

  factory Todo.fromJson(Object? json) {
    final map = json! as Map<String, Object?>;
    return Todo(map['id']! as int, map['title']! as String);
  }

  final int id;
  final String title;
}

void main() {
  ForgeClient clientFor(FakeHttp fake, {Duration? timeout, int? maxResponseBytes, int maxRedirects = 5}) => ForgeClient(
    baseUrl: 'https://api.example.com/v1',
    httpClient: fake,
    retry: RetryPolicy.none,
    timeout: timeout ?? const Duration(seconds: 5),
    maxResponseBytes: maxResponseBytes ?? 1024 * 1024,
    maxRedirects: maxRedirects,
  );

  group('construction', () {
    test('rejects base URLs it cannot use', () {
      for (final url in [
        'api.example.com',
        'ftp://example.com',
        'https://example.com/?a=1',
        'https://example.com/#x',
        '::',
      ]) {
        expect(() => ForgeClient(baseUrl: url), throwsArgumentError, reason: url);
      }
    });

    test('does not repeat a password from the base URL in its error', () {
      try {
        ForgeClient(baseUrl: 'https://admin:hunter2@example.com');
        fail('expected an ArgumentError');
      } on ArgumentError catch (error) {
        expect(error.toString(), isNot(contains('hunter2')));
      }
    });

    test('rejects limits outside their range', () {
      expect(() => ForgeClient(baseUrl: 'https://a.example', timeout: Duration.zero), throwsArgumentError);
      expect(() => ForgeClient(baseUrl: 'https://a.example', maxResponseBytes: 0), throwsArgumentError);
      expect(() => ForgeClient(baseUrl: 'https://a.example', maxRedirects: -1), throwsArgumentError);
      expect(() => ForgeClient(baseUrl: 'https://a.example', maxRedirects: 21), throwsArgumentError);
    });

    test('checks the default headers once, when the client is created', () {
      expect(() => ForgeClient(baseUrl: 'https://a.example', headers: {'x-key': 'a\r\nb'}), throwsArgumentError);
    });
  });

  group('resolve', () {
    final client = ForgeClient(baseUrl: 'https://api.example.com/v1/');

    test('appends relative paths to the base path', () {
      expect(client.resolve('/todos').toString(), 'https://api.example.com/v1/todos');
      expect(client.resolve('todos/7').toString(), 'https://api.example.com/v1/todos/7');
    });

    test('refuses dot segments that would leave the base path', () {
      for (final path in [
        '/../admin',
        'files/../../admin',
        '/a/./b',
        '/%2e%2e/admin',
        '/files/%2E%2E',
        '..',
        '/x/..?q=1',
        r'..\admin',
        r'/files/..\..\admin',
        r'/a/.\b',
        '/..;/admin',
        '/a/..;jsessionid=1/b',
        '/a/..%3Bx/b',
        '/..%2fadmin',
        '/..%2Fadmin',
        '/..%5cadmin',
        '/%2e%2e%5Cadmin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/..hidden').path, '/v1/files/..hidden');
      expect(client.resolve('/a?next=../b').queryParameters, {'next': '../b'});
    });

    test('refuses dot segments that a server decoding twice or trimming names would see', () {
      for (final path in [
        '%252e%252e/admin',
        '/%25252E%25252E/admin',
        '/..%252fadmin',
        '..%00/admin',
        '/..\u0000/admin',
        '.. /admin',
        '/..%20/admin',
        '\t../admin',
        '/..%09/admin',
        '．．/admin',
        '/%EF%BC%8E%EF%BC%8E/admin',
        '/﹒﹒/admin',
        '... /admin',
        '/.../admin',
        '/..%0a/admin',
        '/..%0D/admin',
        '/..%0b/admin',
        '/..%1f/admin',
        '/..%7f/admin',
        '/..\n/admin',
        '/..%c2%a0/admin',
        '/.. /admin',
        '/%c0%ae%c0%ae/admin',
        '/%C0%AE./admin',
        '/%e0%80%ae%e0%80%ae/admin',
        '/%u002e%u002e/admin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/100%25').path, '/v1/files/100%25');
      expect(client.resolve('/files/a%20b').path, '/v1/files/a%20b');
      expect(client.resolve('/files/..%20notes').path, '/v1/files/..%20notes');
      expect(client.resolve('/files/a%0Ab').path, '/v1/files/a%0Ab');
      expect(client.resolve('/files/caf%C3%A9').path, '/v1/files/caf%C3%A9');
    });

    test('refuses dot segments split at a slash that a server decodes or maps to / or \\', () {
      for (final path in [
        '..%c0%afadmin',
        '/..%C0%AFadmin',
        '..%e0%80%afadmin',
        '/..%c1%9cadmin',
        '/..%E0%81%9Cadmin',
        '..%u002fadmin',
        '..%25u002fadmin',
        '/..%U005Cadmin',
        '..%u2215admin',
        '/..∕admin',
        '/..%e2%88%95admin',
        '/..∖admin',
        '/..%e2%88%96admin',
        '..／admin',
        '..＼admin',
        '/..%ef%bc%8fadmin',
        '/..%EF%BC%BCadmin',
        '/..%uff0fadmin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/1／2').path, '/v1/files/1%EF%BC%8F2');
      expect(client.resolve('/files/a%c0%afb').path, '/v1/files/a%C0%AFb');
    });

    test('refuses dot segments ended by an encoded ? or # or hidden by invisible characters', () {
      for (final path in [
        '..%3f/admin',
        '/..%3F/admin',
        '/..%3fx=1/admin',
        '/..%23/admin',
        '/..%253f/admin',
        '/..%c2%ad/admin',
        '/..­/admin',
        '/..%e2%80%8b/admin',
        '/.​./admin',
        '/..%E2%80%8D/admin',
        '/..%e2%81%a0/admin',
        '/..%ef%bb%bf/admin',
        '/﻿../admin',
        '/..%u00ad/admin',
        '/..%u200b/admin',
        '/..%u0000/admin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/a%3Fb').path, '/v1/files/a%3Fb');
      expect(client.resolve('/files/%3F').path, '/v1/files/%3F');
      expect(client.resolve('/files/co%C2%ADop').path, '/v1/files/co%C2%ADop');
    });

    test('refuses a two-dot leader or an ellipsis, which normalisation turns into dots', () {
      for (final path in [
        '‥/admin',
        '/files/‥',
        '/%e2%80%a5/admin',
        '/%u2025/admin',
        '/…/admin',
        '/%E2%80%A6/admin',
        '/.‥/admin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/‥notes').path, '/v1/files/%E2%80%A5notes');
    });

    test('refuses a path that becomes a dot segment when Uri.parse rewrites its escapes', () {
      // Uri.parse decodes `%32` and `%65` and encodes a `%` that starts no
      // escape, so each of these would be sent with `%252e` or `%252f`.
      for (final path in [
        '%25%32%65%25%32%65/admin',
        '/%2%65%2%65/admin',
        '%2e%2e%25%32%66admin',
        '/files/%25%32%65',
        '/%2%45%2%45/admin',
      ]) {
        expect(() => client.resolve(path), throwsArgumentError, reason: path);
      }
      expect(client.resolve('/files/%32%65').path, '/v1/files/2e');
      expect(client.resolve('/files/%2%41').path, '/v1/files/%252A');
    });

    test('reads a deeply nested %25 in time linear in the path length', () {
      // 320 KB of `%2525…252e`: a check that replaced `%25` until none was
      // left took minutes on such a path.
      final nested = '%${'25' * 160000}2e';
      final stopwatch = Stopwatch()..start();
      expect(() => client.resolve('/$nested/admin'), throwsArgumentError);
      expect(client.resolve('/files/${'%25' * 100000}').path, startsWith('/v1/files/%25%25'));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('keeps an encoded slash that is not part of a dot segment', () {
      expect(client.resolve('/files/a%2Fb').path, '/v1/files/a%2Fb');
      expect(client.resolve('/files/a;v=1').path, '/v1/files/a;v=1');
    });

    test('sends nothing, and no token, for a path that climbs out', () async {
      final fake = FakeHttp((_) => reply(200, json: {}));
      final client = ForgeClient(
        baseUrl: 'https://api.example.com/v1',
        httpClient: fake,
        retry: RetryPolicy.none,
        auth: BearerAuth(readToken: () => 'secret'),
      );
      for (final path in [r'..\admin', '..;/admin', '..%2fadmin']) {
        await expectLater(client.getJson(path, decode: (json) => json), throwsArgumentError, reason: path);
      }
      expect(fake.requests, isEmpty);
    });

    test('keeps a protocol-relative path on the base host and drops fragments', () {
      expect(client.resolve('//evil.example/x').host, 'api.example.com');
      expect(client.resolve('/a#section').hasFragment, isFalse);
    });

    test('uses an absolute URL as it is', () {
      expect(client.resolve('https://cdn.example.net/a.png').toString(), 'https://cdn.example.net/a.png');
    });

    test('refuses an absolute URL with user information without repeating it', () {
      try {
        client.resolve('https://alice:hunter2@evil.example');
        fail('expected an ArgumentError');
      } on ArgumentError catch (error) {
        expect(error.toString(), isNot(contains('hunter2')));
      }
    });

    test('adds query values, skips null and repeats iterables', () {
      final uri = client.resolve('/search?sort=asc', {
        'q': 'a b',
        'page': 2,
        'tag': ['x', 'y'],
        'skip': null,
      });
      expect(uri.queryParametersAll, {
        'sort': ['asc'],
        'q': ['a b'],
        'page': ['2'],
        'tag': ['x', 'y'],
      });
    });
  });

  group('JSON calls', () {
    test('getJson sends the default headers and decodes the body', () async {
      final fake = FakeHttp((_) => reply(200, json: {'id': 1, 'title': 'Write tests'}));
      final todo = await clientFor(fake).getJson('/todos/1', decode: Todo.fromJson);
      expect(todo.title, 'Write tests');
      expect(fake.requests.single.method, 'GET');
      expect(fake.requests.single.url.toString(), 'https://api.example.com/v1/todos/1');
      expect(fake.requests.single.headers['accept'], 'application/json');
    });

    test('postJson encodes the body as UTF-8 JSON', () async {
      final fake = FakeHttp((_) => reply(201, json: {'id': 2, 'title': 'Çay'}));
      final todo = await clientFor(fake).postJson('/todos', json: {'title': 'Çay'}, decode: Todo.fromJson);
      expect(todo.id, 2);
      final seen = fake.requests.single;
      expect(seen.method, 'POST');
      expect(seen.headers['content-type'], 'application/json; charset=utf-8');
      expect(seen.text, '{"title":"Çay"}');
    });

    test('put, patch and delete use their methods', () async {
      final fake = FakeHttp((_) => reply(200, json: {'id': 3, 'title': 't'}));
      final client = clientFor(fake);
      await client.putJson('/todos/3', json: {'title': 't'}, decode: Todo.fromJson);
      await client.patchJson('/todos/3', json: {'title': 't'}, decode: Todo.fromJson);
      await client.delete('/todos/3');
      expect(fake.requests.map((r) => r.method), ['PUT', 'PATCH', 'DELETE']);
    });

    test('a status outside 2xx throws HttpStatusException with the response', () async {
      final fake = FakeHttp((_) => reply(404, json: {'error': 'missing'}));
      final error = await clientFor(
        fake,
      ).getJson('/todos/9?token=s3cr3t', decode: Todo.fromJson).then<Object?>((_) => null, onError: (Object e) => e);
      expect(error, isA<HttpStatusException>());
      final status = error! as HttpStatusException;
      expect(status.statusCode, 404);
      expect(status.response.json(), {'error': 'missing'});
      expect(status.isTransient, isFalse);
      expect(status.toString(), 'HttpStatusException: GET https://api.example.com answered 404');
    });

    test('the message of a failed call to an odd host does not repeat the host', () async {
      final fake = FakeHttp((_) => reply(500));
      await expectLater(
        clientFor(fake).request('GET', 'https://h.example;password=hunter2/db'),
        throwsA(
          isA<HttpStatusException>().having(
            (e) => e.toString(),
            'toString',
            'HttpStatusException: GET https://[R] answered 500',
          ),
        ),
      );
    });

    test('a decoder that throws becomes a DecodingException', () async {
      final fake = FakeHttp((_) => reply(200, json: {'id': 'not a number', 'title': 't'}));
      expect(clientFor(fake).getJson('/todos/1', decode: Todo.fromJson), throwsA(isA<DecodingException>()));
    });

    test('a body that is not JSON becomes a DecodingException', () async {
      final fake = FakeHttp((_) => reply(200, text: '<html>'));
      expect(clientFor(fake).getJson('/todos/1', decode: Todo.fromJson), throwsA(isA<DecodingException>()));
    });

    test('json and body together are rejected', () {
      final client = clientFor(FakeHttp((_) => reply(200)));
      expect(() => client.request('POST', '/x', json: 1, body: Uint8List(1)), throwsArgumentError);
    });

    test('send returns error statuses without throwing', () async {
      final fake = FakeHttp((_) => reply(500, text: 'oops'));
      final client = clientFor(fake);
      final response = await client.send(ForgeRequest(method: 'GET', uri: client.resolve('/x')));
      expect(response.statusCode, 500);
      expect(response.text, 'oops');
    });
  });

  group('form and multipart bodies', () {
    test('postForm sends URL-encoded fields', () async {
      final fake = FakeHttp((_) => reply(200, json: {'access_token': 'x'}));
      final token = await clientFor(fake).postForm(
        '/oauth/token',
        fields: {'grant_type': 'password', 'username': 'ayşe yılmaz', 'scope': 'a&b=c'},
        decode: (json) => (json! as Map<String, Object?>)['access_token'],
      );
      expect(token, 'x');
      final seen = fake.requests.single;
      expect(seen.headers['content-type'], startsWith('application/x-www-form-urlencoded'));
      expect(Uri.splitQueryString(seen.text), {'grant_type': 'password', 'username': 'ayşe yılmaz', 'scope': 'a&b=c'});
    });

    test('postMultipart sends fields and files with a boundary', () async {
      final fake = FakeHttp((_) => reply(201, json: {'id': 9}));
      await clientFor(fake).postMultipart(
        '/uploads',
        fields: {'caption': 'Sunset'},
        files: [
          MultipartFile.fromBytes('file', [0x89, 0x50, 0x4e, 0x47], filename: 'sunset.png'),
        ],
        decode: (json) => json,
      );
      final seen = fake.requests.single;
      final contentType = seen.headers['content-type']!;
      expect(contentType, startsWith('multipart/form-data; boundary='));
      final boundary = contentType.split('boundary=').last;
      final body = String.fromCharCodes(seen.body);
      expect(body, contains('--$boundary\r\n'));
      expect(body, contains('content-disposition: form-data; name="caption"\r\n\r\nSunset\r\n'));
      expect(body, contains('content-disposition: form-data; name="file"; filename="sunset.png"'));
      expect(body, endsWith('--$boundary--\r\n'));
    });

    test('a retried multipart request sends the same bytes again', () async {
      var calls = 0;
      final fake = FakeHttp((_) => ++calls == 1 ? reply(503) : reply(200, json: 1));
      final client = ForgeClient(
        baseUrl: 'https://api.example.com',
        httpClient: fake,
        retry: const RetryPolicy(retryNonIdempotent: true, baseDelay: Duration(milliseconds: 1)),
      );
      await client.postMultipart(
        '/uploads',
        files: [MultipartFile.fromString('file', 'hello', filename: 'a.txt')],
        decode: (json) => json,
      );
      expect(fake.requests, hasLength(2));
      expect(fake.requests[1].body, fake.requests[0].body);
    });
  });

  group('transport failures', () {
    test('a client exception becomes a ConnectionException', () async {
      final fake = FakeHttp((_) => throw http.ClientException('connection refused'));
      final future = clientFor(fake).getJson('/x', decode: (json) => json);
      await expectLater(
        future,
        throwsA(isA<ConnectionException>().having((e) => e.isTransient, 'isTransient', isTrue)),
      );
    });

    test('a response that never arrives times out and aborts the request', () async {
      final fake = FakeHttp((_) => never());
      final watch = Stopwatch()..start();
      await expectLater(
        clientFor(fake, timeout: const Duration(milliseconds: 50)).getJson('/x', decode: (json) => json),
        throwsA(isA<RequestTimeoutException>()),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      await Future<void>.delayed(Duration.zero);
      expect(fake.aborted, 1);
    });

    test('a per-request timeout overrides the client default', () async {
      final fake = FakeHttp((_) => never());
      final client = clientFor(fake, timeout: const Duration(minutes: 1));
      await expectLater(
        client.getJson('/x', decode: (json) => json, timeout: const Duration(milliseconds: 20)),
        throwsA(isA<RequestTimeoutException>().having((e) => e.timeout, 'timeout', const Duration(milliseconds: 20))),
      );
    });

    test('cancelling before sending throws without touching the network', () async {
      final fake = FakeHttp((_) => reply(200));
      final token = CancelToken()..cancel();
      await expectLater(
        clientFor(fake).getJson('/x', decode: (json) => json, cancelToken: token),
        throwsA(isA<RequestCancelledException>()),
      );
      expect(fake.requests, isEmpty);
    });

    test('cancelling while waiting aborts the request', () async {
      final fake = FakeHttp((_) => never());
      final token = CancelToken();
      final future = clientFor(fake).getJson('/x', decode: (json) => json, cancelToken: token);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      token.cancel();
      await expectLater(future, throwsA(isA<RequestCancelledException>()));
      await Future<void>.delayed(Duration.zero);
      expect(fake.aborted, 1);
    });

    test('cancelling a token after the request finished has no effect', () async {
      final token = CancelToken();
      final value = await clientFor(
        FakeHttp((_) => reply(200, json: 1)),
      ).getJson('/x', decode: (json) => json, cancelToken: token);
      token.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(value, 1);
    });
  });

  group('response size limit', () {
    test('a declared length over the limit is refused before reading', () async {
      final fake = FakeHttp((_) => reply(200, text: 'x' * 2048));
      await expectLater(
        clientFor(fake, maxResponseBytes: 1024).getJson('/x', decode: (json) => json),
        throwsA(isA<ResponseTooLargeException>().having((e) => e.limit, 'limit', 1024)),
      );
    });

    test('an endless body without a length stops at the limit', () async {
      final fake = FakeHttp((_) => endless());
      await expectLater(
        clientFor(
          fake,
          maxResponseBytes: 512 * 1024,
        ).send(ForgeRequest(method: 'GET', uri: Uri.parse('https://api.example.com/v1/stream'))),
        throwsA(isA<ResponseTooLargeException>()),
      );
    });

    test('a body of exactly the limit is accepted', () async {
      final fake = FakeHttp((_) => reply(200, text: 'x' * 1024));
      final response = await clientFor(fake, maxResponseBytes: 1024).request('GET', '/x');
      expect(response.bodyBytes.length, 1024);
    });
  });

  group('redirects', () {
    test('follows a same-origin redirect and keeps credentials', () async {
      final fake = FakeHttp(
        (r) => r.url.path == '/v1/old' ? reply(301, headers: {'location': '/v1/new'}) : reply(200, json: 'ok'),
      );
      final client = clientFor(fake);
      final value = await client.getJson('/old', decode: (json) => json, headers: {'authorization': 'Bearer t'});
      expect(value, 'ok');
      expect(fake.requests.last.url.path, '/v1/new');
      expect(fake.requests.last.headers['authorization'], 'Bearer t');
    });

    test('drops credentials when the redirect leaves the origin', () async {
      final fake = FakeHttp(
        (r) => r.url.host == 'api.example.com'
            ? reply(302, headers: {'location': 'https://cdn.example.net/file'})
            : reply(200, json: 'ok'),
      );
      await clientFor(
        fake,
      ).request('GET', '/file', headers: {'authorization': 'Bearer t', 'cookie': 'sid=1', 'x-trace': 'keep'});
      final last = fake.requests.last.headers;
      expect(last.containsKey('authorization'), isFalse);
      expect(last.containsKey('cookie'), isFalse);
      expect(last['x-trace'], 'keep');
    });

    test('refuses a redirect from https to http', () async {
      final fake = FakeHttp((_) => reply(302, headers: {'location': 'http://api.example.com/v1/x'}));
      await expectLater(clientFor(fake).request('GET', '/x'), throwsA(isA<RedirectException>()));
      expect(fake.requests, hasLength(1));
    });

    test('refuses a redirect to a scheme other than http or https', () async {
      for (final location in ['javascript:alert(1)', 'file:///etc/passwd', 'ftp://example.com/']) {
        final fake = FakeHttp((_) => reply(302, headers: {'location': location}));
        await expectLater(clientFor(fake).request('GET', '/x'), throwsA(isA<RedirectException>()), reason: location);
      }
    });

    test('refuses a redirect target with user information', () async {
      final fake = FakeHttp((_) => reply(302, headers: {'location': 'https://user:pw@api.example.com/'}));
      await expectLater(clientFor(fake).request('GET', '/x'), throwsA(isA<RedirectException>()));
    });

    test('stops after maxRedirects', () async {
      final fake = FakeHttp((_) => reply(302, headers: {'location': '/v1/loop'}));
      await expectLater(clientFor(fake, maxRedirects: 3).request('GET', '/loop'), throwsA(isA<RedirectException>()));
      expect(fake.requests, hasLength(4));
    });

    test('maxRedirects 0 returns the redirect response', () async {
      final fake = FakeHttp((_) => reply(302, headers: {'location': '/v1/next'}));
      final client = clientFor(fake, maxRedirects: 0);
      final response = await client.send(ForgeRequest(method: 'GET', uri: client.resolve('/x')));
      expect(response.statusCode, 302);
    });

    test('303 after POST becomes GET without a body', () async {
      final fake = FakeHttp(
        (r) => r.method == 'POST' ? reply(303, headers: {'location': '/v1/result'}) : reply(200, json: 'done'),
      );
      await clientFor(fake).postJson('/jobs', json: {'a': 1}, decode: (json) => json);
      final follow = fake.requests.last;
      expect(follow.method, 'GET');
      expect(follow.body, isEmpty);
      expect(follow.headers.containsKey('content-type'), isFalse);
    });

    test('307 keeps the method and body on the same origin', () async {
      final fake = FakeHttp(
        (r) => r.url.path == '/v1/a' ? reply(307, headers: {'location': '/v1/b'}) : reply(200, json: 'ok'),
      );
      await clientFor(fake).postJson('/a', json: {'a': 1}, decode: (json) => json);
      expect(fake.requests.last.method, 'POST');
      expect(fake.requests.last.text, '{"a":1}');
    });

    test('307 refuses to send the body to another origin', () async {
      final fake = FakeHttp((_) => reply(307, headers: {'location': 'https://evil.example.org/collect'}));
      await expectLater(
        clientFor(fake).postJson('/a', json: {'password': 'x'}, decode: (json) => json),
        throwsA(isA<RedirectException>()),
      );
      expect(fake.requests, hasLength(1));
    });

    test('a redirect without Location is returned as it is', () async {
      final fake = FakeHttp((_) => reply(302));
      final client = clientFor(fake);
      final response = await client.send(ForgeRequest(method: 'GET', uri: client.resolve('/x')));
      expect(response.statusCode, 302);
    });
  });

  test('close only closes an http client the ForgeClient created', () {
    final fake = FakeHttp((_) => reply(200));
    ForgeClient(baseUrl: 'https://a.example', httpClient: fake).close();
    expect(fake.closed, isFalse);
  });
}
