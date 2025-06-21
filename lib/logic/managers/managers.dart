import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/logic/classes/progress.dart';
import 'package:yaffuu/logic/operations/operations.dart';

class AccelerationInformation {
  final String id;
  final String displayName;
  final bool implemented;

  AccelerationInformation({
    required this.id,
    required this.displayName,
    required this.implemented,
  });
}

abstract class BaseFFmpegManager {
  final AccelerationInformation acceleration = AccelerationInformation(
    id: 'none',
    displayName: 'None',
    implemented: true,
  );

  BaseFFmpegManager();

  Stream<double> get progress;

  Future<bool> isCompatible();
  Future<bool> isOperationCompatible(Operation operation);

  void setFile(XFile file);
  Stream<Progress> execute(Operation operation);
  
  /// Gets the last output file from the most recent operation
  XFile? get lastOutput;
  
  /// Clears the last output file reference
  void clearLastOutput() {}
}
