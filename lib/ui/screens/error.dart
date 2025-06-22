import 'package:flutter/material.dart';
import 'package:yaffuu/ui/components/appbar.dart';

enum AppErrorType {
  ffmpegMissing(0),
  ffmpegNotCompatible(1),
  ffmpegNotAccessible(2),
  other(3);

  final int id;
  const AppErrorType(this.id);
}

class ErrorPage extends StatelessWidget {
  final int errorId;
  final String? extra;

  const ErrorPage({super.key, required this.errorId, this.extra});

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    final errorType = AppErrorType.values.firstWhere(
      (errorType) => errorType.id == errorId,
      orElse: () => AppErrorType.other,
    );

    switch (errorType) {
      case AppErrorType.ffmpegMissing:
        errorMessage = 'FFmpeg is missing.';
        break;
      case AppErrorType.ffmpegNotCompatible:
        errorMessage = 'FFmpeg is outdated.';
        break;
      case AppErrorType.ffmpegNotAccessible:
        errorMessage = 'FFmpeg is not accessible.';
        break;
      case AppErrorType.other:
        errorMessage = 'An unknown error occurred.';
        break;
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
