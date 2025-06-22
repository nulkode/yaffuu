import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/logic/logger.dart';
import 'package:yaffuu/app/theme/typography.dart';
import 'package:yaffuu/ui/components/appbar.dart';

// TODO: fix when ffmpeg is successfully installed by winget but it's detected as an error

class FFmpegMissingScreen extends StatelessWidget {
  const FFmpegMissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const YaffuuAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'I have already installed FFmpeg',
                  style: AppTypography.titleStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please ensure that FFmpeg is added to your system PATH. Restart the application after verifying.',
                  style: AppTypography.contentStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push('/');
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "I don't have FFmpeg installed",
                  style: AppTypography.titleStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'FFmpeg is the engine that powers yaffuu. Without it, the application is just a shell. Let me assist you in downloading and installing FFmpeg. (Don\'t worry, it should be fast and painless!)',
                  style: AppTypography.contentStyle,
                ),
                const SizedBox(height: 16),
                if (Platform.isWindows)
                  const WindowsFfmpegInstaller()
                else
                  const Text(
                    'Oops! It seems I\'m on an environment that I\'m not familiar with. Please install FFmpeg manually.',
                    style: AppTypography.contentStyle,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WindowsFfmpegInstaller extends StatefulWidget {
  const WindowsFfmpegInstaller({super.key});

  @override
  State<WindowsFfmpegInstaller> createState() => _WindowsFfmpegInstallerState();
}

class _WindowsFfmpegInstallerState extends State<WindowsFfmpegInstaller> {
  bool wingetAvailable = false;
  bool isInstalling = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _checkWingetAvailability();
  }

  Future<void> _checkWingetAvailability() async {
    if (Platform.isWindows) {
      try {
        final result = await Process.run('winget', ['--version']);
        if (result.exitCode == 0) {
          setState(() {
            wingetAvailable = true;
          });
        }
      } catch (_) {
        setState(() {
          wingetAvailable = false;
        });
      }
    }
  }

  Future<void> _startInstallation() async {
    setState(() {
      isInstalling = true;
    });

    final process = await Process.start(
      'winget',
      ['install', 'ffmpeg', '-e', '--source', 'winget'],
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      setState(() {
        logger.i(data);
      });
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      setState(() {
        hasError = true;
      });
    }

    setState(() {
      isInstalling = false;
    });

    if (exitCode == 0) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.push('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows || !wingetAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'As I have detected that you have winget, a package manager for Windows, I can help you install FFmpeg at the click of a button.',
          style: AppTypography.contentStyle,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isInstalling ? null : _startInstallation,
          child: const Text('Install FFmpeg'),
        ),
        if (!isInstalling && hasError) ...[
          // not tested
          const SizedBox(height: 16),
          const Text(
            'Oops! An error occurred during installation.',
            style: AppTypography.contentStyle,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              openLogFile();
            },
            child: const Text('Open log file'),
          ),
        ]
      ],
    );
  }
}
