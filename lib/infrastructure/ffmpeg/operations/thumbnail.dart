import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/compatibility.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';

class VideoToImageOperation implements Operation {
  @override
  final OperationType type = OperationType.video;
  Duration? position;

  VideoToImageOperation({
    this.position,
  });

  @override
  bool isCompatible(CompatibilityContext context) {
    return true;
  }

  @override
  List<Argument> toArguments([FFmpegEngine? engine]) {
    List<Argument> baseArgs = [
      if (position != null)
        Argument(
          type: ArgumentType.output,
          value: '-ss ${position!.inSeconds}',
        ),
      Argument(
        type: ArgumentType.output,
        value: '-vframes 1',
      ),
      Argument(
        type: ArgumentType.output,
        value: '-vf scale=\'min(320,iw)\':-2',
      ),
      Argument(
        type: ArgumentType.outputFormat,
        value: 'image2',
      ),
      Argument(
        type: ArgumentType.outputExtension,
        value: '.jpg',
      ),
    ];

    if (engine != null) {
      switch (engine.hwAccel) {
        case HwAccel.none:
          break;
      }
    }

    return baseArgs;
  }

  @override
  String toString() {
    // TODO: check if this is the correct format
    if (position != null) {
      final hours = position!.inHours.toString().padLeft(2, '0');
      final minutes = (position!.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (position!.inSeconds % 60).toString().padLeft(2, '0');
      final milliseconds =
          (position!.inMilliseconds % 1000).toString().padLeft(3, '0');
      return 'Video to image at $hours:$minutes:$seconds.$milliseconds';
    } else {
      return 'Video to image';
    }
  }
}
