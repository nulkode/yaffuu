import 'package:yaffuu/domain/models/media.dart';
import 'package:yaffuu/domain/models/ffmpeg_info.dart';

class CompatibilityContext {
  final FFmpegInfo ffmpegInfo;
  final MediaFile mediaFile;

  CompatibilityContext(this.ffmpegInfo, this.mediaFile);
}
