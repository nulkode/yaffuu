import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/main.dart';
import 'package:yaffuu/ui/components/logos.dart';
import 'package:yaffuu/ui/screens/error.dart';

class AppInfo {
  final String logPathInfo;
  final FFmpegInfo ffmpegInfo;
  final Directory dataDir;

  AppInfo({
    required this.logPathInfo,
    required this.ffmpegInfo,
    required this.dataDir,
  });
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _initialized = false;
  int _error = -1;
  bool _toTutorial = false;
  String? extra;

  @override
  void initState() {
    super.initState();
    _init(() {
      if (_initialized) {
        context.go('/home');
      } else if (_error == 4) {
        context.go('/error/ffmpeg-missing');
      } else if (_error != -1) {
        context.go(Uri(path: '/error-$_error', queryParameters: {'extra': extra}).toString());
      } else if (_toTutorial) {
        context.go('/tutorial');
      }
    });
  }

  Future<void> _init(VoidCallback onComplete) async {
    try {
      final prefs = await UserPreferences.getInstance();
      // ignore: unused_local_variable
      final hasSeenTutorial = prefs.hasSeenTutorial;

      final ffmpegInfo = await FFService.getFFmpegInfo();
      final logFilePath = fileLogOutput.logFilePath;

      final Directory dataDir = Directory(
          '${(await getApplicationDocumentsDirectory()).absolute.path}/data');

      final appInfo = AppInfo(
        logPathInfo: logFilePath,
        ffmpegInfo: ffmpegInfo,
        dataDir: dataDir,
      );

      getIt.registerSingleton<AppInfo>(appInfo);

      // ignore: dead_code
      if (/* !hasSeenTutorial */ false) { // TODO: build tutorial
        setState(() {
          _toTutorial = true;
        });
      } else {
        setState(() {
          _initialized = true;
        });
      }
    } on FFmpegNotCompatibleException {
      setState(() {
        _error = AppErrorType.ffmpegNotCompatible.id;
      });
    } on FFmpegNotFoundException {
      setState(() {
        _error = 4;
      });
    } on FFmpegNotAccessibleException {
      setState(() {
        _error = AppErrorType.ffmpegNotAccessible.id;
      });
    } on Exception catch (e) {
      logger.e('An unknown error occurred: $e');
      setState(() {
        _error = AppErrorType.other.id;
        extra = e.toString();
      });
    } finally {
      onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 64),
                  child: YaffuuLogo(
                    width: 300,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'powered by',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                FFmpegLogo(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
