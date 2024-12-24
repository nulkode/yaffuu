import 'package:yaffuu/logic/classes/media.dart';
import 'package:yaffuu/logic/ffmpeg.dart';

class CompatibilityContext {
  final FFmpegInfo ffmpegInfo;
  final MediaFile mediaFile;

  CompatibilityContext(this.ffmpegInfo, this.mediaFile);
}
