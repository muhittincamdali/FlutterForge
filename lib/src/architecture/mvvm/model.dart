/// Base classes for MVVM architecture Models.
///
/// Models represent the data and business logic layer,
/// independent of the UI.
library;

import 'package:equatable/equatable.dart';

/// Base class for data models.
///
/// Models are immutable data containers that hold
/// application data.
abstract class Model extends Equatable {
  /// Creates a new [Model].
  const Model();
}

/// Base class for models with an identifier.
abstract class IdentifiableModel<T> extends Model {
  /// Creates a new [IdentifiableModel].
  const IdentifiableModel({required this.id});

  /// The unique identifier.
  final T id;

  @override
  List<Object?> get props => [id];
}

/// Base class for models with timestamps.
abstract class TimestampedModel extends Model {
  /// Creates a new [TimestampedModel].
  const TimestampedModel({
    this.createdAt,
    this.updatedAt,
  });

  /// When the model was created.
  final DateTime? createdAt;

  /// When the model was last updated.
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [createdAt, updatedAt];
}

/// Base class for models with both ID and timestamps.
abstract class BaseModel<T> extends Model {
  /// Creates a new [BaseModel].
  const BaseModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// The unique identifier.
  final T id;

  /// When the model was created.
  final DateTime? createdAt;

  /// When the model was last updated.
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}

/// Result wrapper for model operations.
sealed class ModelResult<T> {
  const ModelResult();

  /// Creates a success result.
  factory ModelResult.success(T data) = ModelSuccess<T>;

  /// Creates a failure result.
  factory ModelResult.failure(Object error, [StackTrace? stackTrace]) =
      ModelFailure<T>;
}

/// Success result containing data.
class ModelSuccess<T> extends ModelResult<T> {
  /// Creates a new [ModelSuccess].
  const ModelSuccess(this.data);

  /// The data.
  final T data;
}

/// Failure result containing error.
class ModelFailure<T> extends ModelResult<T> {
  /// Creates a new [ModelFailure].
  const ModelFailure(this.error, [this.stackTrace]);

  /// The error.
  final Object error;

  /// The stack trace.
  final StackTrace? stackTrace;
}

/// Extension methods for [ModelResult].
extension ModelResultExtension<T> on ModelResult<T> {
  /// Whether this is a success.
  bool get isSuccess => this is ModelSuccess<T>;

  /// Whether this is a failure.
  bool get isFailure => this is ModelFailure<T>;

  /// Gets the data or throws.
  T get data {
    final self = this;
    if (self is ModelSuccess<T>) return self.data;
    throw (self as ModelFailure<T>).error;
  }

  /// Gets the data or null.
  T? get dataOrNull {
    final self = this;
    if (self is ModelSuccess<T>) return self.data;
    return null;
  }

  /// Gets the error or null.
  Object? get errorOrNull {
    final self = this;
    if (self is ModelFailure<T>) return self.error;
    return null;
  }

  /// Maps the data if success.
  ModelResult<R> map<R>(R Function(T) transform) {
    final self = this;
    if (self is ModelSuccess<T>) {
      return ModelSuccess(transform(self.data));
    }
    return ModelFailure<R>(
      (self as ModelFailure<T>).error,
      self.stackTrace,
    );
  }

  /// Handles both cases.
  R fold<R>({
    required R Function(T) onSuccess,
    required R Function(Object, StackTrace?) onFailure,
  }) {
    final self = this;
    if (self is ModelSuccess<T>) {
      return onSuccess(self.data);
    }
    final failure = self as ModelFailure<T>;
    return onFailure(failure.error, failure.stackTrace);
  }
}

/// Interface for models that can be validated.
abstract class Validatable {
  /// Validates the model.
  ValidationResult validate();
}

/// Result of validation.
class ValidationResult {
  /// Creates a new [ValidationResult].
  const ValidationResult({
    this.isValid = true,
    this.errors = const {},
  });

  /// Creates a valid result.
  const ValidationResult.valid() : this();

  /// Creates an invalid result.
  const ValidationResult.invalid(Map<String, String> errors)
      : this(isValid: false, errors: errors);

  /// Whether validation passed.
  final bool isValid;

  /// Field-level errors.
  final Map<String, String> errors;

  /// Gets the error for a field.
  String? getError(String field) => errors[field];

  /// Whether there are any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Combines with another result.
  ValidationResult merge(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: {...errors, ...other.errors},
    );
  }
}

/// Builder for validation results.
class ValidationBuilder {
  final Map<String, String> _errors = {};

  /// Adds an error for a field.
  ValidationBuilder addError(String field, String message) {
    _errors[field] = message;
    return this;
  }

  /// Adds an error if condition is true.
  ValidationBuilder addErrorIf(bool condition, String field, String message) {
    if (condition) _errors[field] = message;
    return this;
  }

  /// Validates a required field.
  ValidationBuilder required(String? value, String field, [String? message]) {
    if (value == null || value.isEmpty) {
      _errors[field] = message ?? '$field is required';
    }
    return this;
  }

  /// Validates minimum length.
  ValidationBuilder minLength(String? value, int min, String field,
      [String? message]) {
    if (value != null && value.length < min) {
      _errors[field] = message ?? '$field must be at least $min characters';
    }
    return this;
  }

  /// Validates maximum length.
  ValidationBuilder maxLength(String? value, int max, String field,
      [String? message]) {
    if (value != null && value.length > max) {
      _errors[field] = message ?? '$field must be at most $max characters';
    }
    return this;
  }

  /// Validates email format.
  ValidationBuilder email(String? value, String field, [String? message]) {
    if (value != null &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      _errors[field] = message ?? 'Invalid email address';
    }
    return this;
  }

  /// Validates pattern match.
  ValidationBuilder pattern(
      String? value, RegExp pattern, String field, String message) {
    if (value != null && !pattern.hasMatch(value)) {
      _errors[field] = message;
    }
    return this;
  }

  /// Builds the validation result.
  ValidationResult build() {
    return ValidationResult(
      isValid: _errors.isEmpty,
      errors: Map.unmodifiable(_errors),
    );
  }
}

/// Mixin for models that can be serialized.
mixin Serializable {
  /// Converts to JSON map.
  Map<String, dynamic> toJson();
}

/// Mixin for models that can be cloned.
mixin Cloneable<T> {
  /// Creates a clone of this model.
  T clone();
}

/// Mixin for models with comparison support.
mixin Comparable<T> {
  /// Compares this model to another.
  int compareTo(T other);
}

/// Factory for creating models from JSON.
abstract class ModelFactory<T> {
  /// Creates a model from JSON.
  T fromJson(Map<String, dynamic> json);

  /// Creates a list of models from JSON.
  List<T> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }
}
