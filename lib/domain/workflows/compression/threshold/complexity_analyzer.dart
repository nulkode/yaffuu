import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';

/// Represents the complexity analysis results of a video
class VideoComplexity {
  /// Scene changes per second (higher = more cuts/transitions)
  final double sceneChangesPerSecond;

  /// Motion intensity from 0.0 to 1.0 (higher = more movement)
  final double motionIntensity;

  /// Signal variance indicating detail complexity (higher = more detail)
  final double signalVariance;

  /// Noise level from 0.0 to 1.0 (higher = more noise/grain)
  final double noiseLevel;

  /// Bitrate efficiency ratio (actual_bitrate / theoretical_bitrate)
  final double bitrateEfficiency;

  /// Duration of the analyzed sample in seconds
  final double analyzedDuration;

  /// Overall complexity factor from 0.5 to 2.0 (1.0 = normal complexity)
  final double complexityFactor;

  const VideoComplexity({
    required this.sceneChangesPerSecond,
    required this.motionIntensity,
    required this.signalVariance,
    required this.noiseLevel,
    required this.bitrateEfficiency,
    required this.analyzedDuration,
    required this.complexityFactor,
  });

  /// Create a default/simple complexity for fallback cases
  const VideoComplexity.simple()
      : sceneChangesPerSecond = 0.1,
        motionIntensity = 0.3,
        signalVariance = 0.4,
        noiseLevel = 0.2,
        bitrateEfficiency = 1.0,
        analyzedDuration = 0.0,
        complexityFactor = 0.7;

  /// Create complexity from analysis results
  factory VideoComplexity.fromAnalysis({
    required double sceneChangesPerSecond,
    required double motionIntensity,
    required double signalVariance,
    required double noiseLevel,
    required double bitrateEfficiency,
    required double analyzedDuration,
  }) {
    final complexityFactor = _calculateComplexityFactor(
      sceneChangesPerSecond,
      motionIntensity,
      signalVariance,
      noiseLevel,
      bitrateEfficiency,
    );

    return VideoComplexity(
      sceneChangesPerSecond: sceneChangesPerSecond,
      motionIntensity: motionIntensity,
      signalVariance: signalVariance,
      noiseLevel: noiseLevel,
      bitrateEfficiency: bitrateEfficiency,
      analyzedDuration: analyzedDuration,
      complexityFactor: complexityFactor,
    );
  }

  /// Calculate overall complexity factor from individual metrics
  static double _calculateComplexityFactor(
    double sceneChanges,
    double motion,
    double signal,
    double noise,
    double bitrate,
  ) {
    final sceneWeight = 0.25;
    final motionWeight = 0.35;
    final signalWeight = 0.20;
    final noiseWeight = 0.10;
    final bitrateWeight = 0.10;

    final weightedSum = (sceneChanges * sceneWeight) +
        (motion * motionWeight) +
        (signal * signalWeight) +
        (noise * noiseWeight) +
        (bitrate * bitrateWeight);

    return (0.5 + (weightedSum * 1.5)).clamp(0.5, 2.0);
  }

  /// Get human-readable complexity level
  String get complexityLevel {
    if (complexityFactor < 0.7) return 'Simple';
    if (complexityFactor < 1.3) return 'Normal';
    return 'Complex';
  }

  /// Get detailed analysis summary
  String get analysisDescription {
    final level = complexityLevel;
    final sceneRate = sceneChangesPerSecond.toStringAsFixed(2);
    final motion = (motionIntensity * 100).toStringAsFixed(1);
    final signal = (signalVariance * 100).toStringAsFixed(1);

    return '$level complexity (${complexityFactor.toStringAsFixed(2)}): '
        '$sceneRate scenes/sec, $motion% motion, $signal% detail';
  }

  @override
  String toString() {
    return 'VideoComplexity(factor: ${complexityFactor.toStringAsFixed(2)}, '
        'level: $complexityLevel)';
  }
}

/// Service for analyzing video complexity to optimize compression parameters
class ComplexityAnalyzer {
  static const _analysisVerbosity = ['-hide_banner', '-loglevel', 'info'];
  static const _analysisTimeoutSeconds = 20;
  static const _sampleDurationSeconds = 30;

