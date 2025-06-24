// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/models/progress.dart';
import 'package:yaffuu/domain/output_files_service.dart';
import 'package:yaffuu/domain/logger.dart';
import 'package:yaffuu/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/ffmpeg/operations/operations.dart';
import 'package:yaffuu/main.dart';

class SoftwareEngine extends FFmpegEngine {

  // ignore: unused_field
  XFile? _file;
  XFile? _lastOutput;

  SoftwareEngine();

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

    // TODO: use the output manager to handle output files
    final tempOutputPath = '';
    final stream = run(arguments, tempOutputPath);

    await for (final rawProgress in stream) {
      yield Progress.fromRaw(rawProgress);
    }

    final tempFile = File(tempOutputPath);
    if (await tempFile.exists()) {
      final managedFile =
          await getIt<OutputFileManager>().saveOutputFile(tempFile);
      _lastOutput = XFile(managedFile.path);

      await tempFile.delete();
    }
  }

  @override
  void setFile(XFile file) {
    _file = file;
  }
}
