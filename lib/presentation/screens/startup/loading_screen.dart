import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/app/router/route_paths.dart';
import 'package:yaffuu/domain/common/startup_service.dart';
import 'package:yaffuu/presentation/shared/widgets/logos.dart';

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
    final result = await StartupService.getInitialState();

    if (!mounted) return;

    if (result.isInitialized) {
      context.go('/');
    } else if (result.shouldShowTutorial) {
      // context.go('/tutorial'); TODO: Implement tutorial screen
      context.go(RoutePaths.input);
    } else if (result.errorCode == 4) {
      context.go(RoutePaths.ffmpegMissing);
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
