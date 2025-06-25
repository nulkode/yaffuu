/// Abstract base class for workflow execution progress
abstract class WorkflowProgress {
  const WorkflowProgress();

  /// Check if the workflow is complete
  bool get isComplete;

  /// Progress percentage (0.0 to 1.0, nullable)
  double? get progress;
}
