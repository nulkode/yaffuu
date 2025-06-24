import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/screens/common/error_screen.dart';
import 'package:yaffuu/presentation/screens/common/ffmpeg_missing_screen.dart';
import 'package:yaffuu/presentation/screens/common/loading_screen.dart';
import 'package:yaffuu/presentation/screens/home/home_screen.dart';
import 'package:yaffuu/presentation/screens/common/output_files_screen.dart';
import 'package:yaffuu/presentation/screens/common/settings_screen.dart';
import 'package:yaffuu/presentation/screens/workflows/compression/compression_screen.dart';
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
