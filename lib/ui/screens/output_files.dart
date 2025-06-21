import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:yaffuu/logic/managers/output_file.dart';
import 'package:yaffuu/main.dart';
import 'package:yaffuu/ui/screens/loading.dart';
import 'package:yaffuu/styles/text.dart';
import 'package:yaffuu/ui/components/context_menu.dart';
import 'package:yaffuu/ui/components/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_list_plus/animated_list_plus.dart';

class OutputFilesScreen extends StatefulWidget {
  const OutputFilesScreen({super.key});

  @override
  State<OutputFilesScreen> createState() => _OutputFilesScreenState();
}

class _OutputFilesScreenState extends State<OutputFilesScreen> {
  late OutputFileManager _outputManager;
  List<OutputFileInfo> _files = [];
  StorageStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _outputManager = getIt<AppInfo>().outputFileManager;
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    // Only show loading on initial load, not on refresh
    if (_files.isEmpty) {
      setState(() => _loading = true);
    }
    
    try {
      final files = await _outputManager.getOutputFiles();
      final stats = await _outputManager.getStorageStats();
      
      setState(() {
        _files = files;
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error loading files: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveFile(OutputFileInfo fileInfo) async {
    try {
      // Let user choose where to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save ${fileInfo.name}',
        fileName: fileInfo.name,
        allowedExtensions: [fileInfo.extension.replaceFirst('.', '')],
        type: FileType.custom,
      );

      if (outputPath != null) {
        // Copy the file to the chosen location
        final sourceFile = File(fileInfo.file.path);
        final targetFile = File(outputPath);
        
        await sourceFile.copy(targetFile.path);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('File Saved'),
              content: Text('File saved to ${path.dirname(outputPath)}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error saving file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _shareFile(OutputFileInfo fileInfo) async {
    try {
      // For now, just copy the file path since share_plus might not be available
      await Clipboard.setData(ClipboardData(text: fileInfo.file.path));
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('File Path Copied'),
            content: const Text('File path copied to clipboard for sharing'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error sharing file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _copyFile(OutputFileInfo fileInfo) async {
    try {
      // Copy to clipboard (file path)
      await Clipboard.setData(ClipboardData(text: fileInfo.file.path));
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Path Copied'),
            content: const Text('File path copied to clipboard'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error copying file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(OutputFileInfo fileInfo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete ${fileInfo.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _outputManager.deleteOutputFile(fileInfo.file);
        await _loadFiles(); // Refresh the list
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('File Deleted'),
              content: Text('${fileInfo.name} deleted'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Error deleting file: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllFiles() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Files'),
        content: const Text('Are you sure you want to delete all output files? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _outputManager.clearAllFiles();
        await _loadFiles(); // Refresh the list
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Files Cleared'),
              content: const Text('All files cleared'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Error clearing files: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaffuuAppBar(
        leftChildren: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Storage Usage Header
                  if (_stats != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title only
                        const Text('Storage Usage', style: titleStyle),
                        
                        const SizedBox(height: 16),
                        
                        // Progress bar
                        LinearProgressIndicator(
                          value: _stats!.usagePercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _stats!.isAtLimit
                                ? Colors.red
                                : _stats!.isNearLimit
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Stats row below progress bar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Size and files info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_stats!.formattedCurrentSize} / ${_stats!.formattedMaxSize}'),
                                  const SizedBox(height: 4),
                                  Text('${_stats!.currentFiles} / ${_stats!.maxFiles} files'),
                                ],
                              ),
                            ),
                            
                            // Right side - Percentage
                            Text(
                              '${_stats!.usagePercentage.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                  
                  // Files List Header and Content
                  if (!_loading) ...[
                    // Files Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text('Files', style: titleStyle),
                        ),
                        if (_files.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep, size: 18),
                            onPressed: _clearAllFiles,
                            tooltip: 'Clear all files',
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            padding: const EdgeInsets.all(2),
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _loadFiles,
                          tooltip: 'Refresh',
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: const EdgeInsets.all(2),
                        ),
                      ],
                    ),
                  ],
                  
                  // Files List
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )
                  else if (_files.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No output files yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Process some files to see them here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ImplicitlyAnimatedList<OutputFileInfo>(
                      items: _files,
                      areItemsTheSame: (oldItem, newItem) => oldItem.file.path == newItem.file.path,
                      insertDuration: const Duration(milliseconds: 300),
                      removeDuration: const Duration(milliseconds: 250),
                      itemBuilder: (context, animation, fileInfo, index) {
                        // Create smooth in-out animations
                        final sizeAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );
                        
                        // Fade starts earlier and uses a different curve
                        final fadeAnimation = CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
                        );

                        return SizeTransition(
                          sizeFactor: sizeAnimation,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: Column(
                              children: [
                                _FileListItem(
                                  fileInfo: fileInfo,
                                  onShare: () => _shareFile(fileInfo),
                                  onCopy: () => _copyFile(fileInfo),
                                  onSave: () => _saveFile(fileInfo),
                                  onDelete: () => _deleteFile(fileInfo),
                                ),
                                if (index < _files.length - 1)
                                  const Divider(height: 1),
                              ],
                            ),
                          ),
                        );
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  final OutputFileInfo fileInfo;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _FileListItem({
    required this.fileInfo,
    required this.onShare,
    required this.onCopy,
    required this.onSave,
    required this.onDelete,
  });

  // TODO: Use a compatibility map
  IconData _getFileIcon() {
    final ext = fileInfo.extension.toLowerCase();
    if (['.mp4', '.avi', '.mov', '.mkv', '.webm'].contains(ext)) {
      return Icons.video_file;
    } else if (['.mp3', '.wav', '.aac', '.flac', '.ogg'].contains(ext)) {
      return Icons.audio_file;
    } else if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext)) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }  @override
  Widget build(BuildContext context) {
    return ContextMenuButton(
      actions: [
        ContextMenuAction(
          label: 'Save',
          icon: Icons.download,
          onTap: onSave,
        ),
        ContextMenuAction(
          label: 'Share',
          icon: Icons.share,
          onTap: onShare,
        ),
        ContextMenuAction(
          label: 'Copy Path',
          icon: Icons.copy,
          onTap: onCopy,
        ),
        ContextMenuAction(
          label: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: onDelete,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(_getFileIcon(), size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileInfo.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${fileInfo.formattedSize} • Created: ${_formatDate(fileInfo.created)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
