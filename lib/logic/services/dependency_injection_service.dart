import 'package:yaffuu/logic/models/app_info.dart';
import 'package:yaffuu/main.dart';

class DependencyInjectionService {
  static void registerAppInfo(AppInfo appInfo) {
    getIt.registerSingleton<AppInfo>(appInfo);
  }
}
