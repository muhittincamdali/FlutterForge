import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_forge/src/cli/cli_runner.dart';
import 'package:flutter_forge/src/cli/templates/feature_template.dart';
import 'package:flutter_forge/src/cli/templates/model_template.dart';
import 'package:flutter_forge/src/cli/templates/repository_template.dart';

/// Command for generating components within a FlutterForge project.
///
/// Usage: flutter_forge generate <component> <name> [options]
///
/// Supported components:
/// - feature: Generates a complete feature module
/// - model: Generates a data model with freezed
/// - repository: Generates a repository with data source
/// - usecase: Generates a use case
/// - widget: Generates a reusable widget
/// - page: Generates a page/screen
/// - service: Generates a service class
class GenerateCommand extends Command<int> with ForgeCommandMixin {
  /// Creates a new [GenerateCommand] instance.
  GenerateCommand() {
    addSubcommand(_FeatureSubcommand());
    addSubcommand(_ModelSubcommand());
    addSubcommand(_RepositorySubcommand());
    addSubcommand(_UseCaseSubcommand());
    addSubcommand(_WidgetSubcommand());
    addSubcommand(_PageSubcommand());
    addSubcommand(_ServiceSubcommand());
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate project components.';

  @override
  String get invocation => 'flutter_forge generate <component> <name> [options]';

  @override
  Future<int> run() async {
    throw UsageException(
      'Please specify a component to generate.',
      usage,
    );
  }
}

/// Subcommand for generating feature modules.
class _FeatureSubcommand extends Command<int> with ForgeCommandMixin {
  _FeatureSubcommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Custom path for the feature.',
        valueHelp: 'path',
      )
      ..addFlag(
        'repository',
        abbr: 'r',
        help: 'Include repository layer.',
        defaultsTo: true,
      )
      ..addFlag(
        'usecase',
        abbr: 'u',
        help: 'Include use cases.',
        defaultsTo: true,
      )
      ..addFlag(
        'tests',
        abbr: 't',
        help: 'Include test files.',
        defaultsTo: true,
      )
      ..addMultiOption(
        'entities',
        abbr: 'e',
        help: 'Entity names to generate.',
      );
  }

  @override
  String get name => 'feature';

  @override
  String get description => 'Generate a new feature module.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a feature name.', usage);
    }

    final featureName = args.rest.first;
    final customPath = args['path'] as String?;
    final includeRepository = args['repository'] as bool;
    final includeUseCase = args['usecase'] as bool;
    final includeTests = args['tests'] as bool;
    final entities = args['entities'] as List<String>;

    // Validate we're in a Flutter project
    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    stdout.writeln('🔧 Generating feature: $featureName\n');

    final template = FeatureTemplate(
      featureName: featureName,
      includeRepository: includeRepository,
      includeUseCase: includeUseCase,
      entities: entities,
    );

    final basePath = customPath ?? 'lib/src/features/$featureName';
    final files = template.generate();

    var count = 0;
    final total = files.length + (includeTests ? 3 : 0);

    for (final entry in files.entries) {
      await _writeFile('$basePath/${entry.key}', entry.value);
      count++;
      printProgress('Generating files', count, total);
    }

    if (includeTests) {
      final testFiles = template.generateTests();
      for (final entry in testFiles.entries) {
        await _writeFile('test/features/$featureName/${entry.key}', entry.value);
        count++;
        printProgress('Generating files', count, total);
      }
    }

    stdout.writeln('\n\n✅ Feature "$featureName" generated successfully!');
    stdout.writeln('\nGenerated files:');
    for (final path in files.keys) {
      stdout.writeln('  📄 $basePath/$path');
    }

    return 0;
  }
}

