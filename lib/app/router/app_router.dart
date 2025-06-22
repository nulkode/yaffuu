import 'package:go_router/go_router.dart';
import 'package:yaffuu/ui/screens/error.dart';
import 'package:yaffuu/ui/screens/ffmpeg_missing.dart';
import 'package:yaffuu/ui/screens/loading.dart';
import 'package:yaffuu/ui/screens/home.dart';
import 'package:yaffuu/ui/screens/output_files.dart';
import 'package:yaffuu/ui/screens/settings.dart';
import 'package:yaffuu/ui/screens/operations/compression.dart';
import 'route_paths.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: RoutePaths.root,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomePage(),
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
      GoRoute(
        path: RoutePaths.compression,
        builder: (context, state) => const CompressionView(),
      ),
    ],
  );
}
