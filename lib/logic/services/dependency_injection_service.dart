import 'package:yaffuu/logic/models/app_info.dart';
import 'package:yaffuu/logic/providers/ffmpeg_manager_provider.dart';
import 'package:yaffuu/main.dart';

class DependencyInjectionService {
  static void registerAppInfo(AppInfo appInfo) {
    getIt.registerSingleton<AppInfo>(appInfo);

    getIt.registerSingleton<FFmpegManagerProvider>(
      FFmpegManagerProvider(appInfo.ffmpegInfo),
    );
  }
}