/// Subcommand for generating data models.
class _ModelSubcommand extends Command<int> with ForgeCommandMixin {
  _ModelSubcommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the model to.',
        valueHelp: 'feature_name',
      )
      ..addMultiOption(
        'fields',
        help: 'Fields in format: name:type (e.g., id:int, name:String)',
      )
      ..addFlag(
        'freezed',
        help: 'Use freezed for immutability.',
        defaultsTo: true,
      )
      ..addFlag(
        'json',
        abbr: 'j',
        help: 'Include JSON serialization.',
        defaultsTo: true,
      )
      ..addFlag(
        'equatable',
        help: 'Use equatable instead of freezed.',
        negatable: false,
      );
  }

  @override
  String get name => 'model';

  @override
  String get description => 'Generate a data model.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a model name.', usage);
    }

    final modelName = args.rest.first;
    final feature = args['feature'] as String?;
    final fields = args['fields'] as List<String>;
    final useFreezed = args['freezed'] as bool;
    final includeJson = args['json'] as bool;
    final useEquatable = args['equatable'] as bool;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    stdout.writeln('🔧 Generating model: $modelName\n');

    final parsedFields = _parseFields(fields);
    final template = ModelTemplate(
      modelName: modelName,
      fields: parsedFields,
      useFreezed: useFreezed && !useEquatable,
      includeJson: includeJson,
    );

    final basePath = feature != null
        ? 'lib/src/features/$feature/data/models'
        : 'lib/src/core/models';

    final content = template.generate();
    final fileName = _toSnakeCase(modelName);

    await _writeFile('$basePath/$fileName.dart', content);

    stdout.writeln('✅ Model "$modelName" generated successfully!');
    stdout.writeln('\n📄 $basePath/$fileName.dart');

    if (useFreezed) {
      stdout.writeln('\n💡 Run `dart run build_runner build` to generate code.');
    }

    return 0;
  }

  List<ModelField> _parseFields(List<String> fields) {
    return fields.map((field) {
      final parts = field.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid field format: $field');
      }
      return ModelField(
        name: parts[0].trim(),
        type: parts[1].trim(),
      );
    }).toList();
  }
}

/// Subcommand for generating repositories.
class _RepositorySubcommand extends Command<int> with ForgeCommandMixin {
  _RepositorySubcommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the repository to.',
        valueHelp: 'feature_name',
      )
      ..addFlag(
        'remote',
        help: 'Include remote data source.',
        defaultsTo: true,
      )
      ..addFlag(
        'local',
        help: 'Include local data source.',
        defaultsTo: true,
      )
      ..addMultiOption(
        'methods',
        abbr: 'm',
        help: 'Methods to generate (e.g., getAll, getById, create)',
      );
  }

  @override
  String get name => 'repository';

  @override
  String get description => 'Generate a repository with data sources.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a repository name.', usage);
    }

    final repoName = args.rest.first;
    final feature = args['feature'] as String?;
    final includeRemote = args['remote'] as bool;
    final includeLocal = args['local'] as bool;
    final methods = args['methods'] as List<String>;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    stdout.writeln('🔧 Generating repository: $repoName\n');

    final template = RepositoryTemplate(
      repositoryName: repoName,
      includeRemoteDataSource: includeRemote,
      includeLocalDataSource: includeLocal,
      methods: methods.isEmpty ? ['getAll', 'getById', 'create', 'update', 'delete'] : methods,
    );

    final basePath = feature != null
        ? 'lib/src/features/$feature/data'
        : 'lib/src/core/data';

    final files = template.generate();

    for (final entry in files.entries) {
      await _writeFile('$basePath/${entry.key}', entry.value);
      stdout.writeln('  📄 $basePath/${entry.key}');
    }

    stdout.writeln('\n✅ Repository "$repoName" generated successfully!');

    return 0;
  }
}

/// Subcommand for generating use cases.
class _UseCaseSubcommand extends Command<int> with ForgeCommandMixin {
  _UseCaseSubcommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the use case to.',
        valueHelp: 'feature_name',
        mandatory: true,
      )
      ..addOption(
        'input',
        abbr: 'i',
        help: 'Input type for the use case.',
        defaultsTo: 'void',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output type for the use case.',
        defaultsTo: 'void',
      );
  }

  @override
  String get name => 'usecase';

  @override
  String get description => 'Generate a use case.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a use case name.', usage);
    }

    final useCaseName = args.rest.first;
    final feature = args['feature'] as String;
    final inputType = args['input'] as String;
    final outputType = args['output'] as String;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final content = _generateUseCase(useCaseName, inputType, outputType);
    final fileName = _toSnakeCase(useCaseName);
    final path = 'lib/src/features/$feature/domain/usecases/$fileName.dart';

    await _writeFile(path, content);

    stdout.writeln('✅ Use case "$useCaseName" generated successfully!');
    stdout.writeln('\n📄 $path');

    return 0;
  }

  String _generateUseCase(String name, String input, String output) {
    return '''
import 'package:flutter_forge/src/architecture/clean_architecture/domain/use_case.dart';

/// Use case for ${_toSentence(name)}.
class $name extends UseCase<$input, $output> {
  /// Creates a new [$name] instance.
  const $name();

  @override
  Future<$output> call($input params) async {
    // TODO: Implement use case logic
    throw UnimplementedError();
  }
}
''';
  }
}

