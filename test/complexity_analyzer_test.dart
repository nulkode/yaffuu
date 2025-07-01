import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/media/media_file_analyzer.dart';
import 'package:yaffuu/domain/workflows/compression/threshold/complexity_analyzer.dart';

void main() {
  group('ComplexityAnalyzer Tests', () {
    late ComplexityAnalyzer analyzer;
    late MediaFileAnalyzer mediaAnalyzer;
    late File testVideoFile;
    late XFile testVideo;

    setUpAll(() {
      analyzer = ComplexityAnalyzer();
      mediaAnalyzer = MediaFileAnalyzer();
      
      testVideoFile = File('test/samples/video.mp4');
      testVideo = XFile(testVideoFile.path);
    });

    test('should find test video file', () {
      expect(testVideoFile.existsSync(), isTrue, 
             reason: 'Test video file should exist at test/samples/video.mp4');
    });

    test('should analyze video complexity successfully', () async {
      // Arrange
      final (mediaFile, _) = await mediaAnalyzer.analyze(testVideo);
      
      // Act
      final complexity = await analyzer.analyze(testVideo, mediaFile);
      
      // Assert
      expect(complexity, isNotNull);
      expect(complexity.complexityFactor, inInclusiveRange(0.5, 2.0));
      expect(complexity.sceneChangesPerSecond, greaterThanOrEqualTo(0.0));
      expect(complexity.motionIntensity, inInclusiveRange(0.0, 1.0));
      expect(complexity.signalVariance, inInclusiveRange(0.0, 1.0));
      expect(complexity.noiseLevel, inInclusiveRange(0.0, 1.0));
      expect(complexity.bitrateEfficiency, greaterThan(0.0));
      expect(complexity.analyzedDuration, equals(30.0)); // Updated to 30s
      
      print('Complexity Analysis Results:');
      print('- Factor: ${complexity.complexityFactor}');
      print('- Level: ${complexity.complexityLevel}');
      print('- Scene Changes/sec: ${complexity.sceneChangesPerSecond}');
      print('- Motion Intensity: ${(complexity.motionIntensity * 100).toStringAsFixed(1)}%');
      print('- Signal Variance: ${(complexity.signalVariance * 100).toStringAsFixed(1)}%');
      print('- Noise Level: ${(complexity.noiseLevel * 100).toStringAsFixed(1)}%');
      print('- Bitrate Efficiency: ${complexity.bitrateEfficiency.toStringAsFixed(2)}x');
      print('- Description: ${complexity.analysisDescription}');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('should return valid complexity level', () async {
      // Arrange
      final (mediaFile, _) = await mediaAnalyzer.analyze(testVideo);
      
      // Act
      final complexity = await analyzer.analyze(testVideo, mediaFile);
      
      // Assert
      expect(complexity.complexityLevel, isIn(['Simple', 'Normal', 'Complex']));
    });

    test('should handle analysis timeout gracefully', () async {
      // This test verifies that the analyzer doesn't hang indefinitely
      final (mediaFile, _) = await mediaAnalyzer.analyze(testVideo);
      
      final stopwatch = Stopwatch()..start();
      final complexity = await analyzer.analyze(testVideo, mediaFile);
      stopwatch.stop();
      
      // Should complete within reasonable time (allowing buffer over the 20s timeout)
      expect(stopwatch.elapsed.inSeconds, lessThan(35));
      expect(complexity, isNotNull);
      
      print('Analysis completed in: ${stopwatch.elapsed.inSeconds}s');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('should create simple fallback complexity', () {
      // Act
      const complexity = VideoComplexity.simple();
      
      // Assert
      expect(complexity.complexityFactor, equals(0.7));
      expect(complexity.complexityLevel, isIn(['Simple', 'Normal']));
      expect(complexity.motionIntensity, equals(0.3));
      expect(complexity.signalVariance, equals(0.4));
      expect(complexity.noiseLevel, equals(0.2));
      expect(complexity.bitrateEfficiency, equals(1.0));
    });

    test('should create complexity from analysis results', () {
      // Arrange
      const sceneChanges = 0.5;
      const motion = 0.7;
      const signal = 0.6;
      const noise = 0.3;
      const bitrate = 1.2;
      const duration = 30.0; // Updated to match new sample duration
      
      // Act
      final complexity = VideoComplexity.fromAnalysis(
        sceneChangesPerSecond: sceneChanges,
        motionIntensity: motion,
        signalVariance: signal,
        noiseLevel: noise,
        bitrateEfficiency: bitrate,
        analyzedDuration: duration,
      );
      
      // Assert
      expect(complexity.sceneChangesPerSecond, equals(sceneChanges));
      expect(complexity.motionIntensity, equals(motion));
      expect(complexity.signalVariance, equals(signal));
      expect(complexity.noiseLevel, equals(noise));
      expect(complexity.bitrateEfficiency, equals(bitrate));
      expect(complexity.analyzedDuration, equals(duration));
      expect(complexity.complexityFactor, inInclusiveRange(0.5, 2.0));
      
      print('Custom complexity factor: ${complexity.complexityFactor}');
      print('Custom complexity level: ${complexity.complexityLevel}');
    });

    test('should handle missing video file gracefully', () async {
      // Arrange
      final nonExistentVideo = XFile('test/samples/nonexistent.mp4');
      
      // Act & Assert
      expect(() async {
        await mediaAnalyzer.analyze(nonExistentVideo);
      }, throwsA(isA<Exception>()));
    });

    test('should produce consistent results for same video', () async {
      // Arrange
      final (mediaFile, _) = await mediaAnalyzer.analyze(testVideo);
      
      // Act
      final complexity1 = await analyzer.analyze(testVideo, mediaFile);
      final complexity2 = await analyzer.analyze(testVideo, mediaFile);
      
      // Assert - Results should be similar (allowing for reasonable variations)
      // Complexity level should be the same or adjacent (Simple/Normal/Complex)
      final level1 = complexity1.complexityLevel;
      final level2 = complexity2.complexityLevel;
      final validLevels = ['Simple', 'Normal', 'Complex'];
      expect(validLevels.contains(level1), isTrue);
      expect(validLevels.contains(level2), isTrue);
      
      // Factor difference should be reasonable (within 0.5)
      expect((complexity1.complexityFactor - complexity2.complexityFactor).abs(), 
             lessThan(0.5));
      
      print('First analysis: ${complexity1.complexityFactor} ($level1)');
      print('Second analysis: ${complexity2.complexityFactor} ($level2)');
      print('Difference: ${(complexity1.complexityFactor - complexity2.complexityFactor).abs()}');
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}