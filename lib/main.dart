import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/logic/bloc/files.dart';
import 'package:yaffuu/logic/bloc/hardware_acceleration.dart';
import 'package:yaffuu/logic/bloc/queue.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/ui/screens/error.dart';
import 'package:yaffuu/ui/screens/ffmpeg_missing.dart';
import 'package:yaffuu/ui/screens/loading.dart';
import 'package:yaffuu/ui/screens/home.dart';
import 'package:yaffuu/ui/screens/settings.dart';
import 'package:yaffuu/logic/bloc/theme.dart';
import 'package:yaffuu/ui/components/drop_overlay.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userPreferences = await UserPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(userPreferences),
        ),
        BlocProvider(
          create: (context) => HardwareAccelerationBloc(userPreferences),
        ),
        BlocProvider(create: (context) => FilesBloc()),
        BlocProvider(create: (context) => QueueBloc()),
      ],
      child: const MainApp(),
    ),
  );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/error-:errorId',
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
      path: '/error/ffmpeg-missing',
      builder: (context, state) => const FFmpegMissingScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, theme) {
        return MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: theme,
          routerConfig: router,
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                const DropOverlay(),
              ],
            );
          },
        );
      },
    );
  }
}
