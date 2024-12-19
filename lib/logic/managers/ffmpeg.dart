// ignore_for_file: prefer_final_fields

import 'dart:collection';

import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';
import 'package:yaffuu/logic/parsing.dart';

class FFmpegManager extends BaseFFmpegManager {
  // ignore: unused_field
  final Queue<Operation> _operations = Queue<Operation>();
  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;

  FFmpegManager(this._ffmpegInfo) {
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
