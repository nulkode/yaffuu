import 'package:yaffuu/logic/managers/managers.dart';
export 'bitrate.dart';
export 'resolution.dart';

enum ArgumentType {
  global,
  input,
  inputFile,
  output,
  outputFile,
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

  bool isCompatible(BaseFFmpegManager manager);
  List<Argument> toArguments(BaseFFmpegManager manager);
}

