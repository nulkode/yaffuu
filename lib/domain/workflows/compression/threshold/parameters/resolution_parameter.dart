import 'package:yaffuu/domain/workflows/compression/threshold/parameters/compress_parameter.dart';

/// Standard resolution heights ordered from highest to lowest
const List<int> _standardHeights = [2160, 1440, 1080, 720, 480, 360];

/// Represents a video resolution
class Resolution {
  final int width;
  final int height;
  final String? name;

  const Resolution(this.width, this.height, [this.name]);

  /// Calculate total pixels
  int get pixels => width * height;

  /// Calculate aspect ratio
  double get aspectRatio => width / height;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Resolution && other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() {
    if (name != null) return '$name (${width}x$height)';
    return '${width}x$height';
  }
}

/// Parameter for adjusting video resolution
class ResolutionParameter extends CompressParameter {
  final Resolution currentResolution;
  final int originalPixels;

  const ResolutionParameter({
    required this.currentResolution,
    required this.originalPixels,
    required super.videoComplexity,
  });

  @override
  CompressParameterType get type => CompressParameterType.resolution;

  @override
  int calculateScore() {
    final currentPixels = currentResolution.pixels;
    final pixelReduction = originalPixels - currentPixels;
    final baseScore = (pixelReduction / originalPixels * 1000).round();
    
    return (baseScore * videoComplexity).round();
  }

  @override
  bool canReduce() {
    return _getNextResolution() != null;
  }

  @override
  CompressParameter reduce() {
    final nextResolution = _getNextResolution();
    if (nextResolution == null) return this;

    return ResolutionParameter(
      currentResolution: nextResolution,
      originalPixels: originalPixels,
      videoComplexity: videoComplexity,
    );
  }

  @override
  String get description => currentResolution.toString();

  /// Find the next smaller resolution by matching height or width to standard values
  Resolution? _getNextResolution() {
    final aspectRatio = currentResolution.aspectRatio;
    
    for (final standardHeight in _standardHeights) {
      if (standardHeight < currentResolution.height) {
        final newWidth = (standardHeight * aspectRatio).round();
        final standardName = _getStandardName(standardHeight);
        return Resolution(newWidth, standardHeight, standardName);
      }
    }
    
    for (final standardHeight in _standardHeights) {
      final standardWidth = (standardHeight * 16 / 9).round();
      if (standardWidth < currentResolution.width) {
        final newHeight = (standardWidth / aspectRatio).round();
        final standardName = _getStandardName(newHeight);
        return Resolution(standardWidth, newHeight, standardName);
      }
    }
    
    if (currentResolution.pixels > _standardHeights.last * (16/9) * _standardHeights.last) {
      final newWidth = (currentResolution.width * 0.75).round();
      final newHeight = (currentResolution.height * 0.75).round();
      return Resolution(newWidth, newHeight);
    }
    
    return null;
  }

  /// Get standard name for known heights
  String? _getStandardName(int height) {
    switch (height) {
      case 2160: return '4K';
      case 1440: return '1440p';
      case 1080: return '1080p';
      case 720: return '720p';
      case 480: return '480p';
      case 360: return '360p';
      default: return null;
    }
  }
}