import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:yaffuu/logic/managers/output_file.dart';

class DirectoryService {
  static Future<(Directory, OutputFileManager)> setupDirectories() async {
    final Directory dataDir = Directory(
        '${(await getApplicationDocumentsDirectory()).absolute.path}/data');

    final outputFileManager = OutputFileManager(
      dataDir: dataDir,
      maxSizeBytes: 2 * 1024 * 1024 * 1024, // 2GB limit
      maxFiles: 150, // Maximum 150 files
      cleanupStrategy: CleanupStrategy.oldestFirst,
    );
    
    await outputFileManager.initialize();
    
    return (dataDir, outputFileManager);
  }
}
