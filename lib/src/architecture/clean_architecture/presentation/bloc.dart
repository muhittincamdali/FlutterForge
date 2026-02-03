/// BLoC pattern base classes for Clean Architecture.
///
/// Business Logic Components separate presentation from business logic,
/// making the code more testable and maintainable.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Base class for BLoC events.
///
/// All events that can be dispatched to a BLoC should extend this class.
@immutable
abstract class BlocEvent {
  /// Creates a new [BlocEvent].
  const BlocEvent();
}

/// Base class for BLoC states.
///
/// All states that a BLoC can emit should extend this class.
@immutable
abstract class BlocState {
  /// Creates a new [BlocState].
  const BlocState();
}

/// Base BLoC class that handles events and emits states.
///
/// Example:
/// ```dart
/// class CounterBloc extends Bloc<CounterEvent, CounterState> {
///   CounterBloc() : super(const CounterInitial()) {
///     on<Increment>(_onIncrement);
///     on<Decrement>(_onDecrement);
///   }
///
///   void _onIncrement(Increment event, Emitter<CounterState> emit) {
///     emit(CounterValue(state.value + 1));
///   }
///
///   void _onDecrement(Decrement event, Emitter<CounterState> emit) {
///     emit(CounterValue(state.value - 1));
///   }
/// }
/// ```
abstract class Bloc<Event extends BlocEvent, State extends BlocState> {
  /// Creates a new [Bloc] with the given [initialState].
  Bloc(this._state) {
    _stateController = StreamController<State>.broadcast();
    _eventController = StreamController<Event>.broadcast();

    _eventSubscription = _eventController.stream.listen(_handleEvent);
  }

  State _state;
  late final StreamController<State> _stateController;
  late final StreamController<Event> _eventController;
  late final StreamSubscription<Event> _eventSubscription;

  final Map<Type, _EventHandler<Event, State>> _handlers = {};

  /// The current state.
  State get state => _state;

  /// Stream of states.
  Stream<State> get stream => _stateController.stream;

  /// Registers an event handler for events of type [E].
  void on<E extends Event>(
    FutureOr<void> Function(E event, Emitter<State> emit) handler,
  ) {
    _handlers[E] = (event, emit) => handler(event as E, emit);
  }

  /// Dispatches an [event] to this BLoC.
  void add(Event event) {
    if (_eventController.isClosed) {
      throw StateError('Cannot add event after BLoC is closed');
    }
    _eventController.add(event);
  }

  void _handleEvent(Event event) async {
    final handler = _handlers[event.runtimeType];
    if (handler == null) {
      throw StateError('No handler registered for ${event.runtimeType}');
    }

    final emitter = _Emitter<State>((state) {
      _state = state;
      _stateController.add(state);
    });

    try {
      await handler(event, emitter);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  /// Called when an error occurs.
  @protected
  void onError(Object error, StackTrace stackTrace) {
    // Override to handle errors
  }

  /// Closes the BLoC and releases resources.
  @mustCallSuper
  Future<void> close() async {
    await _eventSubscription.cancel();
    await _eventController.close();
    await _stateController.close();
  }
}

typedef _EventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> emit,
);

/// Emitter interface for emitting states.
abstract class Emitter<State> {
  /// Emits a new [state].
  void call(State state);

  /// Whether this emitter is done.
  bool get isDone;
}

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);

  final void Function(State) _emit;
  bool _isDone = false;

  @override
  void call(State state) {
    if (_isDone) {
      throw StateError('Cannot emit after handler completes');
    }
    _emit(state);
  }

  @override
  bool get isDone => _isDone;

  void complete() => _isDone = true;
}

/// Base class for Cubits.
///
/// Cubits are simplified BLoCs that don't use events.
///
/// Example:
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///   void decrement() => emit(state - 1);
/// }
/// ```
abstract class Cubit<State> {
  /// Creates a new [Cubit] with the given [initialState].
  Cubit(this._state) {
    _stateController = StreamController<State>.broadcast();
  }

  State _state;
  late final StreamController<State> _stateController;

  /// The current state.
  State get state => _state;

  /// Stream of states.
  Stream<State> get stream => _stateController.stream;

  /// Emits a new [state].
  @protected
  void emit(State state) {
    if (_stateController.isClosed) {
      throw StateError('Cannot emit after Cubit is closed');
    }
    _state = state;
    _stateController.add(state);
  }

  /// Closes the Cubit.
  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
  }
}

