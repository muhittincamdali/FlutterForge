/// Template generator for data models.
///
/// Generates Dart models with freezed or equatable support,
/// including JSON serialization.
library;

/// Represents a field in a model.
class ModelField {
  /// Creates a new [ModelField].
  const ModelField({
    required this.name,
    required this.type,
    this.isNullable = false,
    this.defaultValue,
    this.jsonKey,
    this.documentation,
  });

  /// The name of the field.
  final String name;

  /// The Dart type of the field.
  final String type;

  /// Whether the field can be null.
  final bool isNullable;

  /// Optional default value.
  final String? defaultValue;

  /// Custom JSON key for serialization.
  final String? jsonKey;

  /// Documentation for the field.
  final String? documentation;

  /// Gets the full type string including nullability.
  String get fullType => isNullable ? '$type?' : type;

  /// Gets the field as a constructor parameter.
  String toConstructorParam() {
    final buffer = StringBuffer();

    if (defaultValue != null) {
      buffer.write('@Default($defaultValue) ');
    }

    if (jsonKey != null) {
      buffer.write("@JsonKey(name: '$jsonKey') ");
    }

    if (!isNullable && defaultValue == null) {
      buffer.write('required ');
    }

    buffer.write('this.$name');

    return buffer.toString();
  }
}

/// Template generator for data models.
class ModelTemplate {
  /// Creates a new [ModelTemplate].
  ModelTemplate({
    required this.modelName,
    required this.fields,
    this.useFreezed = true,
    this.includeJson = true,
    this.includeEquatable = false,
    this.documentation,
  });

  /// The name of the model in PascalCase.
  final String modelName;

  /// The fields of the model.
  final List<ModelField> fields;

  /// Whether to use freezed for immutability.
  final bool useFreezed;

  /// Whether to include JSON serialization.
  final bool includeJson;

  /// Whether to use equatable (if not using freezed).
  final bool includeEquatable;

  /// Documentation for the model class.
  final String? documentation;

  /// Gets the model name in snake_case.
  String get modelNameSnake => _toSnakeCase(modelName);

  /// Generates the model file content.
  String generate() {
    if (useFreezed) {
      return _generateFreezedModel();
    } else if (includeEquatable) {
      return _generateEquatableModel();
    } else {
      return _generateSimpleModel();
    }
  }

  String _generateFreezedModel() {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
    buffer.writeln();
    buffer.writeln("part '$modelNameSnake.freezed.dart';");
    if (includeJson) {
      buffer.writeln("part '$modelNameSnake.g.dart';");
    }
    buffer.writeln();

    // Class documentation
    if (documentation != null) {
      buffer.writeln('/// $documentation');
    } else {
      buffer.writeln('/// Data model for $modelName.');
    }

    // Class definition
    buffer.writeln('@freezed');
    buffer.writeln('class $modelName with _\$$modelName {');

    // Constructor
    buffer.writeln('  /// Creates a new [$modelName].');
    buffer.writeln('  const factory $modelName({');

    for (final field in fields) {
      if (field.documentation != null) {
        buffer.writeln('    /// ${field.documentation}');
      }
      buffer.writeln('    ${field.toConstructorParam()},');
    }

    buffer.writeln('  }) = _$modelName;');
    buffer.writeln();

    // Private constructor for methods
    buffer.writeln('  const $modelName._();');
    buffer.writeln();

    // JSON factory
    if (includeJson) {
      buffer.writeln('  /// Creates a model from JSON.');
      buffer.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) =>');
      buffer.writeln('      _\$${modelName}FromJson(json);');
    }

