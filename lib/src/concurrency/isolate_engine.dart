import 'dart:isolate';

/// FlutterForge: High-Performance Isolate Engine
/// 
/// Offloads heavy computation (JSON parsing, Matrix math) to background 
/// Isolates to guarantee zero frame drops on the main UI thread.
class IsolateEngine {
  static final IsolateEngine instance = IsolateEngine._internal();
  IsolateEngine._internal();

  Future<dynamic> computeHeavyTask(Function task, dynamic message) async {
    print("🚀 [FlutterForge] Task offloaded to background Isolate.");
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntry, [receivePort.sendPort, task, message]);
    return await receivePort.first;
  }

  static void _isolateEntry(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final Function task = args[1];
    final dynamic message = args[2];
    final result = task(message);
    sendPort.send(result);
  }
}
