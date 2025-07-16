import 'package:yaffuu/domain/workflows/base/workflow_progress.dart';

/// Represents the different stages of compression workflow execution
enum CompressionStage {
  analyzingVideo,
  adjustingParameters,
  processingVideo,
}

/// Progress information for compression workflows
class CompressionProgress extends WorkflowProgress {
  final CompressionStage currentStage;
  final double? stageProgress;
  final int originalSizeBytes;
  final int currentSizeBytes;
  final Duration encodedDuration;

  const CompressionProgress({
    required this.currentStage,
    this.stageProgress,
    required this.originalSizeBytes,
    required this.currentSizeBytes,
    required this.encodedDuration,
    required super.workflowStartTime,
  });

  @override
  bool get isComplete =>
      currentStage == CompressionStage.processingVideo && stageProgress == 1.0;

  @override
  double? get progress => stageProgress;

  /// Create progress for video analysis stage
  const CompressionProgress.analyzingVideo({
    double? stageProgress,
    required int originalSizeBytes,
    required int currentSizeBytes,
    required Duration encodedDuration,
    required DateTime workflowStartTime,
  }) : this(
          currentStage: CompressionStage.analyzingVideo,
          stageProgress: stageProgress,
          originalSizeBytes: originalSizeBytes,
          currentSizeBytes: currentSizeBytes,
          encodedDuration: encodedDuration,
          workflowStartTime: workflowStartTime,
        );

  /// Create progress for parameter adjustment stage
  const CompressionProgress.adjustingParameters({
    double? stageProgress,
    required int originalSizeBytes,
    required int currentSizeBytes,
    required Duration encodedDuration,
    required DateTime workflowStartTime,
  }) : this(
          currentStage: CompressionStage.adjustingParameters,
          stageProgress: stageProgress,
          originalSizeBytes: originalSizeBytes,
          currentSizeBytes: currentSizeBytes,
          encodedDuration: encodedDuration,
          workflowStartTime: workflowStartTime,
        );

  /// Create progress for video processing stage
  const CompressionProgress.processingVideo({
    double? stageProgress,
    required int originalSizeBytes,
    required int currentSizeBytes,
    required Duration encodedDuration,
    required DateTime workflowStartTime,
  }) : this(
          currentStage: CompressionStage.processingVideo,
          stageProgress: stageProgress,
          originalSizeBytes: originalSizeBytes,
          currentSizeBytes: currentSizeBytes,
          encodedDuration: encodedDuration,
          workflowStartTime: workflowStartTime,
        );

  /// Get formatted size information
  String get formattedSizeInfo {
    return '${_formatBytes(currentSizeBytes)} / ${_formatBytes(originalSizeBytes)}';
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
    final progressText = stageProgress != null
        ? ' (${(stageProgress! * 100).toStringAsFixed(1)}%)'
        : '';
    return 'CompressionProgress.${currentStage.name}$progressText - $formattedSizeInfo - ${encodedDuration.toString().split('.').first}';
  }
}
