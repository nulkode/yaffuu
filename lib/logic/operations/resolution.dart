import 'package:yaffuu/logic/classes/compatibility.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class ResolutionChangeOperation implements Operation {
  @override
  final OperationType type = OperationType.visual;
  @override
  final List<OperationTag> tags = [OperationTag.image];
  final int width;
  final int height;

  ResolutionChangeOperation({
    required this.width,
    required this.height,
  });

  @override
  bool isCompatible(CompatibilityContext context) {
    return true;
  }

  @override
  List<Argument> toArguments() {
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