  /// Analyze video complexity with optional duration limit
  Future<VideoComplexity> analyze(XFile videoFile, MediaFile mediaInfo) async {
    logger.i('Starting complexity analysis for: ${videoFile.name}');
    logger.d('Video info - Duration: ${_getVideoDuration(mediaInfo)}s, '
             'Size: ${mediaInfo.size} bytes');

    try {
      final analysisStartTime = DateTime.now();
      
      final sceneChanges = await _analyzeSceneChanges(videoFile);
      logger.d('Scene analysis completed: $sceneChanges changes/sec');

      final motionIntensity = await _analyzeMotion(videoFile);
      logger.d('Motion analysis completed: ${(motionIntensity * 100).toStringAsFixed(1)}%');

      final signalStats = await _analyzeSignalStats(videoFile);
      logger.d('Signal analysis completed: variance=${(signalStats * 100).toStringAsFixed(1)}%');

      final noiseLevel = await _analyzeNoise(videoFile);
      logger.d('Noise analysis completed: ${(noiseLevel * 100).toStringAsFixed(1)}%');

      final bitrateEfficiency = _calculateBitrateEfficiency(mediaInfo);
      logger.d('Bitrate efficiency: ${bitrateEfficiency.toStringAsFixed(2)}x');

      final analysisTime = DateTime.now().difference(analysisStartTime);
      logger.d('Total analysis time: ${analysisTime.inMilliseconds}ms');

      final complexity = VideoComplexity.fromAnalysis(
        sceneChangesPerSecond: sceneChanges,
        motionIntensity: motionIntensity,
        signalVariance: signalStats,
        noiseLevel: noiseLevel,
        bitrateEfficiency: bitrateEfficiency,
        analyzedDuration: _sampleDurationSeconds.toDouble(),
      );

      logger.i('Complexity analysis completed: ${complexity.analysisDescription}');
      return complexity;

    } catch (e, stackTrace) {
      logger.w('Complexity analysis failed, using simple fallback: $e');
      logger.d('Stack trace: $stackTrace');
      return const VideoComplexity.simple();
    }
  }

  /// Analyze scene changes per second
  Future<double> _analyzeSceneChanges(XFile videoFile) async {
    logger.d('Starting scene change analysis...');
    
    final result = await _runFFmpegAnalysis(
      videoFile,
      ['-filter:v', 'select=gt(scene\\,0.3),showinfo', '-vsync', 'vfr', '-f', 'null', '-'],
      'scene change',
    );

    int frameCount = 0;
    for (final line in result) {
      if (line.contains('frame=')) {
        final match = RegExp(r'frame=\s*(\d+)').firstMatch(line);
        if (match != null) {
          frameCount = int.parse(match.group(1)!);
        }
      }
    }

    logger.d('Scene change frames detected: $frameCount');
    final sceneChangesPerSecond = frameCount / _sampleDurationSeconds;
    return sceneChangesPerSecond;
  }

  /// Analyze motion intensity using frame differences
  Future<double> _analyzeMotion(XFile videoFile) async {
    logger.d('Starting motion analysis...');
    
    final result = await _runFFmpegAnalysis(
      videoFile,
      ['-filter:v', 'select=not(mod(n\\,30)),showinfo', '-vsync', 'vfr', '-f', 'null', '-'],
      'motion',
    );

    int frameCount = 0;
    for (final line in result) {
      if (line.contains('frame=')) {
        final match = RegExp(r'frame=\s*(\d+)').firstMatch(line);
        if (match != null) {
          frameCount = int.parse(match.group(1)!);
        }
      }
    }

    logger.d('Motion sample frames: $frameCount');
    final motionScore = (frameCount / 60.0).clamp(0.0, 1.0);
    return motionScore;
  }

