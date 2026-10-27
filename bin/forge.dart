import 'dart:io';

import 'package:flutter_forge/src/cli/forge_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runForge(arguments);
}
