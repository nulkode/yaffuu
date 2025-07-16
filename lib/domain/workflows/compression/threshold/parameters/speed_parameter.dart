import 'package:yaffuu/domain/workflows/compression/threshold/parameters/compress_parameter.dart';
import 'package:yaffuu/infrastructure/ffmpeg/operations/video_encode.dart';

/// Parameter for adjusting encoding speed vs quality trade-off
class SpeedParameter extends CompressParameter {
  final EncodingPreset currentPreset;

  const SpeedParameter({
    required this.currentPreset,
    required super.videoComplexity,
  });

  @override
  CompressParameterType get type => CompressParameterType.speed;

  @override
  int calculateScore() {
    final speedIndex = _getPresetSpeedIndex(currentPreset);
    final maxSpeedIndex = _getPresetSpeedIndex(EncodingPreset.ultrafast);
    final baseScore = ((maxSpeedIndex - speedIndex) * 200).round();
    
    return (baseScore / videoComplexity).round();
  }

  @override
  bool canReduce() {
    return _getFasterPreset() != null;
  }

  @override
  CompressParameter reduce() {
    final fasterPreset = _getFasterPreset();
    if (fasterPreset == null) return this;

    return SpeedParameter(
      currentPreset: fasterPreset,
      videoComplexity: videoComplexity,
    );
  }

  @override
  String get description => _getPresetDescription(currentPreset);

  /// Get speed index for preset (higher = faster)
  int _getPresetSpeedIndex(EncodingPreset preset) {
    switch (preset) {
      case EncodingPreset.ultrafast: return 10;
      case EncodingPreset.superfast: return 9;
      case EncodingPreset.veryfast: return 8;
      case EncodingPreset.faster: return 7;
      case EncodingPreset.fast: return 6;
      case EncodingPreset.medium: return 5;
      case EncodingPreset.slow: return 4;
      case EncodingPreset.slower: return 3;
      case EncodingPreset.veryslow: return 2;
      case EncodingPreset.placebo: return 1;
    }
  }

  /// Get the next faster preset
  EncodingPreset? _getFasterPreset() {
    final currentIndex = _getPresetSpeedIndex(currentPreset);
    
    switch (currentIndex) {
      case 1: return EncodingPreset.veryslow;
      case 2: return EncodingPreset.slower;
      case 3: return EncodingPreset.slow;
      case 4: return EncodingPreset.medium;
      case 5: return EncodingPreset.fast;
      case 6: return EncodingPreset.faster;
      case 7: return EncodingPreset.veryfast;
      case 8: return EncodingPreset.superfast;
      case 9: return EncodingPreset.ultrafast;
      default: return null;
    }
  }

  /// Get human-readable description for preset
  String _getPresetDescription(EncodingPreset preset) {
    switch (preset) {
      case EncodingPreset.ultrafast: return 'Ultra Fast (lowest quality)';
      case EncodingPreset.superfast: return 'Super Fast';
      case EncodingPreset.veryfast: return 'Very Fast';
      case EncodingPreset.faster: return 'Faster';
      case EncodingPreset.fast: return 'Fast';
      case EncodingPreset.medium: return 'Medium (balanced)';
      case EncodingPreset.slow: return 'Slow';
      case EncodingPreset.slower: return 'Slower';
      case EncodingPreset.veryslow: return 'Very Slow';
      case EncodingPreset.placebo: return 'Placebo (highest quality)';
    }
  }
}