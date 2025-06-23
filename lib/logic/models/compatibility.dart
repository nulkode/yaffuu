import 'package:yaffuu/logic/models/media.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';

class CompatibilityContext {
  final FFmpegInfo ffmpegInfo;
  final MediaFile mediaFile;

  CompatibilityContext(this.ffmpegInfo, this.mediaFile);
}
