import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/models/ffmpeg_info.dart';
import 'package:yaffuu/domain/models/progress.dart';
import 'package:yaffuu/ffmpeg/operations/operations.dart';
import 'package:yaffuu/domain/constants/exception.dart';
import 'package:yaffuu/domain/logger.dart';

class EngineInformation {
  final String id;
  final String displayName;
  final bool implemented;

  EngineInformation({
    required this.id,
    required this.displayName,
    required this.implemented,
  });
}

abstract class FFmpegEngine {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];
  final EngineInformation acceleration = EngineInformation(
    id: 'none',
    displayName: 'None',
    implemented: true,
  );

  FFmpegEngine();

  Stream<double> get progress;

  Future<bool> isCompatible();

  Future<bool> isOperationCompatible(Operation operation);

  void setFile(XFile file);

  Stream<Progress> execute(Operation operation);

  XFile? get lastOutput;

  void clearLastOutput();

  Future<FFmpegInfo> getFFmpegInfo() async {
    try {
      final versionResult = await Process.run('ffmpeg', ['-version']);
      final hwAccelResult =
          await Process.run('ffmpeg', [..._quietVerbose, '-hwaccels']);

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

  Stream<RawProgress> run(List<Argument> arguments, String outputFile) async* {
    final globalArgs = arguments
        .where((arg) => arg.type == ArgumentType.global)
        .map((arg) => arg.value)
        .expand((value) => value.split(' '))
        .toList();
    final inputArgs = arguments
        .where((arg) => arg.type == ArgumentType.input)
        .map((arg) => arg.value)
        .expand((value) => value.split(' '))
        .toList();
    final inputFileArgs = arguments
        .where((arg) => arg.type == ArgumentType.inputFile)
        .map((arg) => arg.value)
        .toList();
    final outputArgs = arguments
        .where((arg) => arg.type == ArgumentType.output)
        .map((arg) => arg.value)
        .expand((value) => value.split(' '))
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
      ..._quietVerbose,
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
      if (videoFilterArgs.isNotEmpty) videoFilterArgs.join(','),
      if (audioFilterArgs.isNotEmpty) '-af',
      if (audioFilterArgs.isNotEmpty) audioFilterArgs.join(','),
      ...outputArgs,
      if (outputFormatArgs.isNotEmpty) '-format',
      outputFormatArgs.first,
      outputFile,
    ];

    final process = await Process.start('ffmpeg', processArguments);
    final controller = StreamController<RawProgress>();

    logger.d('Executing FFmpeg with arguments: $processArguments');
    logger.d('Process started with PID: ${process.pid}');

    process.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(
      (event) {
        logger.d('FFmpeg stdout: "$event"');
        try {
          if (event.trim().isNotEmpty) {
            if (event.contains('frame=') ||
                event.contains('fps=') ||
                event.contains('size=')) {
              final progress = RawProgress.parse([event]);
              logger.d(
                  'Parsed progress: frame=${progress.frame}, fps=${progress.fps}, size=${progress.size}');
              controller.add(progress);
            }
          }
        } catch (e) {
          logger.w('Failed to parse progress from: "$event", error: $e');
        }
      },
      onError: (error) {
        logger.e('FFmpeg stdout error: $error');
        controller.addError(error);
      },
      onDone: () {
        logger.d('FFmpeg stdout stream completed');
      },
    );

    process.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(
      (event) {
        logger.d('FFmpeg stderr: $event');
      },
      onError: (error) {
        logger.e('FFmpeg stderr error: $error');
      },
      onDone: () {
        logger.d('FFmpeg stderr stream completed');
      },
    );

    process.exitCode.then((exitCode) {
      logger.d('FFmpeg process completed with exit code: $exitCode');
      if (exitCode != 0) {
        controller.addError(
            FFmpegException('FFmpeg process failed with exit code: $exitCode'));
      }
      controller.close();
    }).catchError((error) {
      logger.e('FFmpeg process error: $error');
      controller.addError(error);
      controller.close();
    });

    try {
      await for (final progress in controller.stream) {
        yield progress;
      }
    } catch (e) {
      logger.e('Stream error: $e');
      rethrow;
    } finally {
      try {
        final isRunning = !await process.exitCode
            .timeout(
              const Duration(milliseconds: 1),
              onTimeout: () => -1,
            )
            .then((code) => true)
            .catchError((_) => false);

        if (isRunning && !process.kill()) {
          logger.w('Failed to kill FFmpeg process');
        }
      } catch (e) {
        logger.d('Could not determine process state, attempting to kill: $e');
        try {
          process.kill();
        } catch (killError) {
          logger.w('Failed to kill FFmpeg process: $killError');
        }
      }
    }
  }
}
