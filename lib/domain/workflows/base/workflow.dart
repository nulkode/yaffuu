import 'package:yaffuu/domain/workflows/base/workflow_progress.dart';
import 'package:yaffuu/domain/workflows/base/workflow_result.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';

/// Abstract base class for all video processing workflows
abstract class Workflow {
  /// The result of the workflow execution
  WorkflowResult get result;

  /// Execute the workflow with the provided FFmpeg engine
  Stream<WorkflowProgress> execute(FFmpegEngine engine);
}
