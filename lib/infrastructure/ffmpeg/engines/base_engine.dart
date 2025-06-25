import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/ffmpeg_info.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

abstract class FFmpegEngine {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];
  XFile? _file;
  MediaFile? _mediaFile;
  Process? _runningProcess;
  StreamController<Progress>? _progressController;

  final HwAccel hwAccel = HwAccel.none;

  FFmpegEngine();

  XFile? get file => _file;

  MediaFile? get mediaFile => _mediaFile;

  Future<bool> isCompatible();

  Future<bool> isOperationCompatible(Operation operation);

  Future<void> setInputFile(XFile file);

  Stream<Progress> execute(Operation operation);

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

  Future<MediaFile> getMediaFileInfo() async {
    if (_file == null) {
      throw Exception('Input file is not set.');
    }

    final result = await Process.run(
      'ffprobe',
      [
        ..._quietVerbose,
        '-show_format',
        '-show_streams',
        '-of',
        'json',
        _file!.path,
      ],
    );

    if (result.exitCode != 0) {
      throw FFmpegException('Failed to get media file info: ${result.stderr}');
    }

    final json = jsonDecode(result.stdout);
    _mediaFile = MediaFile.fromJson(json);

    return _mediaFile!;
  }

  Stream<Progress> run(List<Argument> arguments) async* {
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

    if (_file == null) {
      throw Exception('Input file is not set.');
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
      _file!.path,
      if (videoFilterArgs.isNotEmpty) '-vf',
      if (videoFilterArgs.isNotEmpty) videoFilterArgs.join(','),
      if (audioFilterArgs.isNotEmpty) '-af',
      if (audioFilterArgs.isNotEmpty) audioFilterArgs.join(','),
      ...outputArgs,
      if (outputFormatArgs.isNotEmpty) '-format',
      outputFormatArgs.first,
      // outputFile, TODO: handle output file
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

  void _cleanup() {
    _runningProcess = null;
    _progressController = null;
  }

  /// Stops the currently running FFmpeg process if any.
  /// Returns true if a process was stopped, false if no process was running.
  bool stop() {
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
