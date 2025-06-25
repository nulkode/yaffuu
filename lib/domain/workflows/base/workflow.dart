import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/workflows/base/workflow_progress.dart';
import 'package:yaffuu/domain/workflows/base/workflow_result.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';

/// Abstract base class for all video processing workflows - self-contained unit of work
abstract class Workflow {
  /// The input file for this workflow
  final XFile inputFile;

  /// Constructor requires an input file
  const Workflow(this.inputFile);

  /// The result of the workflow execution
  WorkflowResult get result;

  /// Execute the workflow with the provided FFmpeg engine and output path
  Stream<WorkflowProgress> execute(FFmpegEngine engine, String outputFilePath);
}
