import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/bloc/workbench_bloc.dart';
import 'package:yaffuu/app/theme/typography.dart';
import 'package:yaffuu/presentation/shared/widgets/error_dialog.dart';

class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkbenchBloc, WorkbenchState>(
      listener: (context, state) {
        if (state is WorkbenchAnalysisFailed) {
          showDetailedErrorDialog(
            context: context,
            title: 'File Analysis Error',
            message: state.error,
            technicalDetails: state.technicalDetails,
            onOk: () {
              Navigator.of(context).pop();
              context.read<WorkbenchBloc>().add(FileCleared());
            },
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Input', style: AppTypography.titleStyle),
          const SizedBox(height: 8),
          const FilePickerCard(),
          const SizedBox(height: 16),
          Text('Operation', style: AppTypography.titleStyle),
          const SizedBox(height: 8),
          const OperationsList(),
        ],
      ),
    );
  }
}

class FilePickerCard extends StatelessWidget {
  const FilePickerCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkbenchBloc, WorkbenchState>(
        builder: (context, state) {
      final disabled = state is WorkbenchAnalysisFailed;
      final loading = state is WorkbenchAnalysisInProgress;
      final showFiles = state is WorkbenchReady;
      final thumbnail = state is WorkbenchReady ? state.thumbnail : null;
      return Column(
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
                            .read<WorkbenchBloc>()
                            .add(FileAdded(result.xFiles.first));
                      }
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: showFiles ? 100 : 150,
                child: Center(
                  child: !loading
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: !showFiles
                              ? const Column(
                                  key: ValueKey('empty'),
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
                              : Container(
                                  key: ValueKey('file-${state.hashCode}'),
                                  child: _buildFileDisplay(
                                      context, state, thumbnail),
                                ),
                        )
                      : CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary),
                        ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showFiles
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: showFiles ? 1.0 : 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                context
                                    .read<WorkbenchBloc>()
                                    .add(FileCleared());
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: const Text('Remove File'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }

  Widget _buildFileDisplay(
      BuildContext context, WorkbenchState state, XFile? thumbnail) {
    if (state is! WorkbenchReady) {
      return const Text('No file selected');
    }

    final inputFile = state.inputFile;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
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
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.video_file,
                          size: 30, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  inputFile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: inputFile.length(),
                  builder: (context, snapshot) {
                    final size = snapshot.data;
                    final sizeText =
                        size != null ? _formatFileSize(size) : 'Unknown size';
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
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class OperationsList extends StatelessWidget {
  const OperationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkbenchBloc, WorkbenchState>(
      builder: (context, state) {
        final hasFile = state is WorkbenchReady;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOperationCard(
              context: context,
              title: 'Video Compression',
              subtitle: 'Reduce file size while maintaining quality',
              icon: Icons.compress,
              enabled: hasFile,
              onTap: hasFile ? () => context.push('/w/compression') : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOperationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card.outlined(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
