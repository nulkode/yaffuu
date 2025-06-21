class RawProgress {
  int frame;
  double fps;
  int size;

  RawProgress._({
    required this.frame,
    required this.fps,
    required this.size,
  });

  // TODO: ai generated code, revise
  factory RawProgress.parse(List<String> lines) {
    final frameRegex = RegExp(r'frame=\s*(\d+)');
    final fpsRegex = RegExp(r'fps=\s*([\d.]+)');
    final sizeRegex = RegExp(r'size=\s*(\d+)');

    int frame = 0;
    double fps = 0;
    int size = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (frame == 0 && frameRegex.hasMatch(line)) {
        frame = int.parse(frameRegex.firstMatch(line)!.group(1)!);
      } else if (fps == 0 && fpsRegex.hasMatch(line)) {
        fps = double.parse(fpsRegex.firstMatch(line)!.group(1)!);
      } else if (size == 0 && sizeRegex.hasMatch(line)) {
        size = int.parse(sizeRegex.firstMatch(line)!.group(1)!);
      }
    }

    return RawProgress._(
      frame: frame,
      fps: fps,
      size: size,
    );
  }
}


class Progress extends RawProgress {
  Progress._({
    required super.frame,
    required super.fps,
    required super.size,
  }) : super._();

  factory Progress.fromRaw(RawProgress raw) {
    return Progress._(
      frame: raw.frame,
      fps: raw.fps,
      size: raw.size,
    );
  }
}
