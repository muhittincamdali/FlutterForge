import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_forge/src/cli/cli_runner.dart';
import 'package:flutter_forge/src/cli/templates/template_engine.dart';

/// Command for creating new Flutter projects with FlutterForge.
///
/// Usage: flutter_forge create <project_name> [options]
///
/// This command generates a complete Flutter project structure with:
/// - Clean architecture setup
/// - Riverpod state management
/// - Routing configuration
/// - Theming setup
/// - Localization support
/// - CI/CD configuration
class CreateCommand extends Command<int> with ForgeCommandMixin {
  /// Creates a new [CreateCommand] instance.
  CreateCommand() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory for the project.',
        valueHelp: 'path',
      )
      ..addOption(
        'architecture',
        abbr: 'a',
        help: 'Architecture pattern to use.',
        allowed: ['clean', 'mvvm', 'feature'],
        defaultsTo: 'clean',
      )
      ..addOption(
        'state',
        abbr: 's',
        help: 'State management solution.',
        allowed: ['riverpod', 'bloc', 'provider'],
        defaultsTo: 'riverpod',
      )
      ..addOption(
        'org',
        help: 'Organization identifier (e.g., com.example).',
        defaultsTo: 'com.example',
      )
      ..addMultiOption(
        'features',
        abbr: 'f',
        help: 'Features to include.',
        allowed: ['auth', 'settings', 'onboarding', 'profile', 'notifications'],
      )
      ..addFlag(
        'tests',
        help: 'Include test files.',
        defaultsTo: true,
      )
      ..addFlag(
        'ci',
        help: 'Include CI/CD configuration.',
        defaultsTo: true,
      )
      ..addFlag(
        'firebase',
        help: 'Include Firebase configuration.',
        defaultsTo: false,
      )
      ..addFlag(
        'flavors',
        help: 'Include flavor/environment configuration.',
        defaultsTo: true,
      )
      ..addFlag(
        'force',
        help: 'Overwrite existing directory.',
        negatable: false,
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project with FlutterForge.';

  @override
  String get invocation => 'flutter_forge create <project_name> [options]';

  @override
  Future<int> run() async {
    final args = argResults!;

    // Validate project name
    if (args.rest.isEmpty) {
      throw UsageException(
        'Please provide a project name.',
        usage,
      );
    }

    final projectName = args.rest.first;
    if (!_isValidProjectName(projectName)) {
      throw UsageException(
        'Invalid project name: "$projectName". '
        'Project names must be lowercase with underscores.',
        usage,
      );
    }

    // Get configuration options
    final outputDir = args['output'] as String? ?? Directory.current.path;
    final architecture = args['architecture'] as String;
    final stateManagement = args['state'] as String;
    final orgIdentifier = args['org'] as String;
    final features = args['features'] as List<String>;
    final includeTests = args['tests'] as bool;
    final includeCI = args['ci'] as bool;
    final includeFirebase = args['firebase'] as bool;
    final includeFlavors = args['flavors'] as bool;
    final force = args['force'] as bool;

    // Create project directory
    final projectDir = Directory('$outputDir/$projectName');

    if (projectDir.existsSync() && !force) {
      final overwrite = await confirm(
        'Directory "${projectDir.path}" already exists. Overwrite?',
      );
      if (!overwrite) {
        stdout.writeln('Aborted.');
        return 1;
      }
    }

    // Display configuration
    _printConfiguration(
      projectName: projectName,
      outputDir: outputDir,
      architecture: architecture,
      stateManagement: stateManagement,
      orgIdentifier: orgIdentifier,
      features: features,
    );

    // Create project structure
    stdout.writeln('\n📦 Creating project structure...\n');

    final templateEngine = TemplateEngine(
      projectName: projectName,
      orgIdentifier: orgIdentifier,
      architecture: _parseArchitecture(architecture),
      stateManagement: _parseStateManagement(stateManagement),
    );

    try {
      // Create directories
      await _createDirectories(projectDir, templateEngine);
      printProgress('Creating directories', 1, 6);

      // Generate core files
      await _generateCoreFiles(projectDir, templateEngine);
      printProgress('Generating core files', 2, 6);

      // Generate architecture files
      await _generateArchitectureFiles(projectDir, templateEngine, architecture);
      printProgress('Generating architecture', 3, 6);

      // Generate features
      await _generateFeatures(projectDir, templateEngine, features);
      printProgress('Generating features', 4, 6);

      // Generate tests if requested
      if (includeTests) {
        await _generateTests(projectDir, templateEngine);
        printProgress('Generating tests', 5, 6);
      }

      // Generate CI/CD if requested
      if (includeCI) {
        await _generateCICD(projectDir, templateEngine);
      }
      printProgress('Finalizing project', 6, 6);

      // Run flutter pub get
      stdout.writeln('\n📥 Installing dependencies...');
      final pubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectDir.path,
      );

      if (pubGetResult.exitCode != 0) {
        stderr.writeln('Warning: flutter pub get failed');
        if (verbose) {
          stderr.writeln(pubGetResult.stderr);
        }
      }

      // Print success message
      _printSuccess(projectName, projectDir.path);

      return 0;
    } catch (e) {
      stderr.writeln('\n❌ Error creating project: $e');
      return 1;
    }
  }

  /// Validates the project name format.
  bool _isValidProjectName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name) && !_dartReservedWords.contains(name);
  }

  /// Parses architecture string to enum.
  ArchitecturePattern _parseArchitecture(String architecture) {
    switch (architecture) {
      case 'clean':
        return ArchitecturePattern.clean;
      case 'mvvm':
        return ArchitecturePattern.mvvm;
      case 'feature':
        return ArchitecturePattern.feature;
      default:
        return ArchitecturePattern.clean;
    }
  }

  /// Parses state management string to enum.
  StateManagement _parseStateManagement(String state) {
    switch (state) {
      case 'riverpod':
        return StateManagement.riverpod;
      case 'bloc':
        return StateManagement.bloc;
      case 'provider':
        return StateManagement.provider;
      default:
        return StateManagement.riverpod;
    }
  }

  /// Creates the directory structure for the project.
  Future<void> _createDirectories(
    Directory projectDir,
    TemplateEngine engine,
  ) async {
    final directories = [
      'lib/src/core/constants',
      'lib/src/core/errors',
      'lib/src/core/network',
      'lib/src/core/storage',
      'lib/src/core/theme',
      'lib/src/core/utils',
      'lib/src/core/widgets',
      'lib/src/features',
      'lib/src/routing',
      'lib/src/l10n',
      'test/unit',
      'test/widget',
      'test/integration',
      'assets/images',
      'assets/icons',
      'assets/animations',
      'assets/fonts',
    ];

    for (final dir in directories) {
      final directory = Directory('${projectDir.path}/$dir');
      await directory.create(recursive: true);
    }
  }

  /// Generates core application files.
  Future<void> _generateCoreFiles(
    Directory projectDir,
    TemplateEngine engine,
  ) async {
    // Generate main.dart
    final mainContent = engine.generateMain();
    await _writeFile('${projectDir.path}/lib/main.dart', mainContent);

    // Generate app.dart
    final appContent = engine.generateApp();
    await _writeFile('${projectDir.path}/lib/src/app.dart', appContent);

    // Generate pubspec.yaml
    final pubspecContent = engine.generatePubspec();
    await _writeFile('${projectDir.path}/pubspec.yaml', pubspecContent);

    // Generate analysis_options.yaml
    final analysisContent = engine.generateAnalysisOptions();
    await _writeFile('${projectDir.path}/analysis_options.yaml', analysisContent);
  }

  /// Generates architecture-specific files.
  Future<void> _generateArchitectureFiles(
    Directory projectDir,
    TemplateEngine engine,
    String architecture,
  ) async {
    final files = engine.generateArchitectureFiles();
    for (final entry in files.entries) {
      await _writeFile('${projectDir.path}/${entry.key}', entry.value);
    }
  }

  /// Generates feature modules.
  Future<void> _generateFeatures(
    Directory projectDir,
    TemplateEngine engine,
    List<String> features,
  ) async {
    for (final feature in features) {
      final featureFiles = engine.generateFeature(feature);
      for (final entry in featureFiles.entries) {
        await _writeFile('${projectDir.path}/${entry.key}', entry.value);
      }
    }
  }

  /// Generates test files.
  Future<void> _generateTests(
    Directory projectDir,
    TemplateEngine engine,
  ) async {
    final testFiles = engine.generateTests();
    for (final entry in testFiles.entries) {
      await _writeFile('${projectDir.path}/${entry.key}', entry.value);
    }
  }

  /// Generates CI/CD configuration.
  Future<void> _generateCICD(
    Directory projectDir,
    TemplateEngine engine,
  ) async {
    final ciFiles = engine.generateCICD();
    for (final entry in ciFiles.entries) {
      await _writeFile('${projectDir.path}/${entry.key}', entry.value);
    }
  }

  /// Writes content to a file.
  Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Prints the configuration summary.
  void _printConfiguration({
    required String projectName,
    required String outputDir,
    required String architecture,
    required String stateManagement,
    required String orgIdentifier,
    required List<String> features,
  }) {
    stdout.writeln('''
┌─────────────────────────────────────────────────────┐
│               Project Configuration                 │
├─────────────────────────────────────────────────────┤
│  Name:          $projectName${' ' * (38 - projectName.length)}│
│  Organization:  $orgIdentifier${' ' * (38 - orgIdentifier.length)}│
│  Architecture:  $architecture${' ' * (38 - architecture.length)}│
│  State:         $stateManagement${' ' * (38 - stateManagement.length)}│
│  Features:      ${features.isEmpty ? 'none' : features.join(', ')}${' ' * (features.isEmpty ? 34 : 38 - features.join(', ').length).clamp(0, 38)}│
└─────────────────────────────────────────────────────┘
''');
  }

  /// Prints success message and next steps.
  void _printSuccess(String projectName, String projectPath) {
    stdout.writeln('''

╔═══════════════════════════════════════════════════════════════╗
║                    🎉 Project Created!                        ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Your new Flutter project is ready!                           ║
║                                                               ║
║  Next steps:                                                  ║
║                                                               ║
║  1. cd $projectName${' ' * (52 - projectName.length)}║
║  2. flutter run                                               ║
║                                                               ║
║  Useful commands:                                             ║
║                                                               ║
║  • flutter_forge generate feature <name>                      ║
║  • flutter_forge generate model <name>                        ║
║  • flutter_forge analyze                                      ║
║  • flutter_forge build                                        ║
║                                                               ║
║  Documentation: https://github.com/mustafacamdalti/FlutterForge║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
''');
  }
}

/// Reserved words that cannot be used as project names.
const _dartReservedWords = {
  'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
  'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do',
  'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external',
  'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide',
  'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
  'mixin', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow',
  'return', 'set', 'show', 'static', 'super', 'switch', 'sync', 'this',
  'throw', 'true', 'try', 'typedef', 'var', 'void', 'while', 'with', 'yield',
};
