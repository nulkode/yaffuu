import 'package:yaffuu/domain/workflows/compression/threshold/parameters/compress_parameter.dart';

/// Standard FPS values ordered from highest to lowest
const List<int> _standardFpsValues = [120, 60, 30, 24, 15];

/// Parameter for adjusting video frame rate
class FpsParameter extends CompressParameter {
  final double currentFps;
  final double originalFps;

  const FpsParameter({
    required this.currentFps,
    required this.originalFps,
    required super.videoComplexity,
  });

  @override
  CompressParameterType get type => CompressParameterType.fps;

  @override
  int calculateScore() {
    final fpsReduction = originalFps - currentFps;
    final reductionPercentage = fpsReduction / originalFps;
    final baseScore = (reductionPercentage * 800).round();
    
    return (baseScore * (2.0 - videoComplexity)).round();
  }

  @override
  bool canReduce() {
    return _getNextFps() != null;
  }

  @override
  CompressParameter reduce() {
    final nextFps = _getNextFps();
    if (nextFps == null) return this;

    return FpsParameter(
      currentFps: nextFps,
      originalFps: originalFps,
      videoComplexity: videoComplexity,
    );
  }

  @override
  String get description => '${_formatFps(currentFps)} FPS';

  /// Find the next lower FPS value with approximation tolerance
  double? _getNextFps() {
    final currentApprox = _approximateToStandard(currentFps);
    double? nextFps;
    
    for (final standardFps in _standardFpsValues) {
      if (standardFps < currentApprox) {
        nextFps = standardFps.toDouble();
        break;
      }
    }
    
    if (nextFps == null && currentApprox > _standardFpsValues.last) {
      nextFps = _standardFpsValues.last.toDouble();
    }
    
    if (nextFps == null && currentApprox > 15) {
      nextFps = (currentApprox * 0.75).clamp(15.0, currentApprox - 1);
    }
    
    return nextFps;
  }

  /// Approximate FPS to nearest standard value if close enough
  double _approximateToStandard(double fps) {
    for (final standardFps in _standardFpsValues) {
      if ((fps - standardFps).abs() <= 0.5) {
        return standardFps.toDouble();
      }
    }
    return fps;
  }

  /// Format FPS for display
  String _formatFps(double fps) {
    if (fps == fps.roundToDouble()) {
      return fps.round().toString();
    }
    return fps.toStringAsFixed(2);
  }
}