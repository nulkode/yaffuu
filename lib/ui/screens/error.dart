import 'package:flutter/material.dart';
import 'package:yaffuu/logic/bloc/app.dart';
import 'package:yaffuu/ui/components/appbar.dart';

class ErrorPage extends StatelessWidget {
  final AppErrorType errorType;

  const ErrorPage({super.key, required this.errorType});

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (errorType) {
      case AppErrorType.ffmpegMissing:
        errorMessage = 'FFmpeg is not installed or not found in the system path.';
        break;
      case AppErrorType.ffmpegOutdated:
        errorMessage = 'FFmpeg version is not compatible.';
        break;
      case AppErrorType.ffmpegNotAccessible:
        errorMessage = 'FFmpeg is not accessible.';
        break;
      case AppErrorType.other:
        errorMessage = 'An unknown error occurred.';
    }

    return Scaffold(
      appBar: const YaffuuAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}