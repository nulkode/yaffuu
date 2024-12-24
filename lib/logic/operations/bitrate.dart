import 'dart:math';

import 'package:yaffuu/logic/classes/compatibility.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class BitrateOperation implements Operation {
  @override
  final OperationType type = OperationType.moving;
  @override
  final List<OperationTag> tags = [OperationTag.audio, OperationTag.video];  
  final int? video;
  final int? audio;

  BitrateOperation({
    this.video,
    this.audio,
  });

  @override
  bool isCompatible(CompatibilityContext context) {
    return true;
  }

  @override
  List<Argument> toArguments() {
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

  @override
  String toString() {
    return video != null && audio != null
        ? 'Change video bitrate to ${formatBytes(video!)}/s and audio bitrate to ${formatBytes(audio!)}/s.'
        : video != null
            ? 'Change video bitrate to ${formatBytes(video!)}/s.'
            : audio != null
                ? 'Change audio bitrate to ${formatBytes(audio!)}/s.'
                : '';
  }
}

String formatBytes(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "kB", "MB", "GB", "TB"];
  var i = (bytes == 0) ? 0 : (log(bytes) / log(1000)).floor();
  var size = bytes / (pow(1000, i));
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}
