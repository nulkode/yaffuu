class Progress {
  double fps;
  Duration outTime;
  int size;

  Progress._({
    required this.fps,
    required this.outTime,
    required this.size,
  });

  // TODO: ai generated code, revise
  factory Progress.parse(List<String> lines) {
    final fpsRegex = RegExp(r'fps=\s*([\d.]+)');
    final sizeRegex = RegExp(r'size=\s*(\d+)');
    final durationRegex = RegExp(r'out_time_ms=\s*([\d.]+)');

    Duration outTime = Duration.zero;
    double fps = 0;
    int size = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (outTime == Duration.zero && durationRegex.hasMatch(line)) {
        outTime = Duration(
            milliseconds: int.parse(durationRegex.firstMatch(line)!.group(1)!));
      } else if (fps == 0 && fpsRegex.hasMatch(line)) {
        fps = double.parse(fpsRegex.firstMatch(line)!.group(1)!);
      } else if (size == 0 && sizeRegex.hasMatch(line)) {
        size = int.parse(sizeRegex.firstMatch(line)!.group(1)!);
      } else if (fps == 0 && fpsRegex.hasMatch(line)) {
        fps = double.parse(fpsRegex.firstMatch(line)!.group(1)!);
      } else if (size == 0 && sizeRegex.hasMatch(line)) {
        size = int.parse(sizeRegex.firstMatch(line)!.group(1)!);
      }
    }

    return Progress._(
      outTime: outTime,
      fps: fps,
      size: size,
    );
  }
}
