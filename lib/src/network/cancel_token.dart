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
///
/// A token can live as long as the app: a request stops listening to it when
/// it finishes, so a token shared by thousands of requests does not keep them
/// in memory.
final class CancelToken {
  final Completer<void> _cancelled = Completer<void>();
  final Set<_Listener> _listeners = {};

  /// Whether [cancel] has been called.
  bool get isCancelled => _cancelled.isCompleted;

  /// Completes when [cancel] is called.
  ///
  /// A callback added with `then` stays attached until the token is
  /// cancelled. Code that waits on a long-lived token many times should use
  /// [onCancel] and remove its callback when it stops waiting.
  Future<void> get whenCancelled => _cancelled.future;

  /// Calls [callback] once when [cancel] is called and returns a function
  /// that removes it again.
  ///
  /// When the token is already cancelled, [callback] runs right away.
  /// Removing a callback twice, or after it ran, does nothing.
  void Function() onCancel(void Function() callback) {
    if (isCancelled) {
      callback();
      return _noop;
    }
    final listener = _Listener(callback);
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Cancels every request that uses this token. Calling it again does
  /// nothing.
  void cancel() {
    if (_cancelled.isCompleted) return;
    _cancelled.complete();
    final listeners = List.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener.callback();
    }
  }
}

/// The number of callbacks [token] holds. Not exported; tests use it to
/// check that finished requests let go of a shared token.
int pendingCancelCallbacks(CancelToken token) => token._listeners.length;

// A wrapper, so the same function can be added twice and removed once.
final class _Listener {
  _Listener(this.callback);

  final void Function() callback;
}

void _noop() {}
