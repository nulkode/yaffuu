import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/files.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesBloc, FilesState>(builder: (context, state) {
      final disabled = state is BlockedFilesState || state is LoadingFilesState;
      final loading = state is LoadingFilesState;
      final showFiles = state is AcceptedFilesState;

      return Card.outlined(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: !disabled
              ? () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: ['mp4'],
                    allowCompression: false,
                    lockParentWindow: true,
                  );

                  if (result != null && context.mounted) {
                    context
                        .read<FilesBloc>()
                        .add(SubmitFilesEvent(result.xFiles.first));
                  }
                }
              : null,
          child: SizedBox(
            height: 150,
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
                      : const Text('Not implemented'))
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary),
                    ),
            ),
          ),
        ),
      );
    });
  }
}
