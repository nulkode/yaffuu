/// Represents the result of a workflow execution
class WorkflowResult {
  final bool isSuccess;
  final String? errorMessage;
  final Duration? executionTime;
  final Map<String, dynamic>? metadata;

  const WorkflowResult._({
    required this.isSuccess,
    this.errorMessage,
    this.executionTime,
    this.metadata,
  });

  /// Create a successful workflow result
  const WorkflowResult.success({
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) : this._(
          isSuccess: true,
          executionTime: executionTime,
          metadata: metadata,
        );

  /// Create a failed workflow result
  const WorkflowResult.failure({
    required String errorMessage,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) : this._(
          isSuccess: false,
          errorMessage: errorMessage,
          executionTime: executionTime,
          metadata: metadata,
        );

  /// Create a cancelled workflow result
  const WorkflowResult.cancelled({
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) : this._(
          isSuccess: false,
          errorMessage: 'Workflow was cancelled',
          executionTime: executionTime,
          metadata: metadata,
        );

  /// Check if the workflow failed
  bool get isFailure => !isSuccess;

  /// Check if the workflow was cancelled
  bool get wasCancelled => errorMessage == 'Workflow was cancelled';

  @override
  String toString() {
    if (isSuccess) {
      return 'WorkflowResult.success()';
    } else {
      return 'WorkflowResult.failure(error: $errorMessage)';
    }
  }
}
