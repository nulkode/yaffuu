import 'dart:collection';

import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/parsing.dart';
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

  CUDAManager(this._ffmpegInfo) {
    if (!isCompatible()) {
      throw FFmpegNotCompatibleException();
    }
  }

  @override
  Stream<double> get progress async* {
    throw UnimplementedError();
  }

  @override
  bool isCompatible() {
    throw UnimplementedError();
  }

  @override
  bool isOperationCompatible(Operation operation) {
    throw UnimplementedError();
  }

  @override
  void addOperation(Operation operation) {
    throw UnimplementedError();
  }
}
