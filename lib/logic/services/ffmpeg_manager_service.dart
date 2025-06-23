import 'package:yaffuu/logic/managers/cuda.dart';
import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/logic/managers/quicksync.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';

class FFmpegManagerService {
  static Future<BaseFFmpegManager> createManager(
    FFmpegInfo ffmpegInfo, 
    String acceleration
  ) async {
    final BaseFFmpegManager manager = switch (acceleration) {
      'none' => FFmpegManager(ffmpegInfo),
      'cuda' => CUDAManager(ffmpegInfo),
      'quicksync' => QuickSyncManager(ffmpegInfo),
      _ => FFmpegManager(ffmpegInfo), // Default fallback
    };

    if (!(await manager.isCompatible())) {
      throw FFmpegNotCompatibleException();
    }

    return manager;
  }

  /// Get all available acceleration methods
  static List<AccelerationInformation> getAvailableAccelerations() {
    return [
      AccelerationInformation(id: 'none', displayName: 'None', implemented: true),
      AccelerationInformation(id: 'cuda', displayName: 'NVIDIA CUDA', implemented: false),
      AccelerationInformation(id: 'quicksync', displayName: 'Intel Quick Sync', implemented: false),
    ];
  }
}
