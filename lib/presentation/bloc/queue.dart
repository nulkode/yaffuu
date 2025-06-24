import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/domain/constants/exception.dart';
import 'package:yaffuu/domain/logger.dart';
import 'package:yaffuu/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/ffmpeg/operations/operations.dart';
import 'package:yaffuu/ffmpeg/operations/thumbnail.dart';

// TODO: remove engine directly from the queue, use the provider

abstract class QueueEvent {}

class QueueAddOperationEvent extends QueueEvent {
  final Operation operation;

  QueueAddOperationEvent(this.operation);
}

class QueueRemoveOperationEvent extends QueueEvent {}

class QueueClearEvent extends QueueEvent {}

class QueueStopEvent extends QueueEvent {}

class QueueStartEvent extends QueueEvent {}

class QueueErrorEvent extends QueueEvent {
  final Exception exception;

  QueueErrorEvent(this.exception);
}

class QueueReadyEvent extends QueueEvent {
  final Operation? operation;
  final XFile? thumbnail;

  QueueReadyEvent(this.operation, {this.thumbnail});
}

class SetEngineEvent extends QueueEvent {
  final FFmpegEngine engine;

  SetEngineEvent(this.engine);
}

class AddFileEvent extends QueueEvent {
  final XFile file;

  AddFileEvent(this.file);
}

class RemoveFileEvent extends QueueEvent {}

class RemoveThumbnailEvent extends QueueEvent {}

abstract class QueueState {}

abstract class QueueFileState extends QueueState {
  final XFile? file;
  final XFile? thumbnail;

  QueueFileState(this.file, this.thumbnail);
}

class QueueLoadingState extends QueueState {}

class QueueReadyState extends QueueFileState {
  final FFmpegEngine engine;
  final Operation? operation;

  QueueReadyState(this.engine, this.operation, super.file, [super.thumbnail]);
}

class QueueBusyState extends QueueFileState {
  final FFmpegEngine engine;
  final Operation operation;
  final double progress;

  QueueBusyState(this.engine, this.operation, this.progress, super.file,
      [super.thumbnail]);
}

class QueueErrorState extends QueueFileState {
  final FFmpegEngine engine;
  final Operation? operation;
  final Exception exception;

  QueueErrorState(this.engine, this.operation, this.exception, super.file,
      [super.thumbnail]);
}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc() : super(QueueLoadingState()) {
    on<QueueAddOperationEvent>(_onAddOperation);
    on<QueueRemoveOperationEvent>(_onRemoveOperation);
    on<QueueClearEvent>(_onClear);
    on<QueueStopEvent>(_onStop);
    on<QueueStartEvent>(_onStart);
    on<QueueReadyEvent>(_onReady);
    on<SetEngineEvent>(_onSetEngine);
    on<AddFileEvent>(_onAddFile);
    on<RemoveFileEvent>(_onRemoveFile);
    on<RemoveThumbnailEvent>(_onRemoveThumbnail);
  }

  void _onAddOperation(
    QueueAddOperationEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final file = (state as QueueReadyState).file;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(engine, event.operation, file, thumbnail));
  }

  void _onRemoveOperation(
    QueueRemoveOperationEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final file = (state as QueueReadyState).file;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(engine, null, file, thumbnail));
  }

  void _onClear(
    QueueClearEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueErrorState) {
      return;
    }

    final engine = (state as QueueErrorState).engine;
    final file = (state as QueueErrorState).file;
    final thumbnail = (state as QueueErrorState).thumbnail;
    emit(QueueReadyState(engine, null, file, thumbnail));
  }

  void _onStop(
    QueueStopEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueBusyState) {
      return;
    }

    // TODO: stop operation

    final engine = (state as QueueBusyState).engine;
    final file = (state as QueueBusyState).file;
    final thumbnail = (state as QueueBusyState).thumbnail;
    emit(QueueReadyState(engine, null, file, thumbnail));
  }

  void _onStart(
    QueueStartEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final file = (state as QueueReadyState).file;
    final operation = (state as QueueReadyState).operation;
    final thumbnail = (state as QueueReadyState).thumbnail;
    if (operation == null) {
      return emit(QueueErrorState(
          engine, null, Exception('No operation'), file, thumbnail));
    }

    // TODO: start operation

    emit(QueueBusyState(engine, operation, 0, file, thumbnail));
  }

  void _onReady(
    QueueReadyEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final file = (state as QueueReadyState).file;
    final currentThumbnail = (state as QueueReadyState).thumbnail;

    final thumbnail = event.thumbnail ?? currentThumbnail;

    emit(QueueReadyState(engine, event.operation, file, thumbnail));
  }

  void _onSetEngine(
    SetEngineEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is QueueLoadingState || state is QueueReadyState) {
      emit(QueueLoadingState());

      if (!(await event.engine.isCompatible())) {
        return emit(QueueErrorState(
            event.engine, null, FFmpegNotCompatibleException(), null));
      } else {
        emit(QueueReadyState(event.engine, null, null));
      }
    }
  }

  void _onAddFile(
    AddFileEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final currentThumbnail = (state as QueueReadyState).thumbnail;

    emit(QueueLoadingState());

    logger.d('Adding file: ${event.file.name}');

    final file = event.file;
    engine.setFile(file);

    try {
      final thumbnail =
          await _generateThumbnail(engine, emit) ?? currentThumbnail;

      if (!emit.isDone) {
        logger.d('File added successfully');
        emit(QueueReadyState(engine, null, file, thumbnail));
      }
    } catch (error) {
      if (!emit.isDone) {
        logger.e('Error during file processing: $error');
        final exception =
            error is Exception ? error : Exception(error.toString());

        emit(QueueErrorState(engine, null, exception, file, currentThumbnail));
      }
    }
  }

  Future<XFile?> _generateThumbnail(
    FFmpegEngine engine,
    Emitter<QueueState> emit,
  ) async {
    engine.clearLastOutput();

    try {
      final operation =
          VideoToImageOperation(position: const Duration(seconds: 1));
      final stream = engine.execute(operation);

      await for (final progress in stream) {
        if (emit.isDone) break;
        logger.d(
            'Thumbnail generation progress: frame=${progress.frame}, fps=${progress.fps}, size=${progress.size}');
      }

      logger.d('Thumbnail generation completed successfully');
      return engine.lastOutput;
    } catch (error) {
      logger.e('Error during thumbnail generation: $error');
      return null;
    }
  }

  void _onRemoveFile(
    RemoveFileEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(engine, null, null, thumbnail));
  }

  void _onRemoveThumbnail(
    RemoveThumbnailEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final engine = (state as QueueReadyState).engine;
    final file = (state as QueueReadyState).file;
    final operation = (state as QueueReadyState).operation;
    emit(QueueReadyState(engine, operation, file, null));
  }
}
