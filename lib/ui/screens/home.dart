import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/files.dart';
import 'package:yaffuu/styles/text.dart';
import 'package:yaffuu/ui/components/appbar.dart';
import 'package:go_router/go_router.dart';

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
                  Text('Input', style: titleStyle),
                  SizedBox(height: 8),
                  FilePickerCard()
                ],
              ),
            ),
          ),
        ),
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
    return BlocBuilder<FilesBloc, FilesState>(
      builder: (context, state) {
        final disabled =
            state is BlockedFilesState || state is LoadingFilesState;
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
      },
    );
  }
}
