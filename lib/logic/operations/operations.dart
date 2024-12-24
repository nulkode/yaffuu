import 'package:yaffuu/logic/classes/compatibility.dart';
export 'bitrate.dart';
export 'resolution.dart';

enum ArgumentType {
  global,
  input,
  inputFile,
  output,
  outputFormat,
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

enum OperationTag {
  image('Image'),
  video('Video'),
  audio('Audio'),
  format('Format'),
  other('Other');

  final String displayName;

  const OperationTag(this.displayName);
}

abstract class Operation {
  final OperationType type = OperationType.all;
  final List<OperationTag> tags = const [OperationTag.other];

  bool isCompatible(CompatibilityContext context);

  List<Argument> toArguments();
}
