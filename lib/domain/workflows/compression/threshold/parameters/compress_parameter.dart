/// Types of compression parameters that can be adjusted
enum CompressParameterType {
  resolution,
  fps,
  audioBitrate,
  speed,
}

/// Abstract base class for compression parameters that can be optimized
abstract class CompressParameter {
  /// Video complexity factor from analysis (0.5 = simple, 1.0 = normal, 2.0 = complex)
  final double videoComplexity;

  const CompressParameter({required this.videoComplexity});

  /// Type of this parameter
  CompressParameterType get type;

  /// Calculate the compression score for this parameter
  /// Higher score means higher priority for reduction
  int calculateScore();

  /// Check if this parameter can be reduced further
  bool canReduce();

  /// Create a new parameter with the next reduction level
  CompressParameter reduce();

  /// Human-readable description of the current parameter values
  String get description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompressParameter && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}
