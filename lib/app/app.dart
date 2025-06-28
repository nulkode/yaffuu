import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/presentation/bloc/theme_bloc.dart';
import 'package:yaffuu/presentation/shared/widgets/drop_overlay.dart';
import 'package:yaffuu/app/router/app_router.dart';
import 'package:yaffuu/app/constants/app_constants.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, theme) {
        return MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.seedColor,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.seedColor,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: theme,
          routerConfig: AppRouter.router,
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
