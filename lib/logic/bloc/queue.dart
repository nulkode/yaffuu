import 'package:flutter_bloc/flutter_bloc.dart';
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

abstract class QueueState {}

class QueueLoadingState extends QueueState {}

class QueueReadyState extends QueueState {
  final BaseFFmpegManager manager;
  final Operation? operation;

  QueueReadyState(this.manager, this.operation);
}

class QueueBusyState extends QueueState {
  final BaseFFmpegManager manager;
  final Operation operation;
  final double progress;

  QueueBusyState(this.manager, this.operation, this.progress);
}

class QueueErrorState extends QueueState {
  final BaseFFmpegManager manager;
  final Operation? operation;
  final Exception exception;

  QueueErrorState(this.manager, this.operation, this.exception);
}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc(
  ) : super(QueueLoadingState()) {
    on<QueueAddOperationEvent>(_onAddOperation);
    on<QueueRemoveOperationEvent>(_onRemoveOperation);
    on<QueueClearEvent>(_onClear);
    on<QueueStopEvent>(_onStop);
    on<QueueStartEvent>(_onStart);
    on<SetManagerEvent>(_onSetManager);
  }

  void _checkCompatibility(BaseFFmpegManager manager) async {
    if (state is! QueueLoadingState) {
      return;
    }

    final isCompatible = await manager.isCompatible();
    if (!isCompatible) {
      add(QueueErrorEvent(Exception('FFmpeg is not compatible')));
    } else {
      add(QueueReadyEvent(null));
    }
  }

  void _onAddOperation(
    QueueAddOperationEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    emit(QueueReadyState(manager, event.operation));
  }

  void _onRemoveOperation(
    QueueRemoveOperationEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;
    emit(QueueReadyState(manager, null));
  }

  void _onClear(
    QueueClearEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueErrorState) {
      return;
    }

    final manager = (state as QueueErrorState).manager;
    emit(QueueReadyState(manager, null));
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
    emit(QueueReadyState(manager, null));
  }

  void _onStart(
    QueueStartEvent event,
    Emitter<QueueState> emit,
  ) {
    if (state is! QueueReadyState) {
      return;
    }

    final manager = (state as QueueReadyState).manager;

    final operation = (state as QueueReadyState).operation;
    if (operation == null) {
      return emit(
          QueueErrorState(manager, null, Exception('No operation')));
    }

    // TODO: start operation

    emit(QueueBusyState(manager, operation, 0));
  }

  void _onSetManager(
    SetManagerEvent event,
    Emitter<QueueState> emit,
  ) async{
    if (
      state is QueueLoadingState ||
      state is QueueReadyState
    ) {
      emit(QueueReadyState(event.manager, null));
    }
  }
}
