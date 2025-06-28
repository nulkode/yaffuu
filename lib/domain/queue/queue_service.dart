import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:uuid/uuid.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/domain/queue/queue_status.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/domain/workflows/base/workflow.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/software_engine.dart';
import 'package:yaffuu/infrastructure/output_files_manager.dart';
import 'package:yaffuu/domain/common/logger.dart';

class QueueService {
  static const _uuid = Uuid();

  final List<QueueItem> _items = [];
  final OutputFileManager _outputFileManager;
  QueueItem? _currentItem;
  FFmpegEngine? _engine;
  bool _isProcessing = false;
  bool _isInitialized = false;
  HwAccel? _currentAcceleration;
  StreamSubscription? _currentSubscription;

  final StreamController<QueueStatus> _statusController =
      StreamController<QueueStatus>.broadcast();

  /// Constructor requires an output file manager
  QueueService(this._outputFileManager);

  /// Stream of queue status updates
  Stream<QueueStatus> get statusStream => _statusController.stream;

  /// Current queue status
  QueueStatus get currentStatus => QueueStatus(
        items: List.unmodifiable(_items),
        currentItem: _currentItem,
        isProcessing: _isProcessing,
        currentEngine: _engine,
      );

  /// Initialize the queue with a specific hardware acceleration
  /// Can be called multiple times to change engines
  Future<void> initialize(HwAccel hwAccel) async {
    if (_isInitialized && _currentAcceleration == hwAccel && _engine != null) {
      return;
    }

    if (_isProcessing && _currentAcceleration != hwAccel) {
      await _stopCurrentProcessing();
    }

    logger.d('Initializing queue with acceleration: ${hwAccel.displayName}');

    try {
      final newEngine = await _createEngine(hwAccel);

      _engine = null;

      _engine = newEngine;
      _currentAcceleration = hwAccel;
      _isInitialized = true;

      logger.d('Queue initialized successfully with ${hwAccel.displayName}');
      _notifyStatusChanged();
    } catch (e) {
      logger.e('Failed to initialize queue with ${hwAccel.displayName}: $e');
      rethrow;
    }
  }

  /// Check if the queue is initialized
  bool get isInitialized => _isInitialized && _engine != null;

  /// Get current acceleration method
  HwAccel? get currentAcceleration => _currentAcceleration;

  /// Add a workflow to the queue for processing
  Future<void> addToQueue(Workflow workflow) async {
    if (!isInitialized) {
      throw StateError(
          'Queue service must be initialized before adding workflows. Call initialize(hwAccel) first.');
    }

    final item = QueueItem(
      id: _uuid.v4(),
      workflow: workflow,
      inputFile: workflow.inputFile,
      createdAt: DateTime.now(),
    );

    _items.add(item);
    _notifyStatusChanged();

    if (!_isProcessing) {
      _processQueue();
    }

    logger.d('Workflow added to queue: ${item.id}');
  }

  /// Remove an item from the queue
  bool removeFromQueue(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;

    final item = _items[index];

    if (_currentItem?.id == itemId) {
      _cancelCurrentItem();
    }

    if (item.status == QueueItemStatus.pending) {
      _items.removeAt(index);
      _notifyStatusChanged();
      return true;
    }

    return false;
  }

  /// Clear completed and failed items
  void clearCompleted() {
    _items.removeWhere(
        (item) => item.isCompleted || item.isFailed || item.isCancelled);
    _notifyStatusChanged();
  }

  /// Stop all processing and clear queue
  void clearAll() {
    _cancelCurrentItem();
    _items.clear();
    _notifyStatusChanged();
  }

  /// Pause queue processing
  void pauseQueue() {
    if (_isProcessing) {
      _cancelCurrentItem();
    }
  }

  /// Resume queue processing
  void resumeQueue() {
    if (!_isProcessing && _items.any((item) => item.isPending)) {
      _processQueue();
    }
  }

  /// Create engine based on hardware acceleration preference (private)
  Future<FFmpegEngine> _createEngine(HwAccel hwAccel) async {
    FFmpegEngine engine;

    switch (hwAccel) {
      case HwAccel.none:
        engine = SoftwareEngine() as FFmpegEngine;
        break;
    }

    final isCompatible = await engine.isCompatible();
    if (!isCompatible) {
      throw Exception('Engine ${hwAccel.displayName} is not compatible');
    }

    return engine;
  }

  /// Stop current processing safely
  Future<void> _stopCurrentProcessing() async {
    if (_isProcessing) {
      _cancelCurrentItem();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Process the queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _notifyStatusChanged();

    try {
      while (_items.any((item) => item.isPending)) {
        final nextItem = _items.firstWhere(
          (item) => item.isPending,
          orElse: () => throw StateError('No pending items'),
        );

        await _processItem(nextItem);
      }
    } catch (e) {
      logger.e('Queue processing error: $e');
    } finally {
      _isProcessing = false;
      _currentItem = null;
      _notifyStatusChanged();
    }
  }

  /// Process a single queue item
  Future<void> _processItem(QueueItem item) async {
    _currentItem = item;

    try {
      _updateItemStatus(item, QueueItemStatus.running,
          startedAt: DateTime.now());

      if (_engine == null) {
        throw StateError('Engine not initialized');
      }

      final outputFilePath = await _outputFileManager
          .getNewOutputFilePath(item.workflow.inputFile.name);

      _currentSubscription =
          item.workflow.execute(_engine!, outputFilePath).listen(
        (workflowProgress) {
          if (workflowProgress.isComplete) {
          } else {
            // TODO: Extract progress information from WorkflowProgress
            // _updateItemProgress(item, progress);
          }
        },
        onError: (error) {
          logger.e('Workflow execution error: $error');
          _updateItemStatus(
            item,
            QueueItemStatus.failed,
            errorMessage: error.toString(),
            completedAt: DateTime.now(),
          );
        },
        onDone: () {
          // TODO: Get output file from workflow result metadata or another way
          // final outputFile = item.workflow.result.outputFile;
          _updateItemStatus(
            item,
            QueueItemStatus.completed,
            // outputFile: outputFile,
            completedAt: DateTime.now(),
          );
        },
      );

      await _currentSubscription?.asFuture();
    } catch (e) {
      logger.e('Item processing error: $e');
      _updateItemStatus(
        item,
        QueueItemStatus.failed,
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
      );
    } finally {
      _currentSubscription?.cancel();
      _currentSubscription = null;
    }
  }

  /// Cancel the currently running item
  void _cancelCurrentItem() {
    if (_currentItem != null) {
      FFmpegEngine.stop();

      _updateItemStatus(
        _currentItem!,
        QueueItemStatus.cancelled,
        completedAt: DateTime.now(),
      );

      _currentSubscription?.cancel();
      _currentSubscription = null;
    }
  }

  /// Update item status
  void _updateItemStatus(
    QueueItem item,
    QueueItemStatus status, {
    String? errorMessage,
    XFile? outputFile,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item.copyWith(
        status: status,
        errorMessage: errorMessage,
        outputFile: outputFile,
        startedAt: startedAt,
        completedAt: completedAt,
      );
      _notifyStatusChanged();
    }
  }

  /// Update item progress (for future use when workflow progress integration is implemented)
  // ignore: unused_element
  void _updateItemProgress(QueueItem item, Progress progress) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item.copyWith(progress: progress);
      _notifyStatusChanged();
    }
  }

  /// Notify listeners of status changes
  void _notifyStatusChanged() {
    _statusController.add(currentStatus);
  }

  /// Dispose resources
  void dispose() {
    _currentSubscription?.cancel();
    _statusController.close();
  }
}
