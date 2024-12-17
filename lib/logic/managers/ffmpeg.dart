import 'dart:collection';

import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/operations/operations.dart';

abstract class BaseFFmpegManager {
  FFmpegInfo _ffmpegInfo;
  Queue<Operation> _operations = Queue<Operation>();

  BaseFFmpegManager(this._ffmpegInfo);

  Stream<double> get progress;

  bool isCompatible();

  bool isOperationCompatible(Operation operation);

  void addOperation(Operation operation);
}

class FFmpegManager extends BaseFFmpegManager {
  FFmpegManager(FFmpegInfo ffmpegInfo) : super(ffmpegInfo) {
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
    // TODO: check versions, libraries, configurations, etc.
    return true;
  }

  @override
  bool isOperationCompatible(Operation operation) {
    return true;
  }

  @override
  void addOperation(Operation operation) {
    if (isOperationCompatible(operation)) {
      _operations.add(operation);
    } else {
      throw OperationNotCompatibleException('Operation is not compatible');
    }
  }
}
