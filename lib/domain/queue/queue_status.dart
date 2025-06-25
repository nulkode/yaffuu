import 'package:cross_file/cross_file.dart';
import 'package:yaffuu/infrastructure/ffmpeg/models/progress.dart';
import 'package:yaffuu/domain/workflows/base/workflow.dart';
import 'package:yaffuu/infrastructure/ffmpeg/engines/base_engine.dart';

enum QueueItemStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

class QueueItem {
  final String id;
  final Workflow workflow;
  final XFile inputFile;
  final DateTime createdAt;
  QueueItemStatus status;
  Progress? progress;
  String? errorMessage;
  XFile? outputFile;
  DateTime? startedAt;
  DateTime? completedAt;

  QueueItem({
    required this.id,
    required this.workflow,
    required this.inputFile,
    required this.createdAt,
    this.status = QueueItemStatus.pending,
    this.progress,
    this.errorMessage,
    this.outputFile,
    this.startedAt,
    this.completedAt,
  });

  QueueItem copyWith({
    QueueItemStatus? status,
    Progress? progress,
    String? errorMessage,
    XFile? outputFile,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return QueueItem(
      id: id,
      workflow: workflow,
      inputFile: inputFile,
      createdAt: createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      outputFile: outputFile ?? this.outputFile,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Duration? get duration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  bool get isActive => status == QueueItemStatus.running;
  bool get isCompleted => status == QueueItemStatus.completed;
  bool get isFailed => status == QueueItemStatus.failed;
  bool get isPending => status == QueueItemStatus.pending;
  bool get isCancelled => status == QueueItemStatus.cancelled;
}

class QueueStatus {
  final List<QueueItem> items;
  final QueueItem? currentItem;
  final bool isProcessing;
  final FFmpegEngine? currentEngine;

  const QueueStatus({
    required this.items,
    this.currentItem,
    this.isProcessing = false,
    this.currentEngine,
  });

  QueueStatus copyWith({
    List<QueueItem>? items,
    QueueItem? currentItem,
    bool? isProcessing,
    FFmpegEngine? currentEngine,
  }) {
    return QueueStatus(
      items: items ?? this.items,
      currentItem: currentItem,
      isProcessing: isProcessing ?? this.isProcessing,
      currentEngine: currentEngine ?? this.currentEngine,
    );
  }

  List<QueueItem> get pendingItems =>
      items.where((item) => item.isPending).toList();

  List<QueueItem> get completedItems =>
      items.where((item) => item.isCompleted).toList();

  List<QueueItem> get failedItems =>
      items.where((item) => item.isFailed).toList();

  int get totalItems => items.length;
  int get completedCount => completedItems.length;
  int get failedCount => failedItems.length;
  int get pendingCount => pendingItems.length;
}
