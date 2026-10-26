import 'dart:async';

/// Cancels one or more requests.
///
/// Pass the same token to several requests to cancel them together, for
/// example when a screen is closed:
///
/// ```dart
/// final token = CancelToken();
/// final posts = client.getJson('/posts', decode: Post.listFromJson, cancelToken: token);
/// // later
/// token.cancel();
/// ```
///
/// A cancelled request completes with a `RequestCancelledException`. The
/// connection is closed when the underlying `http` client supports aborting
/// requests (the `dart:io` and browser clients do).
final class CancelToken {
  final Completer<void> _cancelled = Completer<void>();

  /// Whether [cancel] has been called.
  bool get isCancelled => _cancelled.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _cancelled.future;

  /// Cancels every request that uses this token. Calling it again does
  /// nothing.
  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}
