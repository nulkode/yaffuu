abstract class Operation {}

class BitrateChangeOperation {
  final int video;
  final int audio;

  BitrateChangeOperation({
    required this.video,
    required this.audio,
  });
}

class ResolutionChangeOperation {
  final int width;
  final int height;

  ResolutionChangeOperation({
    required this.width,
    required this.height,
  });
}
