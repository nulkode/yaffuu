import 'package:flutter/material.dart';
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