/// Mixin for BLoCs that need loading state.
mixin LoadingMixin<Event extends BlocEvent, State extends BlocState>
    on Bloc<Event, State> {
  bool _isLoading = false;

  /// Whether the BLoC is currently loading.
  bool get isLoading => _isLoading;

  /// Sets the loading state.
  @protected
  void setLoading(bool loading) {
    _isLoading = loading;
  }
}

/// Mixin for BLoCs that need error handling.
mixin ErrorMixin<Event extends BlocEvent, State extends BlocState>
    on Bloc<Event, State> {
  Object? _error;
  StackTrace? _stackTrace;

  /// The current error, if any.
  Object? get error => _error;

  /// The error stack trace.
  StackTrace? get errorStackTrace => _stackTrace;

  /// Whether there is an error.
  bool get hasError => _error != null;

  /// Sets the error.
  @protected
  void setError(Object? error, [StackTrace? stackTrace]) {
    _error = error;
    _stackTrace = stackTrace;
  }

  /// Clears the error.
  @protected
  void clearError() {
    _error = null;
    _stackTrace = null;
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    setError(error, stackTrace);
    super.onError(error, stackTrace);
  }
}

/// Mixin for BLoCs with debouncing.
mixin DebounceMixin<Event extends BlocEvent, State extends BlocState>
    on Bloc<Event, State> {
  Timer? _debounceTimer;

  /// The debounce duration.
  Duration get debounceDuration => const Duration(milliseconds: 300);

  /// Debounces an action.
  void debounce(void Function() action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, action);
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await super.close();
  }
}

/// Mixin for BLoCs with throttling.
mixin ThrottleMixin<Event extends BlocEvent, State extends BlocState>
    on Bloc<Event, State> {
  DateTime? _lastCall;

  /// The throttle duration.
  Duration get throttleDuration => const Duration(milliseconds: 300);

  /// Throttles an action.
  bool throttle(void Function() action) {
    final now = DateTime.now();
    if (_lastCall == null ||
        now.difference(_lastCall!) > throttleDuration) {
      _lastCall = now;
      action();
      return true;
    }
    return false;
  }
}

/// Observer for BLoC lifecycle events.
abstract class BlocObserver {
  /// Called when a BLoC is created.
  void onCreate(Bloc bloc) {}

  /// Called when an event is added to a BLoC.
  void onEvent(Bloc bloc, Object? event) {}

  /// Called when a state change occurs.
  void onChange(Bloc bloc, Object? currentState, Object? nextState) {}

  /// Called when an error occurs.
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {}

  /// Called when a BLoC is closed.
  void onClose(Bloc bloc) {}
}

/// BLoC transformer for event streams.
typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event> events,
  Stream<Event> Function(Event) mapper,
);

/// Sequential event transformer.
EventTransformer<Event> sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

/// Concurrent event transformer.
EventTransformer<Event> concurrent<Event>() {
  return (events, mapper) => events.flatMap(mapper);
}

/// Droppable event transformer.
EventTransformer<Event> droppable<Event>() {
  return (events, mapper) {
    return events.transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          mapper(event).listen(sink.add);
        },
      ),
    );
  };
}

/// Restartable event transformer.
EventTransformer<Event> restartable<Event>() {
  return (events, mapper) => events.switchMap(mapper);
}

/// Extension for flatMap on Stream.
extension _FlatMapExtension<T> on Stream<T> {
  Stream<R> flatMap<R>(Stream<R> Function(T) mapper) {
    return asyncExpand(mapper);
  }

  Stream<R> switchMap<R>(Stream<R> Function(T) mapper) {
    return transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          mapper(data).listen(sink.add);
        },
      ),
    );
  }
}

/// Utility class for creating common BLoC states.
class BlocStates {
  BlocStates._();

  /// Creates a loading state wrapper.
  static LoadingState<T> loading<T>() => LoadingState<T>();

  /// Creates a success state wrapper.
  static SuccessState<T> success<T>(T data) => SuccessState<T>(data);

  /// Creates an error state wrapper.
  static ErrorState<T> error<T>(Object error, [StackTrace? stackTrace]) =>
      ErrorState<T>(error, stackTrace);
}

/// Generic loading state.
class LoadingState<T> extends BlocState {
  /// Creates a new [LoadingState].
  const LoadingState();
}

/// Generic success state.
class SuccessState<T> extends BlocState {
  /// Creates a new [SuccessState].
  const SuccessState(this.data);

  /// The data.
  final T data;
}

/// Generic error state.
class ErrorState<T> extends BlocState {
  /// Creates a new [ErrorState].
  const ErrorState(this.error, [this.stackTrace]);

  /// The error.
  final Object error;

  /// The stack trace.
  final StackTrace? stackTrace;
}
