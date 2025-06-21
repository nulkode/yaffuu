import 'package:yaffuu/logic/classes/compatibility.dart';
import 'package:yaffuu/logic/operations/operations.dart';
import 'package:yaffuu/logic/managers/managers.dart';

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
  List<Argument> toArguments([BaseFFmpegManager? manager]) {
    List<Argument> args = [];

    if (manager != null) {
      switch (manager.acceleration.id) {
        case 'cuda':
          args.addAll(_getCudaArguments());
          break;
        case 'quicksync':
          args.addAll(_getQuickSyncArguments());
          break;
        case 'none':
        default:
          args.addAll(_getSoftwareArguments());
          break;
      }
    } else {
      // Fallback to software encoding if no manager provided
      args.addAll(_getSoftwareArguments());
    }

    // Add common arguments
    if (bitrate != null) {
      args.add(Argument(
        type: ArgumentType.output,
        value: '-b:v ${bitrate}k',
      ));
    }

    return args;
  }

  List<Argument> _getCudaArguments() {
    List<Argument> args = [
      Argument(
        type: ArgumentType.global,
        value: '-hwaccel cuda',
      ),
      Argument(
        type: ArgumentType.global,
        value: '-hwaccel_output_format cuda',
      ),
    ];

    switch (codec) {
      case VideoCodec.h264:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v h264_nvenc',
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
          value: '-c:v hevc_nvenc',
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
          value: '-c:v av1_nvenc',
        ));
        break;
    }

    return args;
  }

  List<Argument> _getQuickSyncArguments() {
    List<Argument> args = [
      Argument(
        type: ArgumentType.global,
        value: '-hwaccel qsv',
      ),
    ];

    switch (codec) {
      case VideoCodec.h264:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v h264_qsv',
        ));
        break;
      case VideoCodec.h265:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v hevc_qsv',
        ));
        break;
      case VideoCodec.av1:
        args.add(Argument(
          type: ArgumentType.output,
          value: '-c:v av1_qsv',
        ));
        break;
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
