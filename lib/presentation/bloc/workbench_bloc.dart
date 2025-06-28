import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/domain/common/constants/exception.dart';
import 'package:yaffuu/domain/ffmpeg/ffmpeg_info_service.dart';
import 'package:yaffuu/domain/media/media_file_analyzer.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/ffmpeg_info.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/media.dart';
import 'package:yaffuu/domain/common/logger.dart';
import 'package:yaffuu/main.dart';

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

/// Base class for all workbench states.
sealed class WorkbenchState {}

/// Initial state before any file is loaded.
final class WorkbenchInitial extends WorkbenchState {}

/// State while a file is being analyzed.
final class WorkbenchAnalysisInProgress extends WorkbenchState {}

/// State when file analysis is complete and all data is available.
final class WorkbenchReady extends WorkbenchState {
  /// The original input file.
  final XFile inputFile;

  /// Metadata of the loaded media file.
  final MediaFile mediaFile;

  /// Generated thumbnail image (can be null if generation failed).
  final XFile? thumbnail;

  /// FFmpeg build information including available codecs and formats.
  final FFmpegInfo ffmpegInfo;

  /// Currently selected hardware acceleration setting.
  final HwAccel currentHwAccel;

  WorkbenchReady({
    required this.inputFile,
    required this.mediaFile,
    required this.thumbnail,
    required this.ffmpegInfo,
    required this.currentHwAccel,
  });
}

/// State when file analysis fails.
final class WorkbenchAnalysisFailed extends WorkbenchState {
  /// User-friendly error message describing what went wrong during analysis.
  final String error;

  /// Technical details for debugging purposes (optional).
  final String? technicalDetails;

  WorkbenchAnalysisFailed(this.error, {this.technicalDetails});
}

/// BLoC for managing the workbench state and file analysis.
class WorkbenchBloc extends Bloc<WorkbenchEvent, WorkbenchState> {
  /// Service for analyzing media files and generating thumbnails.
  late final MediaFileAnalyzer _mediaFileAnalyzer;

  /// Service for retrieving FFmpeg build information.
  late final FFmpegInfoService _ffmpegInfoService;

  /// Manager for accessing user preferences.
  late final PreferencesManager _preferencesManager;

  /// Creates a new workbench BLoC with the required dependencies.
  WorkbenchBloc() : super(WorkbenchInitial()) {
    _mediaFileAnalyzer = getIt<MediaFileAnalyzer>();
    _ffmpegInfoService = getIt<FFmpegInfoService>();
    _preferencesManager = getIt<PreferencesManager>();

    on<FileAdded>(_onFileAdded);
    on<FileCleared>(_onFileCleared);
  }

  /// Handles the file added event by analyzing the file and gathering all required data.
  Future<void> _onFileAdded(
      FileAdded event, Emitter<WorkbenchState> emit) async {
    emit(WorkbenchAnalysisInProgress());

    try {
      logger.i('Starting analysis of file: ${event.file.path}');

      final analysisResult = await _mediaFileAnalyzer.analyze(event.file);
      final (mediaFile, thumbnail) = analysisResult;

      final ffmpegInfo = await _ffmpegInfoService.getFFmpegInfo();

      final currentHwAccel = await _preferencesManager.settings.getHwAccel();

      logger.i('File analysis completed successfully');

      emit(WorkbenchReady(
        inputFile: event.file,
        mediaFile: mediaFile,
        thumbnail: thumbnail,
        ffmpegInfo: ffmpegInfo,
        currentHwAccel: currentHwAccel,
      ));
    } catch (error) {
      logger.e('File analysis failed: $error');

      String userFriendlyMessage;
      String? technicalDetails;

      if (error is MultimediaNotFoundOrNotRecognizedException) {
        userFriendlyMessage =
            'The selected file is not a valid media file or cannot be read. Please select a supported video file.';
      } else {
        userFriendlyMessage =
            'An unexpected error occurred while analyzing the file. Please try again.';
        technicalDetails = error.toString();
      }

      emit(WorkbenchAnalysisFailed(userFriendlyMessage,
          technicalDetails: technicalDetails));
    }
  }

  /// Handles the file cleared event by resetting to initial state.
  void _onFileCleared(FileCleared event, Emitter<WorkbenchState> emit) {
    logger.i('Clearing workbench');
    emit(WorkbenchInitial());
  }
}
