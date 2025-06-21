import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/queue.dart';
import 'package:yaffuu/styles/text.dart';
import 'package:yaffuu/ui/components/appbar.dart';
import 'package:go_router/go_router.dart';

// TODO: implement pasting files

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaffuuAppBar(
        leftChildren: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  QueueStatus(),
                  SizedBox(height: 8),
                  Text('Input', style: titleStyle),
                  SizedBox(height: 8),
                  FilePickerCard(),
                  SizedBox(height: 16),
                  Text('Operation', style: titleStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QueueStatus extends StatelessWidget {
  const QueueStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {},
            child: BlocBuilder<QueueBloc, QueueState>(
              builder: (context, state) {
                final color = state is QueueReadyState
                    ? Colors.green
                    : state is QueueBusyState
                        ? Colors.orange
                        : state is QueueErrorState
                            ? Colors.red
                            : state is QueueLoadingState
                                ? Colors.blue
                                : Colors.grey;

                final text = state is QueueReadyState
                    ? 'Ready'
                    : state is QueueBusyState
                        ? 'Busy'
                        : state is QueueErrorState
                            ? 'Error'
                            : state is QueueLoadingState
                                ? 'Loading'
                                : 'Unknown';

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Text(text),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class FilePickerCard extends StatelessWidget {
  const FilePickerCard({
    super.key,
  });

  @override  Widget build(BuildContext context) {    return BlocBuilder<QueueBloc, QueueState>(builder: (context, state) {
      final disabled = state is! QueueReadyState;
      final loading = state is QueueLoadingState;
      final showFiles = state is QueueReadyState && state.file is XFile;
      final thumbnail = state is QueueReadyState ? state.thumbnail : null;      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card.outlined(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: !disabled && !showFiles
                  ? () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowMultiple: false,
                        allowedExtensions: ['mp4'],
                        compressionQuality: 0,
                        lockParentWindow: true,
                      );

                      if (result != null && context.mounted) {
                        context
                            .read<QueueBloc>()
                            .add(AddFileEvent(result.xFiles.first));
                      }
                    }
                  : null,
              child: SizedBox(
                height: showFiles ? 100 : 150,
                child: Center(
                  child: !loading
                      ? (!showFiles
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  'Add a new media file',
                                ),
                                Text(
                                  'or drop it here.',
                                ),
                              ],
                            )
                          : _buildFileDisplay(context, state, thumbnail))
                      : CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary),
                        ),
                ),
              ),
            ),
          ),          if (showFiles) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    context.read<QueueBloc>().add(RemoveFileEvent());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: const Text('Remove File'),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }  Widget _buildFileDisplay(BuildContext context, QueueState state, XFile? thumbnail) {
    if (state is! QueueReadyState || state.file == null) {
      return const Text('No file selected');
    }

    final file = state.file!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Thumbnail or placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 60,
              child: thumbnail != null
                  ? Image.file(
                      File(thumbnail.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.video_file, size: 30, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // File information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    final size = snapshot.data;
                    final sizeText = size != null 
                        ? _formatFileSize(size)
                        : 'Unknown size';
                    return Text(
                      sizeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
