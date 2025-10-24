import 'dart:io';

import 'package:yaffuu/domain/media/runtime.dart';
// TODO: make them infra river events
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

/// Service for retrieving and caching FFmpeg build information.
class FFmpegInformationProvider {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];
  RuntimeInformation? _cachedInfo;

  /// Gets FFmpeg information, using cached result if available.
  Future<RuntimeInformation> getFFmpegInfo() async {
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    try {
      final versionResult = await Process.run('ffmpeg', ['-version']);
      final hwAccelResult =
          await Process.run('ffmpeg', [..._quietVerbose, '-hwaccels']);

      if (versionResult.exitCode == 0 && hwAccelResult.exitCode == 0) {
        final info = parse(
          versionResult.stdout,
          hardwareAccelerationMethods: hwAccelResult.stdout,
        );

        _cachedInfo = info;
        return info;
      } else {
        throw FFmpegException('An unknown error occurred.');
      }
    } on ProcessException {
      throw FFmpegNotFoundException();
    } on Exception catch (e) {
      logger.e('An unknown error occurred: $e');
      throw FFmpegException('An unknown error occurred: $e');
    }
  }

  static RuntimeInformation parse(
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

    return RuntimeInformation(
      version: version,
      copyright: copyright,
      builtWith: builtWith,
      configuration: configuration,
      libraries: libraries,
      hardwareAccelerationMethods: hardwareMethods,
    );
  }


  /// Clears the cached FFmpeg information.
  void clearCache() {
    _cachedInfo = null;
  }
}
