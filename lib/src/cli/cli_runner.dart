import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

/// Custom command runner for FlutterForge CLI.
///
/// Extends [CommandRunner] with additional features like global options,
/// colored output, and enhanced error handling.
class ForgeCliRunner extends CommandRunner<int> {
  /// Creates a new [ForgeCliRunner] with the given [executableName] and [description].
  ForgeCliRunner(super.executableName, super.description) {
    argParser
      ..addFlag(
        'verbose',
        abbr: 'V',
        help: 'Enable verbose output for debugging.',
        negatable: false,
      )
      ..addFlag(
        'version',
        abbr: 'v',
        help: 'Print the version number.',
        negatable: false,
      )
      ..addFlag(
        'color',
        help: 'Use colored output.',
        defaultsTo: true,
      )
      ..addOption(
        'log-level',
        help: 'Set the log level.',
        allowed: ['debug', 'info', 'warning', 'error'],
        defaultsTo: 'info',
      );
  }

  /// Indicates whether verbose mode is enabled.
  bool get verbose => argResults?['verbose'] as bool? ?? false;

  /// Indicates whether colored output is enabled.
  bool get useColor => argResults?['color'] as bool? ?? true;

  /// The current log level.
  String get logLevel => argResults?['log-level'] as String? ?? 'info';

  @override
  Future<int?> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      return await runCommand(argResults);
    } on FormatException catch (e) {
      printError('Format error: ${e.message}');
      printUsage();
      return 64;
    } on UsageException catch (e) {
      printError(e.message);
      print('');
      print(e.usage);
      return 64;
    }
  }

  @override
  Future<int?> runCommand(ArgResults? topLevelResults) async {
    if (topLevelResults == null) {
      printUsage();
      return 0;
    }

    if (topLevelResults['verbose'] as bool) {
      _enableVerboseLogging();
    }

    return super.runCommand(topLevelResults);
  }

  /// Prints the usage information for this command runner.
  void printUsage() {
    print(usage);
  }

  /// Prints an error message with optional styling.
  void printError(String message) {
    if (useColor) {
      stderr.writeln('\x1B[31m❌ Error: $message\x1B[0m');
    } else {
      stderr.writeln('Error: $message');
    }
  }

  /// Prints a success message with optional styling.
  void printSuccess(String message) {
    if (useColor) {
      stdout.writeln('\x1B[32m✅ $message\x1B[0m');
    } else {
      stdout.writeln(message);
    }
  }

  /// Prints a warning message with optional styling.
  void printWarning(String message) {
    if (useColor) {
      stdout.writeln('\x1B[33m⚠️ Warning: $message\x1B[0m');
    } else {
      stdout.writeln('Warning: $message');
    }
  }

  /// Prints an info message with optional styling.
  void printInfo(String message) {
    if (useColor) {
      stdout.writeln('\x1B[36mℹ️ $message\x1B[0m');
    } else {
      stdout.writeln(message);
    }
  }

  /// Enables verbose logging output.
  void _enableVerboseLogging() {
    printInfo('Verbose mode enabled');
  }
}

/// A mixin that provides common functionality for Forge commands.
mixin ForgeCommandMixin on Command<int> {
  /// Gets the parent [ForgeCliRunner] instance.
  ForgeCliRunner get forgeRunner => runner as ForgeCliRunner;

  /// Whether verbose mode is enabled.
  bool get verbose => globalResults?['verbose'] as bool? ?? false;

  /// Whether to use colored output.
  bool get useColor => globalResults?['color'] as bool? ?? true;

  /// Prints a progress indicator.
  void printProgress(String message, int current, int total) {
    final percentage = ((current / total) * 100).toStringAsFixed(0);
    final bar = _createProgressBar(current, total);
    stdout.write('\r$message $bar $percentage%');
    if (current == total) {
      stdout.writeln();
    }
  }

  /// Creates a visual progress bar.
  String _createProgressBar(int current, int total) {
    const width = 30;
    final filled = ((current / total) * width).round();
    final empty = width - filled;
    return '[${useColor ? '\x1B[32m' : ''}${'█' * filled}${useColor ? '\x1B[0m' : ''}${'░' * empty}]';
  }

  /// Prompts the user for confirmation.
  Future<bool> confirm(String message, {bool defaultValue = false}) async {
    final defaultHint = defaultValue ? '[Y/n]' : '[y/N]';
    stdout.write('$message $defaultHint: ');

    final input = stdin.readLineSync()?.toLowerCase().trim();
    if (input == null || input.isEmpty) {
      return defaultValue;
    }
    return input == 'y' || input == 'yes';
  }

  /// Prompts the user for input.
  Future<String> prompt(String message, {String? defaultValue}) async {
    final defaultHint = defaultValue != null ? ' [$defaultValue]' : '';
    stdout.write('$message$defaultHint: ');

    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) {
      return defaultValue ?? '';
    }
    return input;
  }

  /// Displays a spinner while executing an async operation.
  Future<T> withSpinner<T>(
    String message,
    Future<T> Function() operation,
  ) async {
    const spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var frameIndex = 0;
    var isRunning = true;

    // Start spinner in background
    Future.doWhile(() async {
      if (!isRunning) return false;
      stdout.write('\r${spinnerFrames[frameIndex]} $message');
      frameIndex = (frameIndex + 1) % spinnerFrames.length;
      await Future.delayed(const Duration(milliseconds: 80));
      return isRunning;
    });

    try {
      final result = await operation();
      isRunning = false;
      stdout.write('\r\x1B[2K'); // Clear line
      return result;
    } catch (e) {
      isRunning = false;
      stdout.write('\r\x1B[2K'); // Clear line
      rethrow;
    }
  }
}
