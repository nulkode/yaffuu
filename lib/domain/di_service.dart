import 'package:yaffuu/domain/output_files_service.dart';
import 'package:yaffuu/main.dart';

class DependencyInjectionService {
  static void registerDependencies(OutputFileManager outputFileManager) {

    getIt.registerSingleton<OutputFileManager>(
      outputFileManager,
    );
  }
}
