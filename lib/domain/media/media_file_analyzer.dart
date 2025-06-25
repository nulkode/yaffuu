import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

/// Result of media file analysis containing metadata and optional thumbnail.
typedef MediaAnalysisResult = (MediaFile mediaFile, XFile? thumbnail);

/// Analyzer for extracting metadata and generating thumbnails from media files.
class MediaFileAnalyzer {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];

  /// Analyzes a media file to extract metadata and generate a thumbnail.
  Future<MediaAnalysisResult> analyze(XFile file) async {
    final mediaFile = await _getMediaFileInfo(file);
    final thumbnail = await _generateThumbnail(file);

    return (mediaFile, thumbnail);
  }

  /// Extracts metadata from a media file using ffprobe.
  Future<MediaFile> _getMediaFileInfo(XFile file) async {
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
      throw FFmpegException('Failed to get media file info: ${result.stderr}');
    }

    final json = jsonDecode(result.stdout);
    return MediaFile.fromJson(json);
  }

  /// Generates a thumbnail for a media file using FFmpeg.
  Future<XFile?> _generateThumbnail(XFile file) async {
    try {
      final tempDir = Directory.systemTemp;
      final thumbnailPath =
          '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';

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
}
