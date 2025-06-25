import 'package:yaffuu/infrastructure/ffmpeg/models/compatibility.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';

enum VideoCodec {
  h264,
  h265,
  av1,
}

enum EncodingPreset {
  ultrafast,
  superfast,
  veryfast,
  faster,
  fast,
  medium,
  slow,
  slower,
  veryslow,
  placebo;

  String get value {
    switch (this) {
      case EncodingPreset.ultrafast:
        return 'ultrafast';
      case EncodingPreset.superfast:
        return 'superfast';
      case EncodingPreset.veryfast:
        return 'veryfast';
      case EncodingPreset.faster:
        return 'faster';
      case EncodingPreset.fast:
        return 'fast';
      case EncodingPreset.medium:
        return 'medium';
      case EncodingPreset.slow:
        return 'slow';
      case EncodingPreset.slower:
        return 'slower';
      case EncodingPreset.veryslow:
        return 'veryslow';
      case EncodingPreset.placebo:
        return 'placebo';
    }
  }
}

class VideoEncodeOperation implements Operation {
  @override
  final OperationType type = OperationType.video;

  final VideoCodec codec;
  final int? bitrate; // in kbps
  final EncodingPreset? preset; // encoding preset

  VideoEncodeOperation({
    required this.codec,
    this.bitrate,
    this.preset,
  });

  @override
  bool isCompatible(CompatibilityContext context) {
    return true;
  }

  @override
  List<Argument> toArguments([FFmpegEngine? engine]) {
    List<Argument> args = [];

    args.addAll(_getSoftwareArguments());

    if (bitrate != null) {
      args.add(Argument(
        type: ArgumentType.output,
        value: '-b:v ${bitrate}k',
      ));
    }

    return args;
  }

  List<Argument> _getSoftwareArguments() {
    List<Argument> args = [];

    switch (codec) {
      case VideoCodec.h264:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v libx264',
        ));
        if (preset != null) {
          args.add(Argument(
            type: ArgumentType.output,
            value: '-preset ${preset!.value}',
          ));
        }
        break;
      case VideoCodec.h265:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v libx265',
        ));
        if (preset != null) {
          args.add(Argument(
            type: ArgumentType.output,
            value: '-preset ${preset!.value}',
          ));
        }
        break;
      case VideoCodec.av1:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v libaom-av1',
        ));
        break;
    }

    return args;
  }

  @override
  String toString() {
    return 'VideoEncode(codec: $codec, bitrate: $bitrate, preset: $preset)';
  }
}
