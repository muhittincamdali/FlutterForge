import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_forge/src/cli/cli_runner.dart';

/// Command for analyzing Flutter projects.
///
/// Usage: flutter_forge analyze [options]
///
/// Runs various analysis tools:
/// - Dart analyzer
/// - Flutter analyze
/// - Custom lint rules
/// - Code metrics
/// - Dependency audit
class AnalyzeCommand extends Command<int> with ForgeCommandMixin {
  /// Creates a new [AnalyzeCommand] instance.
  AnalyzeCommand() {
    argParser
      ..addFlag(
        'fix',
        help: 'Apply automatic fixes where possible.',
        negatable: false,
      )
      ..addFlag(
        'fatal-infos',
        help: 'Treat info level issues as fatal.',
        negatable: false,
      )
      ..addFlag(
        'fatal-warnings',
        help: 'Treat warning level issues as fatal.',
        defaultsTo: true,
      )
      ..addFlag(
        'metrics',
        help: 'Include code metrics analysis.',
        defaultsTo: true,
      )
      ..addFlag(
        'dependencies',
        help: 'Audit dependencies for issues.',
        defaultsTo: true,
      )
      ..addOption(
        'format',
        abbr: 'f',
        help: 'Output format.',
        allowed: ['text', 'json', 'github'],
        defaultsTo: 'text',
      );
  }

  @override
  String get name => 'analyze';

  @override
  String get description => 'Analyze the Flutter project for issues.';

  @override
  Future<int> run() async {
    final args = argResults!;

    if (!File('pubspec.yaml').existsSync()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final applyFix = args['fix'] as bool;
    final fatalInfos = args['fatal-infos'] as bool;
    final fatalWarnings = args['fatal-warnings'] as bool;
    final includeMetrics = args['metrics'] as bool;
    final auditDependencies = args['dependencies'] as bool;
    final format = args['format'] as String;

    stdout.writeln('🔍 Analyzing project...\n');

    var totalIssues = 0;
    var hasErrors = false;

    // Run Flutter analyze
    final analyzeResult = await _runFlutterAnalyze(
      fatalInfos: fatalInfos,
      fatalWarnings: fatalWarnings,
    );
    totalIssues += analyzeResult.issues;
    hasErrors |= analyzeResult.hasErrors;

    // Apply fixes if requested
    if (applyFix) {
      await _runDartFix();
    }

    // Run code metrics
    if (includeMetrics) {
      await _runCodeMetrics();
    }

    // Audit dependencies
    if (auditDependencies) {
      await _auditDependencies();
    }

    // Check for common issues
    await _checkCommonIssues();

    // Print summary
    _printSummary(totalIssues, hasErrors);

    return hasErrors ? 1 : 0;
  }

  /// Runs Flutter analyze command.
  Future<_AnalyzeResult> _runFlutterAnalyze({
    required bool fatalInfos,
    required bool fatalWarnings,
  }) async {
    stdout.writeln('📊 Running Flutter analyzer...\n');

    final args = ['analyze', '--no-pub'];
    if (fatalInfos) args.add('--fatal-infos');
    if (fatalWarnings) args.add('--fatal-warnings');

    final result = await Process.run('flutter', args);

    stdout.writeln(result.stdout);
    if (result.stderr.toString().isNotEmpty) {
      stderr.writeln(result.stderr);
    }

    // Parse results
    final output = result.stdout.toString();
    final issueCount = _parseIssueCount(output);

    return _AnalyzeResult(
      issues: issueCount,
      hasErrors: result.exitCode != 0,
    );
  }

  /// Runs dart fix to apply automatic fixes.
  Future<void> _runDartFix() async {
    stdout.writeln('\n🔧 Applying automatic fixes...\n');

    final result = await Process.run('dart', ['fix', '--apply']);
    stdout.writeln(result.stdout);

    if (result.exitCode == 0) {
      stdout.writeln('✅ Fixes applied successfully');
    } else {
      stderr.writeln('⚠️ Some fixes could not be applied');
      stderr.writeln(result.stderr);
    }
  }

  /// Runs code metrics analysis.
  Future<void> _runCodeMetrics() async {
    stdout.writeln('\n📏 Analyzing code metrics...\n');

    // Check if dart_code_metrics is available
    final metricsAvailable = await _isDartCodeMetricsAvailable();

    if (!metricsAvailable) {
      stdout.writeln(
        'ℹ️ dart_code_metrics not installed. Using built-in analysis.',
      );
      await _runBuiltInMetrics();
      return;
    }

    final result = await Process.run(
      'dart',
      [
        'run',
        'dart_code_metrics:metrics',
        'lib',
        '--reporter=console',
        '--set-exit-on-violation-level=warning',
      ],
    );

    stdout.writeln(result.stdout);
  }

  /// Checks if dart_code_metrics is available.
  Future<bool> _isDartCodeMetricsAvailable() async {
    final pubspec = await File('pubspec.yaml').readAsString();
    return pubspec.contains('dart_code_metrics');
  }

  /// Runs built-in metrics analysis.
  Future<void> _runBuiltInMetrics() async {
    final libDir = Directory('lib');
    if (!await libDir.exists()) {
      stdout.writeln('⚠️ lib directory not found');
      return;
    }

    var totalFiles = 0;
    var totalLines = 0;
    var totalClasses = 0;
    var totalFunctions = 0;

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        totalFiles++;
        final content = await entity.readAsString();
        totalLines += content.split('\n').length;
        totalClasses += RegExp(r'\bclass\s+\w+').allMatches(content).length;
        totalFunctions += RegExp(r'\b(void|Future|String|int|bool|double|dynamic)\s+\w+\s*\(')
            .allMatches(content)
            .length;
      }
    }

