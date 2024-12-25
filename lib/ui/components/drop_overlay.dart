import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/dnd.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:yaffuu/logic/logger.dart';

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
          logger.d('Drag entered');
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (detail) {
          logger.d('Drag exited');
          setState(() {
            _dragging = false;
          });
        },
        onDragDone: (detail) {
          logger.d('Drag done');
          setState(() {
            _dragging = false;
          });
        },
        child: Opacity(
          opacity: _dragging ? 1.0 : 0.0,
          child: BlocBuilder<DragAndDropBloc, DragAndDropState>(
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: state.canDrop
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
                      state.canDrop ? Icons.add : Icons.block,
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