  /// Analyze signal statistics for detail complexity
  Future<double> _analyzeSignalStats(XFile videoFile) async {
    logger.d('Starting signal statistics analysis...');
    
    final result = await _runFFmpegAnalysis(
      videoFile,
      ['-filter:v', 'signalstats', '-f', 'null', '-'],
      'signal stats',
    );

    double totalVariance = 0.0;
    int frameCount = 0;

    for (final line in result) {
        if (line.contains('YDIF:')) {
        final match = RegExp(r'YDIF:([0-9]+(?:\.[0-9]+)?)').firstMatch(line);
        if (match != null) {
          final variance = double.parse(match.group(1)!);
          totalVariance += variance;
          frameCount++;
          logger.d('Signal variance: $variance');
        }
      }
    }

    logger.d('Signal frames analyzed: $frameCount');
    if (frameCount == 0) return 0.4;
    
    final avgVariance = (totalVariance / frameCount / 255.0).clamp(0.0, 1.0);
    return avgVariance;
  }

  /// Analyze noise levels using signal statistics
  Future<double> _analyzeNoise(XFile videoFile) async {
    logger.d('Starting noise analysis...');
    
    final result = await _runFFmpegAnalysis(
      videoFile,
      ['-filter:v', 'signalstats', '-f', 'null', '-'],
      'noise',
    );

    double noiseSum = 0.0;
    int measurements = 0;

    for (final line in result) {
      if (line.contains('YMIN:') && line.contains('YMAX:')) {
        final minMatch = RegExp(r'YMIN:([0-9]+(?:\.[0-9]+)?)').firstMatch(line);
        final maxMatch = RegExp(r'YMAX:([0-9]+(?:\.[0-9]+)?)').firstMatch(line);
        if (minMatch != null && maxMatch != null) {
          final yMin = double.parse(minMatch.group(1)!);
          final yMax = double.parse(maxMatch.group(1)!);
          final range = yMax - yMin;
          noiseSum += range;
          measurements++;
          logger.d('Luminance range: $range');
        }
      }
    }

    logger.d('Noise measurements taken: $measurements');
    if (measurements == 0) return 0.2;
    
    final avgNoise = (noiseSum / measurements / 255.0).clamp(0.0, 1.0);
    return avgNoise;
  }

  /// Calculate bitrate efficiency based on video properties
  double _calculateBitrateEfficiency(MediaFile mediaInfo) {
    final videoStream = mediaInfo.streams.whereType<VideoStream>().firstOrNull;
    if (videoStream == null) return 1.0;

    final pixels = videoStream.width * videoStream.height;
    final theoreticalBitrate = _calculateTheoreticalBitrate(pixels);
    
    logger.d('Actual bitrate: ${videoStream.bitrate}, Theoretical: $theoreticalBitrate');
    
    return (videoStream.bitrate / theoreticalBitrate).clamp(0.1, 5.0);
  }

  /// Calculate theoretical bitrate for given pixel count
  double _calculateTheoreticalBitrate(int pixels) {
    if (pixels >= 3840 * 2160) return 15000000;
    if (pixels >= 2560 * 1440) return 8000000;
    if (pixels >= 1920 * 1080) return 5000000;
    if (pixels >= 1280 * 720) return 2500000;
    return 1000000;
  }

  /// Run FFmpeg analysis with timeout and error handling
  Future<List<String>> _runFFmpegAnalysis(
    XFile videoFile,
    List<String> filterArgs,
    String analysisType,
  ) async {
    final args = [
      ..._analysisVerbosity,
      '-t', _sampleDurationSeconds.toString(),
      '-i', videoFile.path,
      ...filterArgs,
    ];

    logger.d('Running $analysisType analysis: ffmpeg ${args.join(' ')}');

    try {
      final result = await Process.run(
        'ffmpeg',
        args,
      ).timeout(const Duration(seconds: _analysisTimeoutSeconds));

      if (result.exitCode != 0) {
        logger.w('FFmpeg $analysisType analysis failed: ${result.stderr}');
        return <String>[];
      }

      final lines = result.stderr.toString().split('\n');
      logger.d('$analysisType analysis returned ${lines.length} lines');
      return lines;

    } on TimeoutException {
      logger.w('$analysisType analysis timed out after ${_analysisTimeoutSeconds}s');
      return <String>[];
    } catch (e) {
      logger.e('$analysisType analysis error: $e');
      return <String>[];
    }
  }

  /// Get video duration from media info
  double _getVideoDuration(MediaFile mediaInfo) {
    final videoStream = mediaInfo.streams.whereType<VideoStream>().firstOrNull;
    return videoStream?.duration ?? 0.0;
  }
}