    stdout.writeln('''
┌─────────────────────────────────────────────────────┐
│                   Code Metrics                      │
├─────────────────────────────────────────────────────┤
│  Dart files:      $totalFiles${' ' * (32 - totalFiles.toString().length)}│
│  Total lines:     $totalLines${' ' * (32 - totalLines.toString().length)}│
│  Classes:         $totalClasses${' ' * (32 - totalClasses.toString().length)}│
│  Functions:       $totalFunctions${' ' * (32 - totalFunctions.toString().length)}│
│  Avg lines/file:  ${(totalLines / totalFiles).toStringAsFixed(1)}${' ' * (32 - (totalLines / totalFiles).toStringAsFixed(1).length)}│
└─────────────────────────────────────────────────────┘
''');
  }

  /// Audits project dependencies.
  Future<void> _auditDependencies() async {
    stdout.writeln('\n🔐 Auditing dependencies...\n');

    // Check for outdated packages
    final outdatedResult = await Process.run('flutter', ['pub', 'outdated']);
    stdout.writeln(outdatedResult.stdout);

    // Check for security advisories (basic check)
    await _checkSecurityAdvisories();
  }

  /// Checks for known security advisories.
  Future<void> _checkSecurityAdvisories() async {
    // Read pubspec.lock
    final lockFile = File('pubspec.lock');
    if (!await lockFile.exists()) {
      stdout.writeln('⚠️ pubspec.lock not found');
      return;
    }

    final content = await lockFile.readAsString();

    // List of packages with known issues (simplified check)
    final packagesWithIssues = <String, String>{
      'http:0.12': 'Upgrade to http ^1.0.0 for security fixes',
      'dio:4.0.0': 'Consider upgrading to dio 5.x for improvements',
    };

    var foundIssues = false;
    for (final entry in packagesWithIssues.entries) {
      if (content.contains(entry.key)) {
        stdout.writeln('⚠️ ${entry.key}: ${entry.value}');
        foundIssues = true;
      }
    }

    if (!foundIssues) {
      stdout.writeln('✅ No known security issues found in dependencies');
    }
  }

  /// Checks for common project issues.
  Future<void> _checkCommonIssues() async {
    stdout.writeln('\n🔎 Checking for common issues...\n');

    final issues = <String>[];

    // Check for .gitignore
    if (!await File('.gitignore').exists()) {
      issues.add('Missing .gitignore file');
    }

    // Check for README
    if (!await File('README.md').exists()) {
      issues.add('Missing README.md');
    }

    // Check for analysis_options.yaml
    if (!await File('analysis_options.yaml').exists()) {
      issues.add('Missing analysis_options.yaml');
    }

    // Check for test directory
    if (!await Directory('test').exists()) {
      issues.add('Missing test directory');
    }

    // Check for secrets in code
    final secretsFound = await _checkForSecrets();
    if (secretsFound) {
      issues.add('Potential secrets found in code');
    }

    // Check for TODO/FIXME comments
    final todoCount = await _countTodos();
    if (todoCount > 10) {
      issues.add('$todoCount TODO/FIXME comments found');
    }

    if (issues.isEmpty) {
      stdout.writeln('✅ No common issues found');
    } else {
      for (final issue in issues) {
        stdout.writeln('⚠️ $issue');
      }
    }
  }

  /// Checks for potential secrets in code.
  Future<bool> _checkForSecrets() async {
    final libDir = Directory('lib');
    if (!await libDir.exists()) return false;

    final secretPatterns = [
      RegExp(r'api[_-]?key\s*[:=]\s*["\'][^"\']+["\']', caseSensitive: false),
      RegExp(r'secret\s*[:=]\s*["\'][^"\']+["\']', caseSensitive: false),
      RegExp(r'password\s*[:=]\s*["\'][^"\']+["\']', caseSensitive: false),
      RegExp(r'token\s*[:=]\s*["\'][a-zA-Z0-9]{20,}["\']', caseSensitive: false),
    ];

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        for (final pattern in secretPatterns) {
          if (pattern.hasMatch(content)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Counts TODO/FIXME comments in code.
  Future<int> _countTodos() async {
    final libDir = Directory('lib');
    if (!await libDir.exists()) return 0;

    var count = 0;
    final pattern = RegExp(r'//\s*(TODO|FIXME):', caseSensitive: false);

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        count += pattern.allMatches(content).length;
      }
    }

    return count;
  }

  /// Parses issue count from analyzer output.
  int _parseIssueCount(String output) {
    final match = RegExp(r'(\d+)\s+issue').firstMatch(output);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  /// Prints analysis summary.
  void _printSummary(int totalIssues, bool hasErrors) {
    final status = hasErrors ? '❌ Failed' : '✅ Passed';
    final statusColor = hasErrors ? '\x1B[31m' : '\x1B[32m';

    stdout.writeln('''

╔═══════════════════════════════════════════════════════════════╗
║                    Analysis Summary                           ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Status:  $statusColor$status\x1B[0m${' ' * (51 - status.length)}║
║  Issues:  $totalIssues${' ' * (53 - totalIssues.toString().length)}║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
''');
  }
}

/// Result of analysis run.
class _AnalyzeResult {
  const _AnalyzeResult({
    required this.issues,
    required this.hasErrors,
  });

  final int issues;
  final bool hasErrors;
}
