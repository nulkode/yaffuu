import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/ffmpeg_info.dart';

class CompatibilityContext {
  final FFmpegInfo ffmpegInfo;
  final MediaFile mediaFile;

  CompatibilityContext(this.ffmpegInfo, this.mediaFile);
}
