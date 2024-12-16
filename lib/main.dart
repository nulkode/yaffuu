import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/logic/bloc/app.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/ui/screens/error.dart';
import 'package:yaffuu/ui/screens/ffmpeg_missing.dart';
import 'package:yaffuu/ui/screens/loading_screen.dart';
import 'package:yaffuu/ui/screens/home_page.dart';
import 'package:yaffuu/ui/screens/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userPreferences = await UserPreferences.getInstance();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc()..add(StartApp()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(userPreferences.isDarkTheme ? ThemeMode.dark : ThemeMode.light),
        ),
      ],
      child: MainApp(userPreferences: userPreferences),
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
      path: '/error',
      builder: (context, state) {
        final errorType = state.extra as AppErrorType;
        return ErrorPage(errorType: errorType);
      },
    ),
    GoRoute(
      path: '/error/ffmpeg-missing',
      builder: (context, state) => const FfmpegMissingScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class MainApp extends StatelessWidget {
  final UserPreferences userPreferences;

  const MainApp({super.key, required this.userPreferences});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
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
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