    // Custom methods
    buffer.writeln();
    buffer.writeln('  /// Returns a formatted string representation.');
    buffer.writeln("  String get displayName => '${fields.isNotEmpty ? '\${${fields.first.name}}' : modelName}';");

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateEquatableModel() {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:equatable/equatable.dart';");
    if (includeJson) {
      buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
      buffer.writeln();
      buffer.writeln("part '$modelNameSnake.g.dart';");
    }
    buffer.writeln();

    // Class documentation
    if (documentation != null) {
      buffer.writeln('/// $documentation');
    } else {
      buffer.writeln('/// Data model for $modelName.');
    }

    // Class definition
    if (includeJson) {
      buffer.writeln('@JsonSerializable()');
    }
    buffer.writeln('class $modelName extends Equatable {');

    // Constructor
    buffer.writeln('  /// Creates a new [$modelName].');
    buffer.writeln('  const $modelName({');
    for (final field in fields) {
      if (field.defaultValue != null) {
        buffer.writeln('    this.${field.name} = ${field.defaultValue},');
      } else if (field.isNullable) {
        buffer.writeln('    this.${field.name},');
      } else {
        buffer.writeln('    required this.${field.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Fields
    for (final field in fields) {
      if (field.documentation != null) {
        buffer.writeln('  /// ${field.documentation}');
      }
      if (field.jsonKey != null) {
        buffer.writeln("  @JsonKey(name: '${field.jsonKey}')");
      }
      buffer.writeln('  final ${field.fullType} ${field.name};');
      buffer.writeln();
    }

    // JSON methods
    if (includeJson) {
      buffer.writeln('  /// Creates a model from JSON.');
      buffer.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) =>');
      buffer.writeln('      _\$${modelName}FromJson(json);');
      buffer.writeln();
      buffer.writeln('  /// Converts this model to JSON.');
      buffer.writeln('  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);');
      buffer.writeln();
    }

    // copyWith method
    buffer.writeln('  /// Creates a copy with the given fields replaced.');
    buffer.writeln('  $modelName copyWith({');
    for (final field in fields) {
      buffer.writeln('    ${field.type}? ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $modelName(');
    for (final field in fields) {
      buffer.writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // Equatable props
    buffer.writeln('  @override');
    buffer.write('  List<Object?> get props => [');
    buffer.write(fields.map((f) => f.name).join(', '));
    buffer.writeln('];');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateSimpleModel() {
    final buffer = StringBuffer();

    // Imports
    if (includeJson) {
      buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
      buffer.writeln();
      buffer.writeln("part '$modelNameSnake.g.dart';");
      buffer.writeln();
    }

    // Class documentation
    if (documentation != null) {
      buffer.writeln('/// $documentation');
    } else {
      buffer.writeln('/// Data model for $modelName.');
    }

    // Class definition
    if (includeJson) {
      buffer.writeln('@JsonSerializable()');
    }
    buffer.writeln('class $modelName {');

    // Constructor
    buffer.writeln('  /// Creates a new [$modelName].');
    buffer.writeln('  const $modelName({');
    for (final field in fields) {
      if (field.defaultValue != null) {
        buffer.writeln('    this.${field.name} = ${field.defaultValue},');
      } else if (field.isNullable) {
        buffer.writeln('    this.${field.name},');
      } else {
        buffer.writeln('    required this.${field.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Fields
    for (final field in fields) {
      if (field.documentation != null) {
        buffer.writeln('  /// ${field.documentation}');
      }
      if (includeJson && field.jsonKey != null) {
        buffer.writeln("  @JsonKey(name: '${field.jsonKey}')");
      }
      buffer.writeln('  final ${field.fullType} ${field.name};');
      buffer.writeln();
    }

    // JSON methods
    if (includeJson) {
      buffer.writeln('  /// Creates a model from JSON.');
      buffer.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) =>');
      buffer.writeln('      _\$${modelName}FromJson(json);');
      buffer.writeln();
      buffer.writeln('  /// Converts this model to JSON.');
      buffer.writeln('  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);');
      buffer.writeln();
    }

    // copyWith method
    buffer.writeln('  /// Creates a copy with the given fields replaced.');
    buffer.writeln('  $modelName copyWith({');
    for (final field in fields) {
      buffer.writeln('    ${field.type}? ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $modelName(');
    for (final field in fields) {
      buffer.writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // toString
    buffer.writeln('  @override');
    buffer.writeln("  String toString() => '$modelName(");
    final toStringFields = fields
        .map((f) => '${f.name}: \${${f.name}}')
        .join(', ');
    buffer.writeln("      $toStringFields)';");
    buffer.writeln();

    // hashCode and equals
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    if (identical(this, other)) return true;');
    buffer.writeln('    return other is $modelName &&');
    final equalChecks = fields.map((f) => 'other.${f.name} == ${f.name}').join(' &&\n        ');
    buffer.writeln('        $equalChecks;');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => Object.hash(');
    buffer.writeln('        ${fields.map((f) => f.name).join(',\n        ')},');
    buffer.writeln('      );');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }
}

/// Extension methods for generating common model types.
extension ModelTemplateExtensions on ModelTemplate {
  /// Generates a request model variant.
  String generateRequestModel() {
    final requestFields = fields.where((f) => f.name != 'id').toList();
    final requestTemplate = ModelTemplate(
      modelName: '${modelName}Request',
      fields: requestFields,
      useFreezed: useFreezed,
      includeJson: true,
    );
    return requestTemplate.generate();
  }

  /// Generates a response model variant.
  String generateResponseModel() {
    final responseTemplate = ModelTemplate(
      modelName: '${modelName}Response',
      fields: [
        const ModelField(name: 'success', type: 'bool'),
        ModelField(name: 'data', type: modelName, isNullable: true),
        const ModelField(name: 'message', type: 'String', isNullable: true),
      ],
      useFreezed: useFreezed,
      includeJson: true,
    );
    return responseTemplate.generate();
  }

  /// Generates a list response model variant.
  String generateListResponseModel() {
    final listResponseTemplate = ModelTemplate(
      modelName: '${modelName}ListResponse',
      fields: [
        const ModelField(name: 'success', type: 'bool'),
        ModelField(name: 'data', type: 'List<$modelName>'),
        const ModelField(
          name: 'pagination',
          type: 'PaginationInfo',
          isNullable: true,
        ),
      ],
      useFreezed: useFreezed,
      includeJson: true,
    );
    return listResponseTemplate.generate();
  }
}
