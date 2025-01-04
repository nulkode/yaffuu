import 'package:yaffuu/logic/operations/operations.dart';

class Acceleration {
  final String id;
  final String displayName;
  final bool implemented;

  Acceleration({
    required this.id,
    required this.displayName,
    required this.implemented,
  });
}

abstract class BaseFFmpegManager {
  final Acceleration acceleration = Acceleration(
    id: 'none',
    displayName: 'None',
    implemented: true,
  );

  BaseFFmpegManager();

  Stream<double> get progress;

  Future<bool> isCompatible();

  Future<bool> isOperationCompatible(Operation operation);

  void addOperation(Operation operation);
}