/// Subcommand for generating widgets.
class _WidgetSubcommand extends Command<int> with ForgeCommandMixin {
  _WidgetSubcommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the widget to.',
        valueHelp: 'feature_name',
      )
      ..addFlag(
        'stateful',
        help: 'Generate a stateful widget.',
        negatable: false,
      )
      ..addFlag(
        'hooks',
        help: 'Use flutter_hooks.',
        negatable: false,
      );
  }

  @override
  String get name => 'widget';

  @override
  String get description => 'Generate a reusable widget.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a widget name.', usage);
    }

    final widgetName = args.rest.first;
    final feature = args['feature'] as String?;
    final stateful = args['stateful'] as bool;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final content = stateful
        ? _generateStatefulWidget(widgetName)
        : _generateStatelessWidget(widgetName);

    final fileName = _toSnakeCase(widgetName);
    final basePath = feature != null
        ? 'lib/src/features/$feature/presentation/widgets'
        : 'lib/src/core/widgets';

    await _writeFile('$basePath/$fileName.dart', content);

    stdout.writeln('✅ Widget "$widgetName" generated successfully!');
    stdout.writeln('\n📄 $basePath/$fileName.dart');

    return 0;
  }

  String _generateStatelessWidget(String name) {
    return '''
import 'package:flutter/material.dart';

/// A stateless widget for $name.
class $name extends StatelessWidget {
  /// Creates a new [$name] instance.
  const $name({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''';
  }

  String _generateStatefulWidget(String name) {
    return '''
import 'package:flutter/material.dart';

/// A stateful widget for $name.
class $name extends StatefulWidget {
  /// Creates a new [$name] instance.
  const $name({super.key});

  @override
  State<$name> createState() => _${name}State();
}

class _${name}State extends State<$name> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''';
  }
}

/// Subcommand for generating pages.
class _PageSubcommand extends Command<int> with ForgeCommandMixin {
  _PageSubcommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the page to.',
        valueHelp: 'feature_name',
        mandatory: true,
      )
      ..addFlag(
        'scaffold',
        help: 'Include scaffold with app bar.',
        defaultsTo: true,
      );
  }

  @override
  String get name => 'page';

  @override
  String get description => 'Generate a page/screen.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a page name.', usage);
    }

    final pageName = args.rest.first;
    final feature = args['feature'] as String;
    final includeScaffold = args['scaffold'] as bool;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final content = _generatePage(pageName, includeScaffold);
    final fileName = _toSnakeCase(pageName);
    final path = 'lib/src/features/$feature/presentation/pages/$fileName.dart';

    await _writeFile(path, content);

    stdout.writeln('✅ Page "$pageName" generated successfully!');
    stdout.writeln('\n📄 $path');

    return 0;
  }

  String _generatePage(String name, bool includeScaffold) {
    final title = _toSentence(name).replaceAll(' Page', '');
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page widget for $title.
class $name extends ConsumerWidget {
  /// Creates a new [$name] instance.
  const $name({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ${includeScaffold ? '''Scaffold(
      appBar: AppBar(
        title: const Text('$title'),
      ),
      body: const Center(
        child: Text('$title'),
      ),
    )''' : '''const Center(
      child: Text('$title'),
    )'''};
  }
}
''';
  }
}

/// Subcommand for generating services.
class _ServiceSubcommand extends Command<int> with ForgeCommandMixin {
  _ServiceSubcommand() {
    argParser
      ..addFlag(
        'singleton',
        help: 'Generate as singleton.',
        defaultsTo: true,
      )
      ..addMultiOption(
        'methods',
        abbr: 'm',
        help: 'Methods to generate.',
      );
  }

  @override
  String get name => 'service';

  @override
  String get description => 'Generate a service class.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (args.rest.isEmpty) {
      throw UsageException('Please provide a service name.', usage);
    }

    final serviceName = args.rest.first;
    final methods = args['methods'] as List<String>;

    if (!_isFlutterProject()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final content = _generateService(serviceName, methods);
    final fileName = _toSnakeCase(serviceName);
    final path = 'lib/src/core/services/$fileName.dart';

    await _writeFile(path, content);

    stdout.writeln('✅ Service "$serviceName" generated successfully!');
    stdout.writeln('\n📄 $path');

    return 0;
  }

  String _generateService(String name, List<String> methods) {
    final methodsCode = methods.map((m) => '''
  /// ${_toSentence(m)}.
  Future<void> $m() async {
    // TODO: Implement $m
    throw UnimplementedError();
  }
''').join('\n');

    return '''
/// Service for ${_toSentence(name)}.
class $name {
  /// Creates a new [$name] instance.
  const $name();

$methodsCode
}
''';
  }
}

// Helper functions

bool _isFlutterProject() {
  return File('pubspec.yaml').existsSync();
}

Future<void> _writeFile(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      )
      .replaceFirst('_', '');
}

String _toSentence(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => ' ${match.group(0)}',
      )
      .trim();
}
