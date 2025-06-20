import 'package:yaffuu/logic/classes/compatibility.dart';
export 'bitrate.dart';
export 'resolution.dart';

enum ArgumentType {
  global,
  input,
  inputFile,
  output,
  outputFormat,
  outputExtension,
  videoFilter,
  audioFilter,
}

class Argument {
  final ArgumentType type;
  final String value;

  Argument({
    required this.type,
    required this.value,
  });
}

enum OperationType {
  video,
  audio,
  image,
  visual, // video and image
  moving, // video and audio
  all
}

abstract class Operation {
  final OperationType type = OperationType.all;

  bool isCompatible(CompatibilityContext context);

  List<Argument> toArguments();
}
