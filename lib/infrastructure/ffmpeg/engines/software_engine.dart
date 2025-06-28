import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/base.dart';

/// Software-based FFmpeg engine implementation.
///
/// This is a stateless engine that uses CPU-based encoding and acts as
/// the universal fallback for all operations. It doesn't maintain any
/// internal state and operates purely as a strategy for executing
/// FFmpeg operations using software encoding.
class SoftwareEngine extends FFmpegEngine {
  /// Creates a new software engine instance.
  SoftwareEngine();

  @override
  Future<bool> isCompatible() {
    // Software engine is always compatible as it's the universal fallback
    return Future.value(true);
  }

  @override
  Future<bool> isOperationCompatible(Operation operation) {
    // Software engine supports all operations as it's the universal fallback
    return Future.value(true);
  }

  @override
  Stream<Progress> execute(
      Operation operation, XFile inputFile, String outputFilePath) async* {
    logger.d(
        'Executing operation: ${operation.runtimeType} with software engine');

    // Get the base arguments for the operation
    final arguments = operation.toArguments(this);

    // Execute using the static FFmpegEngine.run method
    final stream = FFmpegEngine.run(inputFile, outputFilePath, arguments);

    await for (final progress in stream) {
      yield progress;
    }
  }
}
