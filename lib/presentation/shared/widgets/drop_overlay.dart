import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:yaffuu/presentation/bloc/workbench_bloc.dart';
import 'package:yaffuu/app/router/app_router.dart';

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
      child: ValueListenableBuilder<RouteInformation>(
        valueListenable: AppRouter.router.routeInformationProvider,
        builder: (context, route, child) {
          return BlocBuilder<WorkbenchBloc, WorkbenchState>(
            builder: (context, state) {
              final canDrop =
                  state is! WorkbenchAnalysisFailed && route.uri.path == '/';

              return DropTarget(
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

                  if (!canDrop) {
                    return;
                  }

                  if (detail.files.isNotEmpty) {
                    if (detail.files.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Only one file at a time (for now)'),
                        ),
                      );

                      return;
                    }

                    context
                        .read<WorkbenchBloc>()
                        .add(FileAdded(detail.files.first));
                  }
                },
                child: Opacity(
                  opacity: _dragging ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: canDrop
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.5)
                          : Colors.red.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Icon(
                        canDrop ? Icons.add : Icons.block,
                        color: Colors.white,
                        size: 100.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
