import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/classes/exception.dart';
import 'package:yaffuu/logic/managers/managers.dart';
import 'package:yaffuu/logic/operations/operations.dart';

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

  QueueReadyEvent(this.operation);
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

abstract class QueueState {}

abstract class QueueFileState extends QueueState {
  final XFile? file;

  QueueFileState(this.file);
}

class QueueLoadingState extends QueueState {}

class QueueReadyState extends QueueFileState {
  final BaseFFmpegManager manager;
  final Operation? operation;

  QueueReadyState(this.manager, this.operation, super.file);
}

class QueueBusyState extends QueueFileState {
  final BaseFFmpegManager manager;
  final Operation operation;
  final double progress;

  QueueBusyState(this.manager, this.operation, this.progress, super.file);
}

class QueueErrorState extends QueueFileState {
  final BaseFFmpegManager manager;
  final Operation? operation;
  final Exception exception;

  QueueErrorState(this.manager, this.operation, this.exception, super.file);
}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc() : super(QueueLoadingState()) {
    on<QueueAddOperationEvent>(_onAddOperation);
    on<QueueRemoveOperationEvent>(_onRemoveOperation);
    on<QueueClearEvent>(_onClear);
    on<QueueStopEvent>(_onStop);
    on<QueueStartEvent>(_onStart);
    on<SetManagerEvent>(_onSetManager);
    on<AddFileEvent>(_onAddFile);
    on<RemoveFileEvent>(_onRemoveFile);
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
    emit(QueueReadyState(manager, event.operation, file));
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
    emit(QueueReadyState(manager, null, file));
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
    emit(QueueReadyState(manager, null, file));
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
    emit(QueueReadyState(manager, null, file));
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
    if (operation == null) {
      return emit(
          QueueErrorState(manager, null, Exception('No operation'), file));
    }

    // TODO: start operation

    emit(QueueBusyState(manager, operation, 0, file));
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
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    final file = event.file;
    emit(QueueReadyState(manager, null, file));
  }

  void _onRemoveFile(
    RemoveFileEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    emit(QueueReadyState(manager, null, null));
  }
}
