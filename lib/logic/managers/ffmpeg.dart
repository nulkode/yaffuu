// ignore_for_file: prefer_final_fields

import 'dart:collection';

import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';
import 'package:yaffuu/logic/ffmpeg.dart';

class FFmpegManager extends BaseFFmpegManager {
  // ignore: unused_field
  final Queue<Operation> _operations = Queue<Operation>();
  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;

  FFmpegManager(this._ffmpegInfo);

  @override
  Stream<double> get progress async* {
    throw UnimplementedError();
  }

  @override
  Future<bool> isCompatible() {
    // TODO: check versions, libraries, configurations, etc.
    return Future.value(true);
  }

  @override
  Future<bool> isOperationCompatible(Operation operation) {
    return Future.value(true);
  }

  @override
  void addOperation(Operation operation) async {
    _operations.add(operation);
  }
}
