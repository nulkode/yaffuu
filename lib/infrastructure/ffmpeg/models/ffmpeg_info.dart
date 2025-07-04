class FFmpegInfo {
  final String version;
  final String copyright;
  final String builtWith;
  final List<String> configuration;
  final Map<String, Map<String, String>> libraries;
  final List<String>? hardwareAccelerationMethods;

  FFmpegInfo({
    required this.version,
    required this.copyright,
    required this.builtWith,
    required this.configuration,
    required this.libraries,
    this.hardwareAccelerationMethods,
  });

  static FFmpegInfo parse(
    String ffmpegHeader, {
    String? hardwareAccelerationMethods,
  }) {
    final headerLines = ffmpegHeader.split('\n');
    final versionRegex = RegExp(r'^ffmpeg version (\S+) (Copyright .+)$');
    final builtWithRegex = RegExp(r'^built with (.+)$');
    final configRegex = RegExp(r'^configuration: (.+)$');
    final libraryRegex =
        RegExp(r'^(\S+)\s+(\d+\.\s*\d+\.\s*\d+)\s*/\s*(\d+\.\s*\d+\.\s*\d+)$');

    String version = '';
    String copyright = '';
    String builtWith = '';
    List<String> configuration = [];
    Map<String, Map<String, String>> libraries = {};

    for (var i = 0; i < headerLines.length; i++) {
      final line = headerLines[i].trim();
      if (version.isEmpty && versionRegex.hasMatch(line)) {
        final match = versionRegex.firstMatch(line)!;
        version = match.group(1)!;
        copyright = match.group(2)!;
      } else if (builtWith.isEmpty && builtWithRegex.hasMatch(line)) {
        builtWith = builtWithRegex.firstMatch(line)!.group(1)!.trim();
      } else if (configRegex.hasMatch(line)) {
        configuration = configRegex
            .firstMatch(line)!
            .group(1)!
            .split(' ')
            .map((e) => e.trim())
            .toList();
      } else if (libraryRegex.hasMatch(line)) {
        final match = libraryRegex.firstMatch(line)!;
        final libName = match.group(1)!;
        final compiledVersion = match.group(2)!.replaceAll(' ', '');
        final runtimeVersion = match.group(3)!.replaceAll(' ', '');
        libraries[libName] = {
          'compiled': compiledVersion,
          'runtime': runtimeVersion,
        };
      }
    }

    List<String>? hardwareMethods;
    if (hardwareAccelerationMethods != null) {
      hardwareMethods ??= [];
      final hwaccelLines =
          hardwareAccelerationMethods.split('\n').map((e) => e.trim()).toList();
      final hwaccelRegex = RegExp(r'^Hardware acceleration methods:');

      for (var i = 0; i < hwaccelLines.length; i++) {
        final line = hwaccelLines[i].trim();
        if (hwaccelRegex.hasMatch(line)) {
          continue;
        }

        if (line.isNotEmpty) {
          hardwareMethods.add(line);
        }
      }
    }

    return FFmpegInfo(
      version: version,
      copyright: copyright,
      builtWith: builtWith,
      configuration: configuration,
      libraries: libraries,
      hardwareAccelerationMethods: hardwareMethods,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FFmpegInfo) return false;

    return version == other.version &&
        copyright == other.copyright &&
        builtWith == other.builtWith &&
        configuration.toSet().containsAll(other.configuration) &&
        libraries.length == other.libraries.length &&
        libraries.keys.every((key) => libraries[key] == other.libraries[key]) &&
        (hardwareAccelerationMethods?.toSet() ?? {})
            .containsAll(other.hardwareAccelerationMethods ?? []);
  }

  @override
  int get hashCode {
    return Object.hash(
      version,
      copyright,
      builtWith,
      configuration,
      libraries,
      hardwareAccelerationMethods,
    );
  }
}
