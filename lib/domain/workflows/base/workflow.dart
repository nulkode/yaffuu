import 'package:yaffuu/domain/workflows/base/workflow_progress.dart';
import 'package:yaffuu/domain/workflows/base/workflow_result.dart';

abstract class Workflow {
  WorkflowResult get result;

  Stream<WorkflowProgress> execute();
}