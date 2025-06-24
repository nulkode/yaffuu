import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:yaffuu/presentation/bloc/queue.dart';
import 'package:yaffuu/domain/init_service.dart';
import 'package:yaffuu/presentation/bloc/theme.dart';
import 'package:yaffuu/app/app.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppInitializationService.initialize();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(create: (context) => QueueBloc()),
      ],
      child: const MainApp(),
    ),
  );
}
