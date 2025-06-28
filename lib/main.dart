import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:yaffuu/domain/common/di_service.dart';
import 'package:yaffuu/presentation/bloc/queue_bloc.dart';
import 'package:yaffuu/presentation/bloc/theme_bloc.dart';
import 'package:yaffuu/app/app.dart';
import 'package:yaffuu/presentation/bloc/workbench_bloc.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DependencyInjectionService.setup();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(create: (context) => QueueBloc()),
        BlocProvider(create: (context) => WorkbenchBloc()),
      ],
      child: const MainApp(),
    ),
  );
}
