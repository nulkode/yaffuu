/// Abstract base class for workflow execution progress
abstract class WorkflowProgress {
  final DateTime workflowStartTime;

  const WorkflowProgress({required this.workflowStartTime});

  /// Check if the workflow is complete
  bool get isComplete;

  /// Progress percentage (0.0 to 1.0, nullable)
  double? get progress;

  /// Calculate elapsed time since workflow started
  Duration get elapsedTime => DateTime.now().difference(workflowStartTime);

  /// Calculate estimated time to completion based on current progress
  Duration? get estimatedTimeRemaining {
    final currentProgress = progress;
    if (currentProgress == null || currentProgress <= 0) return null;
    
    final elapsed = elapsedTime;
    final totalEstimated = elapsed.inMilliseconds / currentProgress;
    final remaining = totalEstimated - elapsed.inMilliseconds;
    
    return remaining > 0 ? Duration(milliseconds: remaining.round()) : Duration.zero;
  }
}