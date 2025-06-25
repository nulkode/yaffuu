import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

/// Abstract base class for FFmpeg engines with static utility methods.
abstract class FFmpegEngine {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];
  static Process? _runningProcess;
  static StreamController<Progress>? _progressController;

  final HwAccel hwAccel = HwAccel.none;

  FFmpegEngine();

  /// Checks if this engine is compatible with the current system.
  Future<bool> isCompatible();

  /// Checks if this engine supports the given operation.
  Future<bool> isOperationCompatible(Operation operation);

  /// Executes an operation with the specified input file and output path.
  Stream<Progress> execute(Operation operation, XFile inputFile, String outputFilePath);

  /// Static utility method for executing FFmpeg processes.
  static Stream<Progress> run(XFile inputFile, String outputFilePath, List<Argument> arguments) async* {
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
      inputFile.path,
      if (videoFilterArgs.isNotEmpty) '-vf',
      if (videoFilterArgs.isNotEmpty) videoFilterArgs.join(','),
      if (audioFilterArgs.isNotEmpty) '-af',
      if (audioFilterArgs.isNotEmpty) audioFilterArgs.join(','),
      ...outputArgs,
      if (outputFormatArgs.isNotEmpty) '-format',
      if (outputFormatArgs.isNotEmpty) outputFormatArgs.first,
      outputFilePath,
    ];

    _runningProcess = await Process.start('ffmpeg', processArguments);
    _progressController = StreamController<Progress>();

    logger.d('Executing FFmpeg with arguments: $processArguments');
    logger.d('Process started with PID: ${_runningProcess!.pid}');

    _runningProcess!.stdout
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
              final progress = Progress.parse([event]);
              _progressController!.add(progress);
            }
          }
        } catch (e) {
          logger.w('Failed to parse progress from: "$event", error: $e');
        }
      },
      onError: (error) {
        logger.e('FFmpeg stdout error: $error');
        _progressController!.addError(error);
      },
      onDone: () {
        logger.d('FFmpeg stdout stream completed');
      },
    );

    _runningProcess!.stderr
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

    _runningProcess!.exitCode.then((exitCode) {
      logger.d('FFmpeg process completed with exit code: $exitCode');
      if (exitCode != 0) {
        _progressController!.addError(
            FFmpegException('FFmpeg process failed with exit code: $exitCode'));
      }
      _progressController!.close();
      _cleanup();
    }).catchError((error) {
      logger.e('FFmpeg process error: $error');
      _progressController!.addError(error);
      _progressController!.close();
      _cleanup();
    });

    try {
      await for (final progress in _progressController!.stream) {
        yield progress;
      }
    } catch (e) {
      logger.e('Stream error: $e');
      rethrow;
    } finally {
      try {
        final isRunning = _runningProcess != null &&
            !await _runningProcess!.exitCode
                .timeout(
                  const Duration(milliseconds: 1),
                  onTimeout: () => -1,
                )
                .then((code) => true)
                .catchError((_) => false);

        if (isRunning && !_runningProcess!.kill()) {
          logger.w('Failed to kill FFmpeg process');
        }
      } catch (e) {
        logger.d('Could not determine process state, attempting to kill: $e');
        try {
          _runningProcess?.kill();
        } catch (killError) {
          logger.w('Failed to kill FFmpeg process: $killError');
        }
      } finally {
        _cleanup();
      }
    }
  }

  /// Cleans up static resources after process completion.
  static void _cleanup() {
    _runningProcess = null;
    _progressController = null;
  }

  /// Stops the currently running FFmpeg process if any.
  static bool stop() {
    if (_runningProcess == null) {
      return false;
    }

    try {
      final killed = _runningProcess!.kill();
      if (killed) {
        logger.d('FFmpeg process stopped');
        _progressController
            ?.addError(FFmpegException('Process stopped by user'));
        _progressController?.close();
        _cleanup();
      }
      return killed;
    } catch (e) {
      logger.e('Failed to stop FFmpeg process: $e');
      return false;
    }
  }
}
