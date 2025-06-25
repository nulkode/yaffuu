import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';

class SoftwareEngine extends FFmpegEngine {
  XFile? _file;
  MediaFile? _mediaFile;

  HwAccel hwAccel = HwAccel.none;

  SoftwareEngine();

  @override
  XFile? get file => _file;

  @override
  MediaFile? get mediaFile => _mediaFile;

  @override
  Future<void> setInputFile(XFile file) async {
    _file = file;
    _mediaFile = await getMediaFileInfo();
    // TODO: check if the file is compatible with this engine
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

    // TODO: use the output manager to handle output files
    final stream = run(arguments);

    await for (final rawProgress in stream) {
      yield rawProgress;
    }
  }
}
