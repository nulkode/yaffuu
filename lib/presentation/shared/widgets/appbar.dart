import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/presentation/bloc/queue_bloc.dart';
import 'logos.dart';

class YaffuuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> leftChildren;

  const YaffuuAppBar({super.key, this.leftChildren = const []});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          ...leftChildren,
          const Spacer(),
          BlocBuilder<QueueBloc, QueueState>(
            builder: (context, state) {
              final color = state is QueueLoaded
                  ? Colors.green
                  : state is QueueError
                      ? Colors.red
                      : state is QueueInitial
                          ? Colors.cyan
                          : Colors.blue;

              final text = state is QueueLoaded
                  ? 'Ready'
                  : state is QueueError
                      ? 'Error'
                      : state is QueueInitial
                          ? 'Empty'
                          : 'Unknown';

              return InkWell(
                onTap: () {
                  // TODO: Add queue status action
                },
                child: Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: YaffuuLogo(width: 135),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
