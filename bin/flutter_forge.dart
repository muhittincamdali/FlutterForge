#!/usr/bin/env dart
/// FlutterForge CLI - Production-ready Flutter project generator
///
/// A comprehensive command-line tool for scaffolding Flutter projects
/// with clean architecture, state management, and best practices.
library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_forge/src/cli/cli_runner.dart';
import 'package:flutter_forge/src/cli/commands/create_command.dart';
import 'package:flutter_forge/src/cli/commands/generate_command.dart';
import 'package:flutter_forge/src/cli/commands/build_command.dart';
import 'package:flutter_forge/src/cli/commands/analyze_command.dart';

/// Application version constant
const String kVersion = '1.0.0';

/// Application name constant
const String kAppName = 'flutter_forge';

/// Main entry point for the FlutterForge CLI application.
///
/// Parses command line arguments and delegates to the appropriate command.
/// Supports the following commands:
/// - `create`: Generate a new Flutter project
/// - `generate`: Generate components (features, models, repositories)
/// - `build`: Build the project for various platforms
/// - `analyze`: Run static analysis and linting
Future<void> main(List<String> arguments) async {
  final stopwatch = Stopwatch()..start();

  try {
    await _runApplication(arguments);
  } on UsageException catch (e) {
    _printError('Usage Error: ${e.message}');
    _printUsage(e.usage);
    exit(64); // EX_USAGE
  } on ForgeException catch (e) {
    _printError('Forge Error: ${e.message}');
    if (e.suggestion != null) {
      _printSuggestion(e.suggestion!);
    }
    exit(1);
  } on FileSystemException catch (e) {
    _printError('File System Error: ${e.message}');
    _printSuggestion('Check file permissions and path validity.');
    exit(74); // EX_IOERR
  } catch (e, stackTrace) {
    _printError('Unexpected Error: $e');
    if (_isVerboseMode(arguments)) {
      stderr.writeln('\nStack trace:');
      stderr.writeln(stackTrace);
    }
    exit(70); // EX_SOFTWARE
  } finally {
    stopwatch.stop();
    if (_isVerboseMode(arguments)) {
      stdout.writeln('\n⏱️  Completed in ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}

/// Runs the main application logic.
Future<void> _runApplication(List<String> arguments) async {
  // Handle version flag early
  if (arguments.contains('--version') || arguments.contains('-v')) {
    _printVersion();
    return;
  }

  // Handle help flag early
  if (arguments.isEmpty ||
      arguments.contains('--help') ||
      arguments.contains('-h')) {
    if (arguments.length == 1) {
      _printWelcome();
    }
  }

  // Create and configure the command runner
  final runner = ForgeCliRunner(
    kAppName,
    'FlutterForge - Production-ready Flutter project generator',
  );

  // Register all commands
  runner
    ..addCommand(CreateCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(BuildCommand())
    ..addCommand(AnalyzeCommand());

  // Execute the command
  await runner.run(arguments);
}

/// Prints the application version information.
void _printVersion() {
  stdout.writeln('FlutterForge version $kVersion');
  stdout.writeln('Dart SDK: ${Platform.version.split(' ').first}');
  stdout.writeln('Platform: ${Platform.operatingSystem}');
}

/// Prints a welcome message with ASCII art.
void _printWelcome() {
  stdout.writeln('''
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ███████╗██╗     ██╗   ██╗████████╗████████╗███████╗██████╗  ║
║   ██╔════╝██║     ██║   ██║╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗ ║
║   █████╗  ██║     ██║   ██║   ██║      ██║   █████╗  ██████╔╝ ║
║   ██╔══╝  ██║     ██║   ██║   ██║      ██║   ██╔══╝  ██╔══██╗ ║
║   ██║     ███████╗╚██████╔╝   ██║      ██║   ███████╗██║  ██║ ║
║   ╚═╝     ╚══════╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝ ║
║                                                               ║
║   ███████╗ ██████╗ ██████╗  ██████╗ ███████╗                  ║
║   ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝                  ║
║   █████╗  ██║   ██║██████╔╝██║  ███╗█████╗                    ║
║   ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝                    ║
║   ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗                  ║
║   ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝                  ║
║                                                               ║
║   Production-ready Flutter project generator          v$kVersion ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
''');
}

/// Prints an error message with formatting.
void _printError(String message) {
  stderr.writeln('\n❌ $message');
}

/// Prints usage information.
void _printUsage(String usage) {
  stderr.writeln('\n$usage');
}

/// Prints a suggestion message.
void _printSuggestion(String suggestion) {
  stderr.writeln('\n💡 Suggestion: $suggestion');
}

/// Checks if verbose mode is enabled.
bool _isVerboseMode(List<String> arguments) {
  return arguments.contains('--verbose') || arguments.contains('-V');
}

/// Custom exception for FlutterForge-specific errors.
class ForgeException implements Exception {
  /// Creates a new [ForgeException] with the given [message].
  const ForgeException(this.message, {this.suggestion});

  /// The error message.
  final String message;

  /// Optional suggestion for resolving the error.
  final String? suggestion;

  @override
  String toString() => 'ForgeException: $message';
}

/// Configuration class for the CLI application.
class ForgeConfig {
  /// Creates a new [ForgeConfig] instance.
  const ForgeConfig({
    required this.projectName,
    this.outputDirectory,
    this.architecture = ArchitectureType.clean,
    this.stateManagement = StateManagementType.riverpod,
    this.features = const [],
    this.includeTests = true,
    this.includeCI = true,
    this.verbose = false,
  });

  /// The name of the project to generate.
  final String projectName;

  /// The output directory for the generated project.
  final String? outputDirectory;

  /// The architecture pattern to use.
  final ArchitectureType architecture;

  /// The state management solution to use.
  final StateManagementType stateManagement;

  /// List of features to include.
  final List<String> features;

  /// Whether to include test files.
  final bool includeTests;

  /// Whether to include CI/CD configuration.
  final bool includeCI;

  /// Whether to enable verbose output.
  final bool verbose;

  /// Creates a copy of this config with the given fields replaced.
  ForgeConfig copyWith({
    String? projectName,
    String? outputDirectory,
    ArchitectureType? architecture,
    StateManagementType? stateManagement,
    List<String>? features,
    bool? includeTests,
    bool? includeCI,
    bool? verbose,
  }) {
    return ForgeConfig(
      projectName: projectName ?? this.projectName,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      architecture: architecture ?? this.architecture,
      stateManagement: stateManagement ?? this.stateManagement,
      features: features ?? this.features,
      includeTests: includeTests ?? this.includeTests,
      includeCI: includeCI ?? this.includeCI,
      verbose: verbose ?? this.verbose,
    );
  }
}

/// Supported architecture patterns.
enum ArchitectureType {
  /// Clean Architecture pattern
  clean,

  /// MVVM pattern
  mvvm,

  /// Simple feature-based structure
  feature,
}

/// Supported state management solutions.
enum StateManagementType {
  /// Riverpod state management
  riverpod,

  /// BLoC pattern
  bloc,

  /// Provider package
  provider,
}
