import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A request as the fake server saw it.
final class SeenRequest {
  SeenRequest(this.method, this.url, this.headers, this.body);

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final List<int> body;

  String get text => utf8.decode(body);
}

/// Answers each request with [handler] and records what it received.
///
/// Unlike `MockClient`, it honours `Abortable.abortTrigger` and lets a test
/// stream the body in chunks, so time limits, cancellation and size limits can
/// be checked.
final class FakeHttp extends http.BaseClient {
  FakeHttp(this.handler);

  final FutureOr<http.StreamedResponse> Function(SeenRequest request) handler;
  final List<SeenRequest> requests = [];
  int aborted = 0;
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().toBytes();
    final seen = SeenRequest(request.method, request.url, Map.of(request.headers), body);
    requests.add(seen);
    if (request case http.Abortable(:final abortTrigger?)) {
      unawaited(abortTrigger.then((_) => aborted++));
    }
    return handler(seen);
  }

  @override
  void close() => closed = true;
}

/// A response with a JSON or text body.
http.StreamedResponse reply(int status, {Object? json, String? text, Map<String, String> headers = const {}}) {
  final bytes = json != null ? utf8.encode(jsonEncode(json)) : utf8.encode(text ?? '');
  return http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: bytes.length,
    headers: {if (json != null) 'content-type': 'application/json', ...headers},
  );
}

/// A response whose body never finishes and has no declared length.
http.StreamedResponse endless({int chunkSize = 64 * 1024}) {
  Stream<List<int>> chunks() async* {
    final chunk = List<int>.filled(chunkSize, 0x61);
    while (true) {
      yield chunk;
      await Future<void>.delayed(Duration.zero);
    }
  }

  return http.StreamedResponse(chunks(), 200);
}

/// A response that never arrives.
Future<http.StreamedResponse> never() => Completer<http.StreamedResponse>().future;
