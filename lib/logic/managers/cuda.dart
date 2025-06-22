import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/logic/classes/progress.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class CUDAManager extends BaseFFmpegManager {
  @override
  AccelerationInformation get acceleration => AccelerationInformation(
        id: 'cuda',
        displayName: 'NVIDIA CUDA',
        implemented: false,
      );

  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;
  // ignore: unused_field
  XFile? _file;
  XFile? _lastOutput;

  CUDAManager(this._ffmpegInfo);

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
    // TODO: Check if NVIDIA CUDA is available
    // This would typically involve checking:
    // 1. NVIDIA GPU presence
    // 2. CUDA drivers installed
    // 3. FFmpeg built with NVENC/NVDEC support
    // 4. Compatible GPU architecture (Pascal or newer for modern codecs)
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
