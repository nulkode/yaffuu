import 'dart:io';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/managers/output_file.dart';

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
