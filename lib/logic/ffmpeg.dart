import 'dart:io';

import 'package:yaffuu/logic/classes/exception.dart';

class FFmpegInfo {
  final String version;
  final String buildWith;
  final String configuration;
  final Map<String, String> libraryVersions;
  final Map<String, String> hardwareAccelerations;

  FFmpegInfo({
    required this.version,
    required this.buildWith,
    required this.configuration,
    required this.libraryVersions,
    required this.hardwareAccelerations,
  });

  factory FFmpegInfo.parse(String versionOutput, String hwAccelOutput) {
    final lines = versionOutput.split('\n');

    String version = '';
    String buildWith = '';
    String configuration = '';
    Map<String, String> libraryVersions = {};

    for (var line in lines) {
      if (line.startsWith('ffmpeg version')) {
        version = line.trim();
      } else if (line.startsWith('built with')) {
        buildWith = line.trim();
      } else if (line.startsWith('configuration:')) {
        configuration = line.substring('configuration:'.length).trim();
      } else if (line.startsWith('lib')) {
        final components = line.trim().split(RegExp(r'\s+'));
        if (components.length >= 2) {
          final libName = components[0];
          final libVersion = components[1];
          libraryVersions[libName] = libVersion;
        }
      }
    }

    final hwAccelLines = hwAccelOutput.split('\n');
    final hwAccels = <String>[];

    bool startParsing = false;
    for (var line in hwAccelLines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line == 'Hardware acceleration methods:') {
        startParsing = true;
        continue;
      }

      if (startParsing) {
        hwAccels.add(line);
      }
    }

    final accelDescriptions = {
      'none': 'None',
      'cuda': 'NVIDIA CUDA (GPU)',
      'dxva2': 'DirectX Video Acceleration 2 (Windows)',
      'qsv': 'Intel Quick Sync Video',
      'd3d11va': 'Direct3D 11 Video Acceleration',
      'vaapi': 'Video Acceleration API',
      'vdpau': 'Video Decode and Presentation API for Unix',
      'videotoolbox': 'VideoToolbox',
      'opencl': 'OpenCL',
      'vulkan': 'Vulkan',
      'd3d12va': 'Direct3D 12 Video Acceleration',
    };

    final hardwareAccelerations = <String, String>{};
    for (var accel in hwAccels) {
      final friendlyName = accelDescriptions[accel] ?? accel;
      hardwareAccelerations[accel] = friendlyName;
    }

    return FFmpegInfo(
      version: version,
      buildWith: buildWith,
      configuration: configuration,
      libraryVersions: libraryVersions,
      hardwareAccelerations: hardwareAccelerations,
    );
  }

  @override
  String toString() {
    return 'FFmpegInfo(version: $version, buildWith: $buildWith, configuration: $configuration, libraryVersions: $libraryVersions, hardwareAccelerations: $hardwareAccelerations)';
  }
}

Future<FFmpegInfo?> checkFFmpegInstallation() async {
  try {
    final versionResult = await Process.run('ffmpeg', ['-version']);
    final hwAccelResult = await Process.run('ffmpeg', ['-hwaccels']);
    if (versionResult.exitCode == 0 && hwAccelResult.exitCode == 0) {
      final info = FFmpegInfo.parse(versionResult.stdout, hwAccelResult.stdout);
      // check version
      final versionComponents = info.version.split(' ');
      final versionNumber = versionComponents[2];
      final majorVersion = int.parse(versionNumber.split('.').first);
      if (majorVersion < 4) {
        throw FFmpegNotCompatibleException();
      }
      return info;
    } else if (versionResult.exitCode != 0) {
      throw FFmpegNotCompatibleException();
    } else if (hwAccelResult.exitCode != 0) {
      throw FFmpegNotAccessibleException();
    } else {
      return null;
    }
  } on ProcessException catch (_) {
    throw FFmpegNotFoundException();
  } catch (e) {
    throw FFmpegException('An unknown error occurred: $e');
  }
}