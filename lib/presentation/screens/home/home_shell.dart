import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/shared/widgets/appbar.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaffuuAppBar(
        leftChildren: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => context.push('/output-files'),
            tooltip: 'Output Files',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: navigationShell,
          ),
        ),
      ),
    );
  }
}