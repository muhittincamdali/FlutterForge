import 'dart:typed_data';

import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_example/core/error_message.dart';

void main() {
  final request = ForgeRequest(
    method: 'GET',
    uri: Uri.parse('https://api.example.com/items'),
  );

  ForgeResponse response(int status) => ForgeResponse(
    statusCode: status,
    request: request,
    bodyBytes: Uint8List(0),
  );

  test('explains each kind of failure', () {
    expect(errorMessage(ConnectionException(request)), contains('offline'));
    expect(
      errorMessage(RequestTimeoutException(request, Duration.zero)),
      contains('too long'),
    );
    expect(
      errorMessage(HttpStatusException(response(401))),
      contains('Sign in'),
    );
    expect(
      errorMessage(HttpStatusException(response(404))),
      contains('not be found'),
    );
    expect(
      errorMessage(HttpStatusException(response(503))),
      contains('server had a problem'),
    );
    expect(errorMessage(HttpStatusException(response(418))), contains('418'));
    expect(errorMessage(StateError('bug')), 'Something went wrong. Try again.');
  });
}
