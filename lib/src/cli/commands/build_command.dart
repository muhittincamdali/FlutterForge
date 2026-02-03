import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_forge/src/cli/cli_runner.dart';

/// Command for building Flutter projects.
///
/// Usage: flutter_forge build <platform> [options]
///
/// Supported platforms:
/// - android: Build Android APK or App Bundle
/// - ios: Build iOS IPA
/// - web: Build web application
/// - windows: Build Windows executable
/// - macos: Build macOS application
/// - linux: Build Linux application
class BuildCommand extends Command<int> with ForgeCommandMixin {
  /// Creates a new [BuildCommand] instance.
  BuildCommand() {
    argParser
      ..addOption(
        'platform',
        abbr: 'p',
        help: 'Target platform.',
        allowed: ['android', 'ios', 'web', 'windows', 'macos', 'linux'],
      )
      ..addOption(
        'flavor',
        abbr: 'f',
        help: 'Build flavor/environment.',
        allowed: ['development', 'staging', 'production'],
        defaultsTo: 'production',
      )
      ..addOption(
        'target',
        abbr: 't',
        help: 'Main entry point file.',
        defaultsTo: 'lib/main.dart',
      )
      ..addFlag(
        'release',
        help: 'Build in release mode.',
        defaultsTo: true,
      )
      ..addFlag(
        'obfuscate',
        help: 'Obfuscate Dart code.',
        defaultsTo: true,
      )
      ..addFlag(
        'split-debug-info',
        help: 'Split debug info.',
        defaultsTo: true,
      )
      ..addOption(
        'build-number',
        help: 'Build number to use.',
      )
      ..addOption(
        'build-name',
        help: 'Build name/version to use.',
      );
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Build the Flutter project.';

  @override
  String get invocation => 'flutter_forge build [options]';

  @override
  Future<int> run() async {
    final args = argResults!;

    // Validate we're in a Flutter project
    if (!File('pubspec.yaml').existsSync()) {
      throw UsageException(
        'Not in a Flutter project. Please run from project root.',
        usage,
      );
    }

    final platform = args['platform'] as String?;
    final flavor = args['flavor'] as String;
    final target = args['target'] as String;
    final release = args['release'] as bool;
    final obfuscate = args['obfuscate'] as bool;
    final splitDebugInfo = args['split-debug-info'] as bool;
    final buildNumber = args['build-number'] as String?;
    final buildName = args['build-name'] as String?;

    // If no platform specified, detect based on OS
    final targetPlatform = platform ?? _detectPlatform();

    stdout.writeln('🔨 Building for $targetPlatform ($flavor)...\n');

    // Build command arguments
    final buildArgs = _buildFlutterArgs(
      platform: targetPlatform,
      flavor: flavor,
      target: target,
      release: release,
      obfuscate: obfuscate,
      splitDebugInfo: splitDebugInfo,
      buildNumber: buildNumber,
      buildName: buildName,
    );

    if (verbose) {
      stdout.writeln('Running: flutter ${buildArgs.join(' ')}\n');
    }

    // Pre-build checks
    await _runPreBuildChecks(targetPlatform);

    // Execute build
    final stopwatch = Stopwatch()..start();

    final process = await Process.start(
      'flutter',
      buildArgs,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;
    stopwatch.stop();

    if (exitCode == 0) {
      _printBuildSuccess(targetPlatform, stopwatch.elapsed);
      await _postBuildActions(targetPlatform, flavor);
    } else {
      _printBuildFailure(targetPlatform);
    }

    return exitCode;
  }

  /// Detects the current platform.
  String _detectPlatform() {
    if (Platform.isMacOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'android';
  }

  /// Builds Flutter command arguments.
  List<String> _buildFlutterArgs({
    required String platform,
    required String flavor,
    required String target,
    required bool release,
    required bool obfuscate,
    required bool splitDebugInfo,
    String? buildNumber,
    String? buildName,
  }) {
    final args = <String>['build'];

    // Add platform-specific build command
    switch (platform) {
      case 'android':
        args.add('appbundle'); // Use app bundle for production
        break;
      case 'ios':
        args.add('ipa');
        break;
      case 'web':
        args.add('web');
        break;
      case 'windows':
        args.add('windows');
        break;
      case 'macos':
        args.add('macos');
        break;
      case 'linux':
        args.add('linux');
        break;
    }

    // Add common options
    if (release) {
      args.add('--release');
    }

    args.addAll(['--target', target]);

    // Add flavor/environment
    args.addAll(['--dart-define', 'ENVIRONMENT=$flavor']);

    // Add obfuscation for mobile
    if (obfuscate && (platform == 'android' || platform == 'ios')) {
      args.add('--obfuscate');
      if (splitDebugInfo) {
        args.addAll(['--split-debug-info', 'build/debug-info']);
      }
    }

    // Add build version info
    if (buildNumber != null) {
      args.addAll(['--build-number', buildNumber]);
    }
    if (buildName != null) {
      args.addAll(['--build-name', buildName]);
    }

    return args;
  }

  /// Runs pre-build checks for the target platform.
  Future<void> _runPreBuildChecks(String platform) async {
    stdout.writeln('🔍 Running pre-build checks...');

    // Check Flutter version
    final flutterVersion = await Process.run('flutter', ['--version']);
    if (verbose) {
      stdout.writeln(flutterVersion.stdout);
    }

    // Run flutter doctor for the target platform
    final doctorResult = await Process.run(
      'flutter',
      ['doctor', '-v'],
    );

    if (doctorResult.exitCode != 0) {
      stdout.writeln('⚠️ Some Flutter doctor checks failed. Build may fail.');
    }

    // Platform-specific checks
    switch (platform) {
      case 'ios':
        await _checkIOSRequirements();
        break;
      case 'android':
        await _checkAndroidRequirements();
        break;
      case 'web':
        await _checkWebRequirements();
        break;
    }

    stdout.writeln('✅ Pre-build checks passed\n');
  }

  /// Checks iOS build requirements.
  Future<void> _checkIOSRequirements() async {
    if (!Platform.isMacOS) {
      throw UsageException(
        'iOS builds require macOS.',
        usage,
      );
    }

    // Check for Xcode
    final xcodeResult = await Process.run('xcodebuild', ['-version']);
    if (xcodeResult.exitCode != 0) {
      throw UsageException(
        'Xcode is required for iOS builds.',
        usage,
      );
    }

    // Check for CocoaPods
    final podResult = await Process.run('pod', ['--version']);
    if (podResult.exitCode != 0) {
      stdout.writeln('⚠️ CocoaPods not found. Installing...');
      await Process.run('gem', ['install', 'cocoapods']);
    }
  }

  /// Checks Android build requirements.
  Future<void> _checkAndroidRequirements() async {
    // Check for Android SDK
    final androidHome = Platform.environment['ANDROID_HOME'] ??
        Platform.environment['ANDROID_SDK_ROOT'];

    if (androidHome == null || androidHome.isEmpty) {
      stdout.writeln('⚠️ ANDROID_HOME not set. Build may fail.');
    }
  }

  /// Checks web build requirements.
  Future<void> _checkWebRequirements() async {
    // Check for Chrome (for testing)
    if (Platform.isMacOS) {
      final chromeExists = await Directory(
        '/Applications/Google Chrome.app',
      ).exists();
      if (!chromeExists && verbose) {
        stdout.writeln('ℹ️ Chrome not found. Web testing may be limited.');
      }
    }
  }

  /// Performs post-build actions.
  Future<void> _postBuildActions(String platform, String flavor) async {
    stdout.writeln('\n📦 Running post-build actions...');

    // Copy artifacts to a consistent location
    final outputDir = Directory('build/outputs/$platform/$flavor');
    await outputDir.create(recursive: true);

    switch (platform) {
      case 'android':
        await _copyAndroidArtifacts(flavor, outputDir);
        break;
      case 'ios':
        await _copyIOSArtifacts(flavor, outputDir);
        break;
      case 'web':
        await _copyWebArtifacts(outputDir);
        break;
    }

    stdout.writeln('✅ Artifacts copied to ${outputDir.path}');
  }

  /// Copies Android build artifacts.
  Future<void> _copyAndroidArtifacts(String flavor, Directory outputDir) async {
    final bundlePath = 'build/app/outputs/bundle/release/app-release.aab';
    final apkPath = 'build/app/outputs/flutter-apk/app-release.apk';

    if (await File(bundlePath).exists()) {
      await File(bundlePath).copy('${outputDir.path}/app-$flavor.aab');
    }
    if (await File(apkPath).exists()) {
      await File(apkPath).copy('${outputDir.path}/app-$flavor.apk');
    }
  }

  /// Copies iOS build artifacts.
  Future<void> _copyIOSArtifacts(String flavor, Directory outputDir) async {
    final ipaDir = Directory('build/ios/ipa');
    if (await ipaDir.exists()) {
      await for (final file in ipaDir.list()) {
        if (file.path.endsWith('.ipa')) {
          final fileName = file.path.split('/').last;
          await File(file.path).copy('${outputDir.path}/$fileName');
        }
      }
    }
  }

  /// Copies web build artifacts.
  Future<void> _copyWebArtifacts(Directory outputDir) async {
    final webDir = Directory('build/web');
    if (await webDir.exists()) {
      await Process.run('cp', ['-r', webDir.path, outputDir.path]);
    }
  }

  /// Prints build success message.
  void _printBuildSuccess(String platform, Duration elapsed) {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    stdout.writeln('''

╔═══════════════════════════════════════════════════════════════╗
║                     🎉 Build Successful!                      ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Platform:    $platform${' ' * (48 - platform.length)}║
║  Duration:    ${minutes}m ${seconds}s${' ' * (46 - '${minutes}m ${seconds}s'.length)}║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
''');
  }

  /// Prints build failure message.
  void _printBuildFailure(String platform) {
    stderr.writeln('''

╔═══════════════════════════════════════════════════════════════╗
║                     ❌ Build Failed                           ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Platform: $platform${' ' * (51 - platform.length)}║
║                                                               ║
║  Tips:                                                        ║
║  • Run 'flutter doctor' to check setup                        ║
║  • Check the build output above for errors                    ║
║  • Try 'flutter clean' and rebuild                            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
''');
  }
}
