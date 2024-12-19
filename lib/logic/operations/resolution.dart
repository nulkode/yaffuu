import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/managers/managers.dart';
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
  bool isCompatible(BaseFFmpegManager manager) {
    return true;
  }

  @override
  List<Argument> toArguments(BaseFFmpegManager manager) {
    if (!isCompatible(manager)) {
      throw OperationNotCompatibleException('Resolution change operation is not compatible with ${manager.acceleration.displayName}.');
    }
    
    return [
      Argument(
        type: ArgumentType.videoFilter,
        value: 'scale=$width:$height',
      ),
    ];
  }

  @override
  String toString() {
    return 'Change resolution to ${width}x$height.';
  }
}
