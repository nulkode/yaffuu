import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class BitrateOperation implements Operation {
  @override
  final OperationType type = OperationType.moving;
  final int? video;
  final int? audio;

  BitrateOperation({
    this.video,
    this.audio,
  });

  @override
  List<Argument> toArguments(FFmpegManager manager) {
    return [
      if (video != null)
        Argument(
          type: ArgumentType.output,
          value: '-b:v $video',
        ),
      if (audio != null)
        Argument(
          type: ArgumentType.output,
          value: '-b:a $audio',
        ),
    ];
  }
}
