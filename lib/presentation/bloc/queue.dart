import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/domain/queue/queue_service.dart';
import 'package:yaffuu/domain/queue/queue_status.dart';
import 'package:yaffuu/domain/workflows/base/workflow.dart';
import 'package:yaffuu/domain/common/logger.dart';

// Events
abstract class QueueEvent {}

class QueueStarted extends QueueEvent {}

class AddWorkflowToQueue extends QueueEvent {
  final Workflow workflow;
  final XFile inputFile;

  AddWorkflowToQueue(this.workflow, this.inputFile);
}

class RemoveFromQueue extends QueueEvent {
  final String itemId;

  RemoveFromQueue(this.itemId);
}

class ClearCompleted extends QueueEvent {}

class ClearAll extends QueueEvent {}

class PauseQueue extends QueueEvent {}

class ResumeQueue extends QueueEvent {}

class _QueueStatusUpdated extends QueueEvent {
  final QueueStatus status;

  _QueueStatusUpdated(this.status);
}

// States
abstract class QueueState {
  final QueueStatus status;

  const QueueState(this.status);
}

class QueueInitial extends QueueState {
  const QueueInitial() : super(const QueueStatus(items: []));
}

class QueueLoaded extends QueueState {
  const QueueLoaded(super.status);
}

class QueueError extends QueueState {
  final String message;

  const QueueError(super.status, this.message);
}

// Bloc
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueService _queueService;

  QueueBloc(this._queueService) : super(const QueueInitial()) {
    on<QueueStarted>(_onQueueStarted);
    on<AddWorkflowToQueue>(_onAddWorkflowToQueue);
    on<RemoveFromQueue>(_onRemoveFromQueue);
    on<ClearCompleted>(_onClearCompleted);
    on<ClearAll>(_onClearAll);
    on<PauseQueue>(_onPauseQueue);
    on<ResumeQueue>(_onResumeQueue);
    on<_QueueStatusUpdated>(_onQueueStatusUpdated);
  }

  void _onQueueStarted(QueueStarted event, Emitter<QueueState> emit) {
    // Listen to queue status updates
    _queueService.statusStream.listen(
      (status) => add(_QueueStatusUpdated(status)),
      onError: (error) {
        logger.e('Queue status stream error: $error');
        emit(QueueError(state.status, error.toString()));
      },
    );

    // Emit initial status
    emit(QueueLoaded(_queueService.currentStatus));
  }

  void _onAddWorkflowToQueue(
      AddWorkflowToQueue event, Emitter<QueueState> emit) {
    try {
      _queueService.addToQueue(event.workflow, event.inputFile);
    } catch (e) {
      logger.e('Failed to add workflow to queue: $e');
      emit(QueueError(state.status, 'Failed to add to queue: $e'));
    }
  }

  void _onRemoveFromQueue(RemoveFromQueue event, Emitter<QueueState> emit) {
    try {
      final removed = _queueService.removeFromQueue(event.itemId);
      if (!removed) {
        emit(QueueError(state.status, 'Failed to remove item from queue'));
      }
    } catch (e) {
      logger.e('Failed to remove from queue: $e');
      emit(QueueError(state.status, 'Failed to remove from queue: $e'));
    }
  }

  void _onClearCompleted(ClearCompleted event, Emitter<QueueState> emit) {
    try {
      _queueService.clearCompleted();
    } catch (e) {
      logger.e('Failed to clear completed: $e');
      emit(QueueError(state.status, 'Failed to clear completed: $e'));
    }
  }

  void _onClearAll(ClearAll event, Emitter<QueueState> emit) {
    try {
      _queueService.clearAll();
    } catch (e) {
      logger.e('Failed to clear all: $e');
      emit(QueueError(state.status, 'Failed to clear all: $e'));
    }
  }

  void _onPauseQueue(PauseQueue event, Emitter<QueueState> emit) {
    try {
      _queueService.pauseQueue();
    } catch (e) {
      logger.e('Failed to pause queue: $e');
      emit(QueueError(state.status, 'Failed to pause queue: $e'));
    }
  }

  void _onResumeQueue(ResumeQueue event, Emitter<QueueState> emit) {
    try {
      _queueService.resumeQueue();
    } catch (e) {
      logger.e('Failed to resume queue: $e');
      emit(QueueError(state.status, 'Failed to resume queue: $e'));
    }
  }

  void _onQueueStatusUpdated(
      _QueueStatusUpdated event, Emitter<QueueState> emit) {
    emit(QueueLoaded(event.status));
  }

  @override
  Future<void> close() {
    _queueService.dispose();
    return super.close();
  }
}
