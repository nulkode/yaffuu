import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/domain/queue/queue_service.dart';
import 'package:yaffuu/domain/queue/queue_status.dart';
import 'package:yaffuu/domain/workflows/base/workflow.dart';
import 'package:yaffuu/domain/common/logger.dart';

// Events

/// Base class for all queue events.
sealed class QueueEvent {}

/// Event fired when the queue should be initialized and started.
final class QueueInitialized extends QueueEvent {}

/// Event fired when a workflow should be submitted to the queue for processing.
final class WorkflowSubmitted extends QueueEvent {
  /// The workflow to be executed (contains input file).
  final Workflow workflow;

  WorkflowSubmitted(this.workflow);
}

/// Event fired when an item should be removed from the queue.
final class QueueItemRemoved extends QueueEvent {
  /// The ID of the item to remove.
  final String itemId;

  QueueItemRemoved(this.itemId);
}

/// Event fired when all completed items should be cleared from the queue.
final class QueueCompletedCleared extends QueueEvent {}

/// Event fired when the entire queue should be cleared.
final class QueueCleared extends QueueEvent {}

/// Event fired when the queue should be paused.
final class QueuePaused extends QueueEvent {}

/// Event fired when the queue should be resumed.
final class QueueResumed extends QueueEvent {}

/// Internal event fired when the queue status is updated.
final class _QueueStatusUpdated extends QueueEvent {
  /// The updated queue status.
  final QueueStatus status;

  _QueueStatusUpdated(this.status);
}

// States

/// Base class for all queue states.
sealed class QueueState {
  /// The current status of the queue.
  final QueueStatus status;

  const QueueState(this.status);
}

/// Initial state when the queue has not been initialized.
final class QueueInitial extends QueueState {
  const QueueInitial() : super(const QueueStatus(items: []));
}

/// State when the queue is loaded and operational.
final class QueueLoaded extends QueueState {
  const QueueLoaded(super.status);
}

/// State when an error occurs in queue operations.
final class QueueError extends QueueState {
  /// Error message describing what went wrong.
  final String message;

  const QueueError(super.status, this.message);
}

// BLoC

/// BLoC responsible for managing the processing queue.
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  /// Service for managing queue operations.
  final QueueService _queueService;

  /// Creates a new queue BLoC with the required queue service.
  QueueBloc(this._queueService) : super(const QueueInitial()) {
    on<QueueInitialized>(_onQueueInitialized);
    on<WorkflowSubmitted>(_onWorkflowSubmitted);
    on<QueueItemRemoved>(_onQueueItemRemoved);
    on<QueueCompletedCleared>(_onQueueCompletedCleared);
    on<QueueCleared>(_onQueueCleared);
    on<QueuePaused>(_onQueuePaused);
    on<QueueResumed>(_onQueueResumed);
    on<_QueueStatusUpdated>(_onQueueStatusUpdated);
  }

  /// Handles queue initialization by setting up status stream listening.
  void _onQueueInitialized(QueueInitialized event, Emitter<QueueState> emit) {
    logger.i('Initializing queue');
    
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

  /// Handles workflow submission by delegating to the queue service.
  void _onWorkflowSubmitted(WorkflowSubmitted event, Emitter<QueueState> emit) async {
    try {
      logger.i('Submitting workflow to queue: ${event.workflow.runtimeType}');
      
      // Add the workflow to the queue (it now contains its input file)
      await _queueService.addToQueue(event.workflow);
    } catch (e) {
      logger.e('Failed to submit workflow to queue: $e');
      emit(QueueError(state.status, 'Failed to add to queue: $e'));
    }
  }

  /// Handles queue item removal by delegating to the queue service.
  void _onQueueItemRemoved(QueueItemRemoved event, Emitter<QueueState> emit) {
    try {
      logger.i('Removing item from queue: ${event.itemId}');
      final removed = _queueService.removeFromQueue(event.itemId);
      if (!removed) {
        emit(QueueError(state.status, 'Failed to remove item from queue'));
      }
    } catch (e) {
      logger.e('Failed to remove from queue: $e');
      emit(QueueError(state.status, 'Failed to remove from queue: $e'));
    }
  }

  /// Handles clearing completed items by delegating to the queue service.
  void _onQueueCompletedCleared(QueueCompletedCleared event, Emitter<QueueState> emit) {
    try {
      logger.i('Clearing completed items from queue');
      _queueService.clearCompleted();
    } catch (e) {
      logger.e('Failed to clear completed: $e');
      emit(QueueError(state.status, 'Failed to clear completed: $e'));
    }
  }

  /// Handles clearing the entire queue by delegating to the queue service.
  void _onQueueCleared(QueueCleared event, Emitter<QueueState> emit) {
    try {
      logger.i('Clearing entire queue');
      _queueService.clearAll();
    } catch (e) {
      logger.e('Failed to clear all: $e');
      emit(QueueError(state.status, 'Failed to clear all: $e'));
    }
  }

  /// Handles queue pausing by delegating to the queue service.
  void _onQueuePaused(QueuePaused event, Emitter<QueueState> emit) {
    try {
      logger.i('Pausing queue');
      _queueService.pauseQueue();
    } catch (e) {
      logger.e('Failed to pause queue: $e');
      emit(QueueError(state.status, 'Failed to pause queue: $e'));
    }
  }

  /// Handles queue resuming by delegating to the queue service.
  void _onQueueResumed(QueueResumed event, Emitter<QueueState> emit) {
    try {
      logger.i('Resuming queue');
      _queueService.resumeQueue();
    } catch (e) {
      logger.e('Failed to resume queue: $e');
      emit(QueueError(state.status, 'Failed to resume queue: $e'));
    }
  }

  /// Handles internal queue status updates by emitting new loaded state.
  void _onQueueStatusUpdated(_QueueStatusUpdated event, Emitter<QueueState> emit) {
    emit(QueueLoaded(event.status));
  }

  /// Disposes of the queue service when the BLoC is closed.
  @override
  Future<void> close() {
    logger.i('Closing queue BLoC');
    _queueService.dispose();
    return super.close();
  }
}
