import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/classes/media.dart';
import 'package:yaffuu/logic/classes/progress.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/operations/operations.dart';

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
    /* HEADER */
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

    /* HARDWARE ACCELERATION */
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

const quietVerbose = ['-v', 'quiet'];

abstract class FFService {
  static Future<FFmpegInfo> getFFmpegInfo() async {
    try {
      final versionResult = await Process.run('ffmpeg', ['-version']);
      final hwAccelResult =
          await Process.run('ffmpeg', [...quietVerbose, '-hwaccels']);

      if (versionResult.exitCode == 0 && hwAccelResult.exitCode == 0) {
        final info = FFmpegInfo.parse(
          versionResult.stdout,
          hardwareAccelerationMethods: hwAccelResult.stdout,
        );

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

  static Future<MediaFile> probeFile(String path) async {
    try {
      final result = await Process.run('ffprobe', [
        ...quietVerbose,
        '-output_format',
        'json',
        '-show_format',
        '-show_streams',
        path,
      ]);

      if (result.exitCode == 0) {
        return result.stdout;
      } else if (result.exitCode > 0) {
        throw MultimediaNotFoundOrNotRecognizedException();
      }

      return MediaFile.fromJson(result.stdout);
    } on JsonParsingException {
      rethrow;
    } on MultimediaNotFoundOrNotRecognizedException {
      rethrow;
    } catch (e) {
      logger.e('An unknown error occurred: $e');
      throw FFmpegException('An unknown error occurred: $e');
    }
  }

  static Stream<RawProgress> execute(
      List<Argument> arguments, String outputFile) async* {
    final globalArgs = arguments
        .where((arg) => arg.type == ArgumentType.global)
        .map((arg) => arg.value)
        .toList();
    final inputArgs = arguments
        .where((arg) => arg.type == ArgumentType.input)
        .map((arg) => arg.value)
        .toList();
    final inputFileArgs = arguments
        .where((arg) => arg.type == ArgumentType.inputFile)
        .map((arg) => arg.value)
        .toList();
    final outputArgs = arguments
        .where((arg) => arg.type == ArgumentType.output)
        .map((arg) => arg.value)
        .toList();
    final outputFormatArgs = arguments
        .where((arg) => arg.type == ArgumentType.outputFormat)
        .map((arg) => arg.value)
        .toList();
    final videoFilterArgs = arguments
        .where((arg) => arg.type == ArgumentType.videoFilter)
        .map((arg) => arg.value)
        .toList();
    final audioFilterArgs = arguments
        .where((arg) => arg.type == ArgumentType.audioFilter)
        .map((arg) => arg.value)
        .toList();

    if (inputFileArgs.isEmpty) {
      throw ArgumentError('No input file provided.');
    } else if (inputFileArgs.length > 1) {
      throw ArgumentError(
          'Multiple input files provided. Only one input file is allowed.');
    }

    if (outputFormatArgs.length > 1) {
      throw ArgumentError(
          'Multiple output formats provided. Only one output format is allowed.');
    }

    final processArguments = [
      ...quietVerbose,
      '-progress',
      'pipe:1',
      '-stats_period',
      '0.1s',
      '-y',
      ...globalArgs,
      ...inputArgs,
      '-i',
      inputFileArgs.first,
      if (videoFilterArgs.isNotEmpty) '-vf',
      videoFilterArgs.join(','),
      if (audioFilterArgs.isNotEmpty) '-af',
      audioFilterArgs.join(','),
      ...outputArgs,
      if (outputFormatArgs.isNotEmpty) '-format',
      outputFormatArgs.first,
      outputFile,
    ];

    final process = await Process.start('ffmpeg', processArguments);
    final controller = StreamController<RawProgress>();

    process.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((event) {
          final progress = RawProgress.parse(event.split('\n'));
          controller.add(progress);
        });

    await for (final progress in controller.stream) {
      yield progress;
    }
  }
}
