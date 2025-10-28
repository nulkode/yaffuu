import 'package:yaffuu/domain/contracts/ffmpeg/media/container.dart';
import 'package:yaffuu/domain/contracts/ffmpeg/runtime/runtime_info.dart';

class CompatibilityContext {
  final RuntimeInformation runtimeInformation;
  final MediaContainer mediaContainer;

  CompatibilityContext(this.runtimeInformation, this.mediaContainer);
}
