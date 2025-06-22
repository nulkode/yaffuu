// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/logic/classes/progress.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/main.dart';
import 'package:yaffuu/ui/screens/loading.dart';

class FFmpegManager extends BaseFFmpegManager {
  // ignore: unused_field
  final FFmpegInfo _ffmpegInfo;
  // ignore: unused_field
  XFile? _file;
  XFile? _lastOutput;

  FFmpegManager(this._ffmpegInfo);

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
  Future<bool> isCompatible() {
    return Future.value(true);
  }

  @override
  Future<bool> isOperationCompatible(Operation operation) {
    return Future.value(true);
  }

  @override
  Stream<Progress> execute(Operation operation) async* {
    logger.d('Executing operation: ${operation.runtimeType}');

    if (_file == null) throw Exception('File is not set.');

    final appInfo = getIt<AppInfo>();

    final arguments = operation.toArguments(this);

    final outputExtensionArgs = arguments
        .where((element) => element.type == ArgumentType.outputExtension);
    if (outputExtensionArgs.isNotEmpty && outputExtensionArgs.length > 1) {
      throw Exception('Multiple output extensions are not supported.');
    }

    final inputFileArg = Argument(
      type: ArgumentType.inputFile,
      value: _file!.path,
    );
    if (!arguments.contains(inputFileArg)) {
      arguments.add(inputFileArg);
    }

    final tempOutputPath =
        '${appInfo.dataDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}_${_file!.name}${outputExtensionArgs.isNotEmpty ? outputExtensionArgs.first.value : ''}';

    final stream = FFService.execute(arguments, tempOutputPath);

    await for (final rawProgress in stream) {
      yield Progress.fromRaw(rawProgress);
    }

    final tempFile = File(tempOutputPath);
    if (await tempFile.exists()) {
      final managedFile =
          await appInfo.outputFileManager.saveOutputFile(tempFile);
      _lastOutput = XFile(managedFile.path);

      await tempFile.delete();
    }
  }

  @override
  void setFile(XFile file) {
    _file = file;
  }
}
