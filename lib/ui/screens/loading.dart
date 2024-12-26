import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/logic/bloc/app.dart';
import 'package:yaffuu/logic/bloc/files.dart';
import 'package:yaffuu/ui/components/logos.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AppBloc()..add(StartApp()),
        child: BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppStartSuccess) {
              context.push('/home');
              context.read<FilesBloc>().add(AcceptFilesEvent());
            } else if (state is AppStartFailure) {
              if (state.errorType == AppErrorType.ffmpegMissing) {
                context.push('/error/ffmpeg-missing');
              } else {
                context.push('/error', extra: state.errorType);
              }
            }
          },
          child: const Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64),
                      child: YaffuuLogo(
                        width: 300,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'powered by',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    FFmpegLogo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
