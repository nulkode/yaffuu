import 'dart:io';
import 'package:yaffuu/logic/managers/output_file.dart';
import 'package:yaffuu/logic/models/ffmpeg_info.dart';

class AppInfo {
  final String logPathInfo;
  final FFmpegInfo ffmpegInfo;
  final Directory dataDir;
  final OutputFileManager outputFileManager;

  AppInfo({
    required this.logPathInfo,
    required this.ffmpegInfo,
    required this.dataDir,
    required this.outputFileManager,
  });
}
