import 'package:yaffuu/logic/classes/compatibility.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class VideoToImageOperation implements Operation {
  @override
  final OperationType type = OperationType.video;
  @override
  final List<OperationTag> tags = [OperationTag.video];  
  final Duration? position;

  VideoToImageOperation({
    this.position,
  });

  @override
  bool isCompatible(CompatibilityContext context) {
    return true;
  }

  @override
  List<Argument> toArguments() {
    return [
      if (position != null)
        Argument(
          type: ArgumentType.output,
          value: '-ss ${position!.inSeconds}', // TODO: check how decimals are handled
        ),
      Argument(
        type: ArgumentType.output,
        value: '-vframes 1',
      ),
      Argument(
        type: ArgumentType.outputFormat,
        value: 'image2',
      )
    ];
  }

  @override
  String toString() {
    // TODO: check if this is the correct format
    if (position != null) {
      final hours = position!.inHours.toString().padLeft(2, '0');
      final minutes = (position!.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (position!.inSeconds % 60).toString().padLeft(2, '0');
      final milliseconds = (position!.inMilliseconds % 1000).toString().padLeft(3, '0');
      return 'Video to image at $hours:$minutes:$seconds.$milliseconds';
    } else {
      return 'Video to image';
    }
  }
}
