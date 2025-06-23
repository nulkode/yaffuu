import 'package:yaffuu/logic/managers/cuda.dart';
import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';

class FFmpegManagerService {
  static Future<BaseFFmpegManager> createManager(
    FFmpegInfo ffmpegInfo, 
    String acceleration
  ) async {
    final BaseFFmpegManager manager;
    
    if (acceleration == 'none') {
      manager = FFmpegManager(ffmpegInfo);
    } else if (acceleration == 'cuda') {
      manager = CUDAManager(ffmpegInfo);
    } else {
      manager = FFmpegManager(ffmpegInfo);
    }

    if (!(await manager.isCompatible())) {
      throw FFmpegNotCompatibleException();
    }

    return manager;
  }
}
