import 'package:yaffuu/domain/media/container.dart';
import 'package:yaffuu/domain/media/runtime.dart';

class CompatibilityContext {
  final RuntimeInformation runtimeInformation;
  final MediaContainer mediaContainer;

  CompatibilityContext(this.runtimeInformation, this.mediaContainer);
}
