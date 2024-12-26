import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/files.dart';
import 'package:desktop_drop/desktop_drop.dart';

class DropOverlay extends StatefulWidget {
  const DropOverlay({super.key});

  @override
  State<DropOverlay> createState() => _DropOverlayState();
}

class _DropOverlayState extends State<DropOverlay> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DropTarget(
        onDragEntered: (detail) {
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (detail) {
          setState(() {
            _dragging = false;
          });
        },
        onDragDone: (detail) {
          setState(() {
            _dragging = false;
          });

          if (detail.files.isNotEmpty) {
            if (detail.files.length > 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only one file at a time (for now)'),
                ),
              );

              return;
            }

            context.read<FilesBloc>().add(SubmitFilesEvent(detail.files.first));
          }
        },
        child: Opacity(
          opacity: _dragging ? 1.0 : 0.0,
          child: BlocBuilder<FilesBloc, FilesState>(
            builder: (context, state) {
              final canDrop = state is AcceptingFilesState;

              return Container(
                decoration: BoxDecoration(
                  color: canDrop
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(48.0),
                child: DottedBorder(
                  color: Colors.white,
                  strokeWidth: 32.0,
                  dashPattern: const [100, 75],
                  borderType: BorderType.RRect,
                  child: Center(
                    child: Icon(
                      canDrop ? Icons.add : Icons.block,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
