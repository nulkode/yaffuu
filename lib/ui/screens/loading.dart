import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/logic/bloc/queue.dart';
import 'package:yaffuu/logic/services/app_initialization_service.dart';
import 'package:yaffuu/ui/components/logos.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final result = await AppInitializationService.initialize();

    if (!mounted) return;

    if (result.manager != null) {
      context.read<QueueBloc>().add(SetManagerEvent(result.manager!));
    }

    if (result.isInitialized) {
      context.go('/home');
    } else if (result.shouldShowTutorial) {
      context.go('/tutorial');
    } else if (result.errorCode == 4) {
      context.go('/error/ffmpeg-missing');
    } else if (result.errorCode != null) {
      final uri = Uri(
        path: '/error-${result.errorCode}',
        queryParameters:
            result.errorExtra != null ? {'extra': result.errorExtra} : null,
      );
      context.go(uri.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
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
    );
  }
}
