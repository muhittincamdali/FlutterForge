import 'dart:async';
import 'dart:math' as math;

import 'package:http_parser/http_parser.dart' show parseHttpDate;

import 'api_exception.dart';
import 'forge_request.dart';
import 'forge_response.dart';
import 'interceptor.dart';

/// The highest number of attempts a [RetryPolicy] makes, whatever its
/// `maxAttempts` says.
const int maxRetryAttempts = 10;

/// When and how long to wait before sending a request again.
///
/// The defaults retry a request up to two more times after a connection
/// error, a timeout, or a `408`, `429`, `500`, `502`, `503` or `504` answer,
/// waiting about 300 ms and then about 600 ms. Requests whose method is not
/// idempotent (`POST`, `PATCH`) are never repeated unless
/// [retryNonIdempotent] is `true`, because the server may already have
/// acted on them.
final class RetryPolicy {
  /// Creates a policy.
  ///
  /// [maxAttempts] counts the first attempt, so `3` means up to two retries.
  /// It is clamped to `1...10`; negative durations count as zero.
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 10),
    this.retryStatuses = const {408, 429, 500, 502, 503, 504},
    this.retryNonIdempotent = false,
    this.respectRetryAfter = true,
  });

  /// A policy that never retries.
  static const RetryPolicy none = RetryPolicy(maxAttempts: 1);

  /// The number of attempts, including the first one.
  final int maxAttempts;

  /// The wait before the first retry; each later retry doubles it.
  final Duration baseDelay;

  /// The longest wait between two attempts.
  final Duration maxDelay;

  /// Status codes that are worth another attempt.
  final Set<int> retryStatuses;

  /// Whether `POST`, `PATCH` and other non-idempotent requests are retried.
  final bool retryNonIdempotent;

  /// Whether a `Retry-After` header on a `429` or `503` answer sets the wait.
  /// When it asks for longer than [maxDelay], the answer is returned instead
  /// of waiting.
  final bool respectRetryAfter;

  /// [maxAttempts] clamped to `1...maxRetryAttempts`.
  int get attempts => maxAttempts.clamp(1, maxRetryAttempts);

  /// The wait before retry number [retry] (1 for the first retry) before
  /// jitter: `baseDelay * 2^(retry - 1)`, never more than [maxDelay].
  ///
  /// The doubling is done on integers with an overflow check, so any [retry]
  /// value gives a finite result.
  Duration backoff(int retry) {
    if (retry < 1) return Duration.zero;
    final base = math.max(0, baseDelay.inMicroseconds);
    final cap = math.max(0, maxDelay.inMicroseconds);
    if (base == 0 || cap == 0) return Duration.zero;
    final shift = math.min(retry - 1, 62);
    if (base > (cap >> shift)) return Duration(microseconds: cap);
    return Duration(microseconds: math.min(base << shift, cap));
  }

  /// Whether [request] may be sent again at all.
  bool allowsRetryOf(ForgeRequest request) => retryNonIdempotent || request.isIdempotent;
}

/// Reads a `Retry-After` header value: either a number of seconds or an HTTP
/// date (RFC 9110, section 10.2.3).
///
/// Returns `null` when [value] is missing or malformed. A number longer than
/// ten digits is rejected instead of overflowing; a date in the past gives
/// [Duration.zero].
Duration? parseRetryAfter(String? value, {DateTime? now}) {
  if (value == null) return null;
  final text = value.trim();
  if (RegExp(r'^\d{1,10}$').hasMatch(text)) {
    return Duration(seconds: int.parse(text));
  }
  try {
    final date = parseHttpDate(text);
    final wait = date.difference(now ?? DateTime.now().toUtc());
    return wait.isNegative ? Duration.zero : wait;
  } on FormatException {
    return null;
  }
}

/// Sends a request again after a transient failure, as described by a
/// [RetryPolicy].
///
/// The wait is the policy's [RetryPolicy.backoff] with "equal jitter": a
/// random value between half of it and all of it, so many clients that failed
/// together do not retry together. Cancelling the request also ends the wait.
final class RetryInterceptor implements Interceptor {
  /// Creates the interceptor.
  ///
  /// [random] and [sleep] can be replaced in tests.
  RetryInterceptor([
    this.policy = const RetryPolicy(),
    math.Random? random,
    Future<void> Function(Duration delay)? sleep,
  ]) : _random = random ?? math.Random(),
       _sleep = sleep ?? Future<void>.delayed;

  /// The policy in use.
  final RetryPolicy policy;

  final math.Random _random;
  final Future<void> Function(Duration delay) _sleep;

  @override
  Future<ForgeResponse> intercept(ForgeRequest request, RequestHandler next) async {
    final attempts = policy.allowsRetryOf(request) ? policy.attempts : 1;
    for (var attempt = 1; ; attempt++) {
      final ForgeResponse response;
      try {
        response = await next(request);
      } on ApiException catch (error) {
        final retryable = error is ConnectionException || error is RequestTimeoutException;
        if (!retryable || attempt >= attempts) rethrow;
        await _wait(request, _jittered(policy.backoff(attempt)));
        continue;
      }
      if (attempt >= attempts || !policy.retryStatuses.contains(response.statusCode)) {
        return response;
      }
      final delay = _delayFor(response, attempt);
      if (delay == null) return response;
      await _wait(request, delay);
    }
  }

  Duration? _delayFor(ForgeResponse response, int attempt) {
    final status = response.statusCode;
    if (policy.respectRetryAfter && (status == 429 || status == 503)) {
      final requested = parseRetryAfter(response.header('retry-after'));
      if (requested != null) {
        return requested > policy.maxDelay ? null : requested;
      }
    }
    return _jittered(policy.backoff(attempt));
  }

  Duration _jittered(Duration delay) {
    final half = delay.inMicroseconds ~/ 2;
    return Duration(microseconds: half + (_random.nextDouble() * half).floor());
  }

  Future<void> _wait(ForgeRequest request, Duration delay) async {
    final token = request.cancelToken;
    if (token == null) return _sleep(delay);
    if (token.isCancelled) throw RequestCancelledException(request);
    final woken = Completer<void>();
    void wake() {
      if (!woken.isCompleted) woken.complete();
    }

    final stopListening = token.onCancel(wake);
    unawaited(
      _sleep(delay).then(
        (_) => wake(),
        onError: (Object error, StackTrace stack) {
          if (!woken.isCompleted) woken.completeError(error, stack);
        },
      ),
    );
    try {
      await woken.future;
    } finally {
      stopListening();
    }
    if (token.isCancelled) throw RequestCancelledException(request);
  }
}
