import 'dart:async';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:test/test.dart';

import '../support/fake_http.dart';

void main() {
  late String? token;
  late int refreshes;

  setUp(() {
    token = 'old';
    refreshes = 0;
  });

  Future<String?> refresh() async {
    refreshes++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    token = 'new';
    return token;
  }

  ForgeClient clientFor(FakeHttp fake, {TokenRefresher? refresher}) => ForgeClient(
    baseUrl: 'https://api.example.com',
    httpClient: fake,
    retry: RetryPolicy.none,
    auth: BearerAuth(readToken: () => token, refreshToken: refresher ?? refresh),
  );

  FakeHttp acceptsOnly(String accepted) =>
      FakeHttp((r) => r.headers['authorization'] == 'Bearer $accepted' ? reply(200, json: 'ok') : reply(401));

  test('adds the token to requests for the base URL origin', () async {
    final fake = FakeHttp((_) => reply(200, json: 1));
    await clientFor(fake).request('GET', '/me');
    expect(fake.requests.single.headers['authorization'], 'Bearer old');
  });

  test('does not add the token to another origin', () async {
    final fake = FakeHttp((_) => reply(200, json: 1));
    final client = clientFor(fake);
    await client.request('GET', 'https://cdn.example.net/a.png');
    await client.request('GET', 'http://api.example.com/plain');
    await client.request('GET', 'https://api.example.com:8443/other-port');
    expect(fake.requests.map((r) => r.headers.containsKey('authorization')), [false, false, false]);
  });

  test('sends no header while signed out', () async {
    token = null;
    final fake = FakeHttp((_) => reply(200, json: 1));
    await clientFor(fake).request('GET', '/public');
    expect(fake.requests.single.headers.containsKey('authorization'), isFalse);
  });

  test('refreshes once on 401 and sends the request again', () async {
    final fake = acceptsOnly('new');
    expect(await clientFor(fake).getJson('/me', decode: (json) => json), 'ok');
    expect(refreshes, 1);
    expect(fake.requests.map((r) => r.headers['authorization']), ['Bearer old', 'Bearer new']);
  });

  test('concurrent 401 answers share one refresh', () async {
    final fake = acceptsOnly('new');
    final client = clientFor(fake);
    final results = await Future.wait([for (var i = 0; i < 5; i++) client.getJson('/me', decode: (json) => json)]);
    expect(results, everyElement('ok'));
    expect(refreshes, 1);
  });

  test('a server that keeps answering 401 gets one retry, not a loop', () async {
    final fake = FakeHttp((_) => reply(401));
    await expectLater(
      clientFor(fake).request('GET', '/me'),
      throwsA(isA<HttpStatusException>().having((e) => e.statusCode, 'statusCode', 401)),
    );
    expect(fake.requests, hasLength(2));
    expect(refreshes, 1);
  });

  test('returns the 401 when the refresher cannot get a token', () async {
    final fake = FakeHttp((_) => reply(401));
    await expectLater(
      clientFor(fake, refresher: () async => null).request('GET', '/me'),
      throwsA(isA<HttpStatusException>()),
    );
    expect(fake.requests, hasLength(1));
  });

  test('an error from the refresher reaches the caller', () async {
    final fake = FakeHttp((_) => reply(401));
    await expectLater(
      clientFor(fake, refresher: () async => throw StateError('refresh endpoint down')).request('GET', '/me'),
      throwsStateError,
    );
  });

  test('a token with a line break is rejected instead of sent', () async {
    token = 'abc\r\nx-admin: true';
    final fake = FakeHttp((_) => reply(200));
    await expectLater(clientFor(fake).request('GET', '/me'), throwsArgumentError);
    expect(fake.requests, isEmpty);
  });

  test('the interceptor needs at least one trusted origin', () {
    expect(() => BearerAuthInterceptor(readToken: () => 't', trustedOrigins: const []), throwsArgumentError);
  });
}
