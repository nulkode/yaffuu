import 'dart:io';

import 'package:yaffuu/infrastructure/ffmpeg/models/ffmpeg_info.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/common/logger.dart';

/// Service for retrieving and caching FFmpeg build information.
class FFmpegInfoService {
  static const _quietVerbose = ['-v', 'error', '-hide_banner'];
  FFmpegInfo? _cachedInfo;

  /// Gets FFmpeg information, using cached result if available.
  Future<FFmpegInfo> getFFmpegInfo() async {
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    try {
      final versionResult = await Process.run('ffmpeg', ['-version']);
      final hwAccelResult =
          await Process.run('ffmpeg', [..._quietVerbose, '-hwaccels']);

      if (versionResult.exitCode == 0 && hwAccelResult.exitCode == 0) {
        final info = FFmpegInfo.parse(
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

  /// Clears the cached FFmpeg information.
  void clearCache() {
    _cachedInfo = null;
  }
}
