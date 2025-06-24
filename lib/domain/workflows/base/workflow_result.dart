abstract class WorkflowResult {}

class WorkflowSuccess extends WorkflowResult {}

class WorkflowFailure extends WorkflowResult {
  final String error;

  WorkflowFailure(this.error);
}