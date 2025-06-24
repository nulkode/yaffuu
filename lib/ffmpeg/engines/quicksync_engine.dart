import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/models/progress.dart';
import 'package:yaffuu/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/ffmpeg/operations/operations.dart';

class QuickSyncEngine extends FFmpegEngine {
  @override
  EngineInformation get acceleration => EngineInformation(
        id: 'quicksync',
        displayName: 'Intel Quick Sync',
        implemented: false,
      );

  // ignore: unused_field
  XFile? _file;
  XFile? _lastOutput;

  QuickSyncEngine();

  @override
  XFile? get lastOutput => _lastOutput;

  @override
  void clearLastOutput() {
    _lastOutput = null;
  }

  @override
  Stream<double> get progress async* {
    throw UnimplementedError();
  }

  @override
  Future<bool> isCompatible() async {
    // TODO: Check if Intel Quick Sync is available
    // This would typically involve checking:
    // 1. Intel GPU presence
    // 2. FFmpeg built with QSV support
    // 3. Driver compatibility
    return false; // Not implemented yet
  }

  @override
  Future<bool> isOperationCompatible(Operation operation) async {
    if (!await isCompatible()) return false;

    return operation.type == OperationType.video ||
        operation.type == OperationType.moving ||
        operation.type == OperationType.visual ||
        operation.type == OperationType.all;
  }

  @override
  Stream<Progress> execute(Operation operation) {
    throw UnimplementedError();
  }

  @override
  void setFile(XFile file) {
    _file = file;
  }
}
