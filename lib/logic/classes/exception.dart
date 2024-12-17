class OperationNotCompatibleException implements Exception {
  final String message;

  OperationNotCompatibleException(this.message);
}

class FFmpegException implements Exception {
  final String message;
  FFmpegException(this.message);

  @override
  String toString() => 'FFmpegException: $message';
}

class FFmpegNotFoundException extends FFmpegException {
  FFmpegNotFoundException() : super('FFmpeg is not installed or not found in the system path.');
}

class FFmpegNotCompatibleException extends FFmpegException {
  FFmpegNotCompatibleException() : super('FFmpeg version is not compatible.');
}

class FFmpegNotAccessibleException extends FFmpegException {
  FFmpegNotAccessibleException() : super('FFmpeg is not accessible.');
}