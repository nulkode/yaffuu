import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/domain/ffmpeg/ffmpeg_info_service.dart';
import 'package:yaffuu/domain/media/media_file_analyzer.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/ffmpeg_info.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/domain/common/logger.dart';

// Events

/// Base class for all workbench events.
sealed class WorkbenchEvent {}

/// Event fired when a user selects a file to be analyzed.
final class FileAdded extends WorkbenchEvent {
  /// The file that was selected by the user.
  final XFile file;

  FileAdded(this.file);
}

/// Event fired when the user removes the current file from the workbench.
final class FileCleared extends WorkbenchEvent {}

// States

/// Base class for all workbench states.
sealed class WorkbenchState {}

/// Initial state before any file is loaded.
final class WorkbenchInitial extends WorkbenchState {}

/// State while a file is being analyzed.
final class WorkbenchAnalysisInProgress extends WorkbenchState {}

/// State when file analysis is complete and all data is available.
final class WorkbenchReady extends WorkbenchState {
  /// Metadata of the loaded media file.
  final MediaFile mediaFile;
  
  /// Generated thumbnail image (can be null if generation failed).
  final XFile? thumbnail;
  
  /// FFmpeg build information including available codecs and formats.
  final FFmpegInfo ffmpegInfo;
  
  /// Currently selected hardware acceleration setting.
  final HwAccel currentHwAccel;

  WorkbenchReady({
    required this.mediaFile,
    required this.thumbnail,
    required this.ffmpegInfo,
    required this.currentHwAccel,
  });
}

/// State when file analysis fails.
final class WorkbenchAnalysisFailed extends WorkbenchState {
  /// Error message describing what went wrong during analysis.
  final String error;

  WorkbenchAnalysisFailed(this.error);
}

// BLoC

/// BLoC for managing the workbench state and file analysis.
class WorkbenchBloc extends Bloc<WorkbenchEvent, WorkbenchState> {
  /// Service for analyzing media files and generating thumbnails.
  final MediaFileAnalyzer _mediaFileAnalyzer;
  
  /// Service for retrieving FFmpeg build information.
  final FFmpegInfoService _ffmpegInfoService;
  
  /// Manager for accessing user preferences.
  final PreferencesManager _preferencesManager;

  /// Creates a new workbench BLoC with the required dependencies.
  WorkbenchBloc({
    required MediaFileAnalyzer mediaFileAnalyzer,
    required FFmpegInfoService ffmpegInfoService,
    required PreferencesManager preferencesManager,
  })  : _mediaFileAnalyzer = mediaFileAnalyzer,
        _ffmpegInfoService = ffmpegInfoService,
        _preferencesManager = preferencesManager,
        super(WorkbenchInitial()) {
    on<FileAdded>(_onFileAdded);
    on<FileCleared>(_onFileCleared);
  }

  /// Handles the file added event by analyzing the file and gathering all required data.
  Future<void> _onFileAdded(FileAdded event, Emitter<WorkbenchState> emit) async {
    emit(WorkbenchAnalysisInProgress());

    try {
      logger.i('Starting analysis of file: ${event.file.path}');

      // Analyze the media file to get metadata and thumbnail
      final analysisResult = await _mediaFileAnalyzer.analyze(event.file);
      final (mediaFile, thumbnail) = analysisResult;

      // Get FFmpeg build information
      final ffmpegInfo = await _ffmpegInfoService.getFFmpegInfo();

      // Get current hardware acceleration preference
      final currentHwAccel = await _preferencesManager.settings.getHwAccel();

      logger.i('File analysis completed successfully');

      emit(WorkbenchReady(
        mediaFile: mediaFile,
        thumbnail: thumbnail,
        ffmpegInfo: ffmpegInfo,
        currentHwAccel: currentHwAccel,
      ));
    } catch (error) {
      logger.e('File analysis failed: $error');
      emit(WorkbenchAnalysisFailed(error.toString()));
    }
  }

  /// Handles the file cleared event by resetting to initial state.
  void _onFileCleared(FileCleared event, Emitter<WorkbenchState> emit) {
    logger.i('Clearing workbench');
    emit(WorkbenchInitial());
  }
}
