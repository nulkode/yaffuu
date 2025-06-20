import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class CUDAManager extends BaseFFmpegManager {
  @override
  AccelerationInformation get acceleration => AccelerationInformation(
        id: 'cuda',
        displayName: 'CUDA',
        implemented: false,
      );
  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;
  // ignore: unused_field
  XFile? _file;

  CUDAManager(this._ffmpegInfo);

  @override
  Stream<double> get progress async* {
    throw UnimplementedError();
  }

  @override
  Future<bool> isCompatible() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isOperationCompatible(Operation operation) {
    throw UnimplementedError();
  }

  @override
  void execute(Operation operation) {
    throw UnimplementedError();
  }

    @override
  void setFile(XFile file) {
    _file = file;
  }
}
