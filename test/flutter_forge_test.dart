/// FlutterForge comprehensive test suite.
///
/// Tests for all major components including architecture patterns,
/// utilities, and CLI functionality.
library;

import 'package:flutter_test/flutter_test.dart';

import 'src/architecture_test.dart' as architecture;
import 'src/utils_test.dart' as utils;
import 'src/storage_test.dart' as storage;
import 'src/networking_test.dart' as networking;

void main() {
  group('FlutterForge Tests', () {
    group('Architecture', architecture.main);
    group('Utils', utils.main);
    group('Storage', storage.main);
    group('Networking', networking.main);
  });
}
