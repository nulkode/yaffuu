import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';
import 'package:yaffuu/logic/operations/thumbnail.dart';

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

class SetManagerEvent extends QueueEvent {
  final BaseFFmpegManager manager;

  SetManagerEvent(this.manager);
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
  final BaseFFmpegManager manager;
  final Operation? operation;

  QueueReadyState(this.manager, this.operation, super.file, [super.thumbnail]);
}

class QueueBusyState extends QueueFileState {
  final BaseFFmpegManager manager;
  final Operation operation;
  final double progress;

  QueueBusyState(this.manager, this.operation, this.progress, super.file,
      [super.thumbnail]);
}

class QueueErrorState extends QueueFileState {
  final BaseFFmpegManager manager;
  final Operation? operation;
  final Exception exception;

  QueueErrorState(this.manager, this.operation, this.exception, super.file,
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
    on<SetManagerEvent>(_onSetManager);
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

    final manager = (state as QueueReadyState).manager;
    final file = (state as QueueReadyState).file;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(manager, event.operation, file, thumbnail));
  }

  void _onRemoveOperation(
    QueueRemoveOperationEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    final file = (state as QueueReadyState).file;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(manager, null, file, thumbnail));
  }

  void _onClear(
    QueueClearEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueErrorState) {
      return;
    }

    final manager = (state as QueueErrorState).manager;
    final file = (state as QueueErrorState).file;
    final thumbnail = (state as QueueErrorState).thumbnail;
    emit(QueueReadyState(manager, null, file, thumbnail));
  }

  void _onStop(
    QueueStopEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueBusyState) {
      return;
    }

    // TODO: stop operation

    final manager = (state as QueueBusyState).manager;
    final file = (state as QueueBusyState).file;
    final thumbnail = (state as QueueBusyState).thumbnail;
    emit(QueueReadyState(manager, null, file, thumbnail));
  }

  void _onStart(
    QueueStartEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    final file = (state as QueueReadyState).file;
    final operation = (state as QueueReadyState).operation;
    final thumbnail = (state as QueueReadyState).thumbnail;
    if (operation == null) {
      return emit(QueueErrorState(
          manager, null, Exception('No operation'), file, thumbnail));
    }

    // TODO: start operation

    emit(QueueBusyState(manager, operation, 0, file, thumbnail));
  }

  void _onReady(
    QueueReadyEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    final file = (state as QueueReadyState).file;
    final currentThumbnail = (state as QueueReadyState).thumbnail;

    final thumbnail = event.thumbnail ?? currentThumbnail;

    emit(QueueReadyState(manager, event.operation, file, thumbnail));
  }

  void _onSetManager(
    SetManagerEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is QueueLoadingState || state is QueueReadyState) {
      emit(QueueLoadingState());

      if (!(await event.manager.isCompatible())) {
        return emit(QueueErrorState(
            event.manager, null, FFmpegNotCompatibleException(), null));
      } else {
        emit(QueueReadyState(event.manager, null, null));
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

    final manager = (state as QueueReadyState).manager;
    final currentThumbnail = (state as QueueReadyState).thumbnail;

    emit(QueueLoadingState());

    logger.d('Adding file: ${event.file.name}');

    final file = event.file;
    manager.setFile(file);

    try {
      final thumbnail =
          await _generateThumbnail(manager, emit) ?? currentThumbnail;

      if (!emit.isDone) {
        logger.d('File added successfully');
        emit(QueueReadyState(manager, null, file, thumbnail));
      }
    } catch (error) {
      if (!emit.isDone) {
        logger.e('Error during file processing: $error');
        final exception =
            error is Exception ? error : Exception(error.toString());

        emit(QueueErrorState(manager, null, exception, file, currentThumbnail));
      }
    }
  }

  Future<XFile?> _generateThumbnail(
    BaseFFmpegManager manager,
    Emitter<QueueState> emit,
  ) async {
    manager.clearLastOutput();

    try {
      final operation =
          VideoToImageOperation(position: const Duration(seconds: 1));
      final stream = manager.execute(operation);

      await for (final progress in stream) {
        if (emit.isDone) break;
        logger.d(
            'Thumbnail generation progress: frame=${progress.frame}, fps=${progress.fps}, size=${progress.size}');
      }

      logger.d('Thumbnail generation completed successfully');
      return manager.lastOutput;
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

    final manager = (state as QueueReadyState).manager;
    final thumbnail = (state as QueueReadyState).thumbnail;
    emit(QueueReadyState(manager, null, null, thumbnail));
  }

  void _onRemoveThumbnail(
    RemoveThumbnailEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    final file = (state as QueueReadyState).file;
    final operation = (state as QueueReadyState).operation;
    emit(QueueReadyState(manager, operation, file, null));
  }
}
