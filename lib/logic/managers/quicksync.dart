import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/logic/models/progress.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class QuickSyncManager extends BaseFFmpegManager {
  @override
  AccelerationInformation get acceleration => AccelerationInformation(
        id: 'quicksync',
        displayName: 'Intel Quick Sync',
        implemented: false,
      );

  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;
  // ignore: unused_field
  XFile? _file;
  XFile? _lastOutput;

  QuickSyncManager(this._ffmpegInfo);

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
