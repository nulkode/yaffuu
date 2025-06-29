import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/shared/widgets/anti_alert_sound_gesture_on_empty_areas.dart.dart';
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
      body: Stack(
        children: [
          navigationShell,
        ],
      ),
    );
  }
}

class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AntiAlertSoundGestureOnEmptyAreas(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: child,
          ),
        ),
      ),
    );
  }
}
