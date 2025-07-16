import 'package:yaffuu/domain/workflows/base/workflow_result.dart';

/// Result of a compression workflow execution with compression-specific metadata
class CompressionResult extends WorkflowResult {
  final Map<String, dynamic> initialParameters;
  final Map<String, dynamic> finalParameters;
  final int initialSizeBytes;
  final int finalSizeBytes;

  const CompressionResult({
    required super.isSuccess,
    super.errorMessage,
    super.executionTime,
    super.metadata,
    required this.initialParameters,
    required this.finalParameters,
    required this.initialSizeBytes,
    required this.finalSizeBytes,
  });

  /// Create a successful compression result
  const CompressionResult.success({
    Duration? executionTime,
    Map<String, dynamic>? metadata,
    required Map<String, dynamic> initialParameters,
    required Map<String, dynamic> finalParameters,
    required int initialSizeBytes,
    required int finalSizeBytes,
  }) : this(
          isSuccess: true,
          executionTime: executionTime,
          metadata: metadata,
          initialParameters: initialParameters,
          finalParameters: finalParameters,
          initialSizeBytes: initialSizeBytes,
          finalSizeBytes: finalSizeBytes,
        );

  /// Create a failed compression result
  const CompressionResult.failure({
    required String errorMessage,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
    required Map<String, dynamic> initialParameters,
    required Map<String, dynamic> finalParameters,
    required int initialSizeBytes,
    required int finalSizeBytes,
  }) : this(
          isSuccess: false,
          errorMessage: errorMessage,
          executionTime: executionTime,
          metadata: metadata,
          initialParameters: initialParameters,
          finalParameters: finalParameters,
          initialSizeBytes: initialSizeBytes,
          finalSizeBytes: finalSizeBytes,
        );

  /// Create a cancelled compression result
  const CompressionResult.cancelled({
    Duration? executionTime,
    Map<String, dynamic>? metadata,
    required Map<String, dynamic> initialParameters,
    required Map<String, dynamic> finalParameters,
    required int initialSizeBytes,
    required int finalSizeBytes,
  }) : this(
          isSuccess: false,
          errorMessage: 'Workflow was cancelled',
          executionTime: executionTime,
          metadata: metadata,
          initialParameters: initialParameters,
          finalParameters: finalParameters,
          initialSizeBytes: initialSizeBytes,
          finalSizeBytes: finalSizeBytes,
        );

  /// Calculate compression ratio achieved
  double get compressionRatio => initialSizeBytes / finalSizeBytes;

  /// Calculate size reduction percentage
  double get sizeReductionPercentage =>
      ((initialSizeBytes - finalSizeBytes) / initialSizeBytes) * 100;

  /// Get formatted size reduction information
  String get formattedSizeReduction {
    final reduction = sizeReductionPercentage.toStringAsFixed(1);
    return '${_formatBytes(initialSizeBytes)} → ${_formatBytes(finalSizeBytes)} ($reduction% reduction)';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'CompressionResult.success($formattedSizeReduction)';
    } else {
      return 'CompressionResult.failure(error: $errorMessage)';
    }
  }
}
