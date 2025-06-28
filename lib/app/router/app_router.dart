import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/screens/startup/error_screen.dart';
import 'package:yaffuu/presentation/screens/startup/ffmpeg_missing_screen.dart';
import 'package:yaffuu/presentation/screens/startup/loading_screen.dart';
import 'package:yaffuu/presentation/screens/home/home_shell.dart';
import 'package:yaffuu/presentation/pages/input/input_page.dart';
import 'package:yaffuu/presentation/pages/workflows/compression/compression_page.dart';
import 'package:yaffuu/presentation/screens/output_files/output_files_screen.dart';
import 'package:yaffuu/presentation/screens/settings/settings_screen.dart';
import 'route_paths.dart';

class SlideTransitionPage extends CustomTransitionPage {
  SlideTransitionPage({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: curve,
              )),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-1.0, 0.0),
                ).animate(CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: curve,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 350),
        );
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/input',
    routes: [
      GoRoute(
        path: RoutePaths.root,
        builder: (context, state) => const LoadingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.input,
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: const InputPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/w/compression',
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: const CompressionPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/processing',
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: const Scaffold(
                    body: Center(
                      child: Text('Processing'),
                    ),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':workflowId',
                    pageBuilder: (context, state) {
                      final workflowId = state.pathParameters['workflowId']!;
                      // TODO: Replace with actual ProcessingPage
                      return SlideTransitionPage(
                        child: Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Processing: $workflowId'),
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/output',
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: const Scaffold(
                    body: Center(
                      child: Text('Output'),
                    ),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':workflowId',
                    pageBuilder: (context, state) {
                      final workflowId = state.pathParameters['workflowId']!;
                      // TODO: Replace with actual OutputPage
                      return SlideTransitionPage(
                        child: Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Output: $workflowId'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.go('/input'),
                                  child: const Text('Start New Workflow'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.errorWithId,
        builder: (context, state) {
          final errorId = state.pathParameters['errorId']!;
          final extra = state.uri.queryParameters['extra'];
          return ErrorPage(
            errorId: int.parse(errorId),
            extra: extra,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.ffmpegMissing,
        builder: (context, state) => const FFmpegMissingScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.outputFiles,
        builder: (context, state) => const OutputFilesScreen(),
      ),
    ],
  );
}
