import 'dart:collection';

import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class CUDAManager extends BaseFFmpegManager {
  @override
  Acceleration get acceleration => Acceleration(
        id: 'cuda',
        displayName: 'CUDA',
        implemented: false,
      );
  // ignore: unused_field
  final Queue<Operation> _operations = Queue<Operation>();
  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;

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
  void addOperation(Operation operation) {
    throw UnimplementedError();
  }
}
