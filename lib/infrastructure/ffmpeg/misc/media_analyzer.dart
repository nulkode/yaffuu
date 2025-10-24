import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:yaffuu/domain/media/codec.dart';
import 'package:yaffuu/domain/media/container.dart';
import 'package:yaffuu/domain/media/stream.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
// TODO: use infra river events
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

/// Result of media container analysis containing metadata and optional thumbnail.
typedef MediaAnalysisResult = (MediaContainer mediaContainer, XFile? thumbnail);

/// Analyzer for extracting metadata and generating thumbnails from media containers.
class MediaAnalyzer {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];

  /// Analyzes a media container to extract metadata and generate a thumbnail.
  Future<MediaAnalysisResult> analyze(XFile file) async {
    final mediaContainer = await _getMediaContainerInfo(file);
    final thumbnail = await _generateThumbnail(file);

    return (mediaContainer, thumbnail);
  }

  /// Extracts metadata from a media container using ffprobe.
  Future<MediaContainer> _getMediaContainerInfo(XFile file) async {
    final result = await Process.run(
      'ffprobe',
      [
        ..._quietVerbose,
        '-show_format',
        '-show_streams',
        '-of',
        'json',
        file.path,
      ],
    );

    if (result.exitCode != 0) {
      throw FFmpegException('Failed to get media container information: ${result.stderr}');
    }

    final json = jsonDecode(result.stdout);
    return _parseMediaContainer(json);
  }

  /// Generates a thumbnail for a media container using FFmpeg.
  Future<XFile?> _generateThumbnail(XFile file) async {
    try {
      final tempDir = Directory.systemTemp;
      final thumbnailPath = path.join(tempDir.path,
          'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final arguments = [
        Argument(
          type: ArgumentType.output,
          value: '-ss 1',
        ),
        Argument(
          type: ArgumentType.output,
          value: '-vframes 1',
        ),
        Argument(
          type: ArgumentType.output,
          value: '-vf scale=\'min(320,iw)\':-2',
        ),
        Argument(
          type: ArgumentType.outputFormat,
          value: 'image2',
        ),
        Argument(
          type: ArgumentType.outputExtension,
          value: '.jpg',
        ),
      ];

      await for (final progress
          in FFmpegEngine.run(file, thumbnailPath, arguments)) {
        logger.d('Thumbnail generation progress: ${progress.toString()}');
      }

      final thumbnailFile = File(thumbnailPath);
      if (await thumbnailFile.exists()) {
        return XFile(thumbnailPath);
      }

      return null;
    } catch (e) {
      logger.w('Failed to generate thumbnail: $e');
      return null;
    }
  }

  MediaContainer _parseMediaContainer(Map<String, dynamic> json) {
    try {
      if (json['streams'] == null ||
          json['format'] == null ||
          json['format']['format_name'] == null ||
          json['format']['size'] == null) {
        throw JsonParsingException('Invalid media container JSON data.');
      }

      List<MediaStream> streams = [];
      for (var stream in json['streams']) {
        if (stream['codec_type'] == 'video') {
          streams.add(_parseVideoStream(stream));
        } else if (stream['codec_type'] == 'audio') {
          streams.add(_parseAudioStream(stream));
        }
      }

      List<Format> formats = [];
      for (var format in json['format']['format_name'].split(',')) {
        formats.add(_parseFormat(format));
      }

      return MediaContainer(
        streams,
        formats,
        int.parse(json['format']['size']),
      );
    } catch (e) {
      throw MultimediaNotFoundOrNotRecognizedException();
    }
  }

  Format _parseFormat(String name) {
    for (var format in Format.values) {
      if (format.name == name) {
        return format;
      }
    }
    throw JsonParsingException("Unknown format: $name");
  }

  VideoStream _parseVideoStream(Map<String, dynamic> json) {
    if (json['index'] == null ||
        json['codec_name'] == null ||
        json['width'] == null ||
        json['height'] == null ||
        json['duration'] == null ||
        json['bit_rate'] == null) {
      throw JsonParsingException('Invalid video stream JSON data.');
    }
    return VideoStream(
      json['index'],
      _parseMediaCodec(json['codec_name']),
      json['width'],
      json['height'],
      double.parse(json['duration']),
      int.parse(json['bit_rate']),
    );
  }

  AudioStream _parseAudioStream(Map<String, dynamic> json) {
    if (json['index'] == null ||
        json['codec_name'] == null ||
        json['sample_rate'] == null ||
        json['channels'] == null ||
        json['duration'] == null) {
      throw JsonParsingException('Invalid audio stream JSON data.');
    }
    return AudioStream(
      json['index'],
      _parseMediaCodec(json['codec_name']),
      int.parse(json['sample_rate']),
      json['channels'],
      double.parse(json['duration']),
    );
  }

    MediaCodec _parseMediaCodec(String name) {
    for (var codec in MediaCodec.values) {
      if (codec.name == name) {
        return codec;
      }
    }
    throw JsonParsingException("Unknown codec: $name");
  }
}
