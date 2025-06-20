// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaffuu/logic/classes/progress.dart';
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
  Stream<Progress> execute(Operation operation) async* {
    if (_file == null) throw Exception('File is not set.');

    final appInfo = getIt<AppInfo>();

    final arguments = operation.toArguments();

    final outputExtensionArgs = arguments
        .where((element) => element.type == ArgumentType.outputExtension);
    if (outputExtensionArgs.isNotEmpty && outputExtensionArgs.length > 1)
      throw Exception('Multiple output extensions are not supported.');

    final outputPath =
        '${appInfo.dataDir.path}/${DateTime.now().millisecondsSinceEpoch}_${_file!.name}${outputExtensionArgs.isNotEmpty ? outputExtensionArgs.first.value : ''}';

    final mediaInfo = await FFService.probeFile(_file!.path);

    final output = await FFService.execute(arguments, outputPath);
  }

  @override
  void setFile(XFile file) {
    _file = file;
  }
}
