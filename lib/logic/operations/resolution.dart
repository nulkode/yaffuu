import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class ResolutionChangeOperation implements Operation {
  @override
  final OperationType type = OperationType.visual;
  final int width;
  final int height;

  ResolutionChangeOperation({
    required this.width,
    required this.height,
  });

  @override
  List<Argument> toArguments(FFmpegManager manager) {
    return [
      Argument(
        type: ArgumentType.videoFilter,
        value: 'scale=$width:$height',
      ),
    ];
  }
}
