import 'package:yaffuu/logic/managers/cuda.dart';
import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/logic/managers/quicksync.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';

class FFmpegManagerProvider {
  final FFmpegInfo _ffmpegInfo;

  FFmpegManagerProvider(this._ffmpegInfo);

  Future<BaseFFmpegManager> createManager(String acceleration) async {
    final BaseFFmpegManager manager = switch (acceleration) {
      'none' => FFmpegManager(_ffmpegInfo),
      'cuda' => CUDAManager(_ffmpegInfo),
      'quicksync' => QuickSyncManager(_ffmpegInfo),
      _ => FFmpegManager(_ffmpegInfo),
    };

    if (!(await manager.isCompatible())) {
      throw FFmpegNotCompatibleException();
    }

    return manager;
  }

  static List<AccelerationInformation> getAvailableAccelerations() {
    return [
      AccelerationInformation(
          id: 'none', displayName: 'None', implemented: true),
      AccelerationInformation(
          id: 'cuda', displayName: 'NVIDIA CUDA', implemented: false),
      AccelerationInformation(
          id: 'quicksync', displayName: 'Intel Quick Sync', implemented: false),
    ];
  }
}
