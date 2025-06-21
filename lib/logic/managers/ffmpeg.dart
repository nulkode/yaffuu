// ignore_for_file: prefer_final_fields

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
  /// Gets the last output file from the most recent operation
  XFile? get lastOutput => _lastOutput;

  /// Clears the last output file reference
  void clearLastOutput() {
    _lastOutput = null;
  }

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
  Stream<Progress> execute(Operation operation) async* {
    logger.d('Executing operation: ${operation.runtimeType}');

    if (_file == null) throw Exception('File is not set.');

    final appInfo = getIt<AppInfo>();

    final arguments = operation.toArguments();

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
    }    final outputPath =
        '${appInfo.dataDir.path}/${DateTime.now().millisecondsSinceEpoch}_${_file!.name}${outputExtensionArgs.isNotEmpty ? outputExtensionArgs.first.value : ''}';

    final stream = FFService.execute(arguments, outputPath);

    await for (final rawProgress in stream) {
      yield Progress.fromRaw(rawProgress);
    }
    
    // Store the output file after successful completion
    _lastOutput = XFile(outputPath);
  }

  @override
  void setFile(XFile file) {
    _file = file;
  }
}
