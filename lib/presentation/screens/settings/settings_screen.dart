import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/domain/common/constants/hwaccel.dart';
import 'package:yaffuu/infrastructure/ffmpeg/misc/ffmpeg_info_service.dart';
import 'package:yaffuu/domain/media/runtime.dart';
import 'package:yaffuu/domain/preferences/preferences_manager.dart';
import 'package:yaffuu/domain/queue/queue_service.dart';
import 'package:yaffuu/main.dart';
import 'package:yaffuu/app/theme/typography.dart';
import 'package:yaffuu/presentation/shared/widgets/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/shared/widgets/help.dart';
import 'package:yaffuu/presentation/bloc/theme_bloc.dart';
import 'package:yaffuu/presentation/shared/widgets/logos.dart';
import 'package:yaffuu/presentation/shared/widgets/error_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late PreferencesManager _preferencesManager;
  HwAccel _selectedHardwareAcceleration = HwAccel.none;

  Future<RuntimeInformation> get _ffmpegInfo {
    final ffmpegInfoService = getIt<FFmpegInformationProvider>();
    return ffmpegInfoService.getFFmpegInfo();
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _preferencesManager = getIt<PreferencesManager>();
    final hwAccel = await _preferencesManager.settings.getHwAccel();
    setState(() {
      _selectedHardwareAcceleration = hwAccel;
    });
  }

  void _updateHardwareAcceleration(HwAccel method) async {
    setState(() {
      _selectedHardwareAcceleration = method;
    });
    await _preferencesManager.settings.setHwAccel(method);

    try {
      final queueService = getIt<QueueService>();
      await queueService.initialize(method);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Success',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Hardware acceleration changed to "${method.displayName}"'),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await showDetailedErrorDialog(
          context: context,
          title: 'Hardware Acceleration Error',
          message:
              'Hardware acceleration "${method.displayName}" is not compatible with your system.',
          technicalDetails: e.toString(),
        );

        setState(() {
          _selectedHardwareAcceleration = HwAccel.none;
        });
        await _preferencesManager.settings.setHwAccel(HwAccel.none);

        try {
          final queueService = getIt<QueueService>();
          await queueService.initialize(HwAccel.none);

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, color: Colors.orange, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Fallback Applied',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text('Reverted to software acceleration'),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } catch (fallbackError) {
          if (mounted) {
            await showDetailedErrorDialog(
              context: context,
              title: 'Critical Error',
              message:
                  'Unable to initialize fallback engine. The application may not function properly.',
              technicalDetails: fallbackError.toString(),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaffuuAppBar(
        leftChildren: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, theme) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text('App Theme', style: AppTypography.titleStyle),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          ThemeRadio(
                            value: ThemeMode.system,
                            groupValue: theme,
                            icon: Icons.settings,
                            text: 'System Theme',
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(ThemeEvent.system);
                            },
                          ),
                          const SizedBox(height: 16),
                          ThemeRadio(
                            value: ThemeMode.light,
                            groupValue: theme,
                            icon: Icons.wb_sunny,
                            text: 'Light Theme',
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(ThemeEvent.light);
                            },
                          ),
                          const SizedBox(height: 16),
                          ThemeRadio(
                            value: ThemeMode.dark,
                            groupValue: theme,
                            icon: Icons.nights_stay,
                            text: 'Dark Theme',
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(ThemeEvent.dark);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        children: [
                          Text('Hardware Acceleration',
                              style: AppTypography.titleStyle),
                          SizedBox(width: 8),
                          HelpButton(
                            title: 'Hardware Acceleration',
                            content:
                                'Hardware acceleration usually makes processing faster by utilizing specialized hardware components, such as dedicated graphics cards (GPUs), to enhance video processing performance. Note that only certain codecs support hardware acceleration.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: HwAccel.values.map((acceleration) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Radio<HwAccel>(
                                      value: acceleration,
                                      groupValue: _selectedHardwareAcceleration,
                                      onChanged: (value) {
                                        if (value != null) {
                                          _updateHardwareAcceleration(value);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(acceleration.displayName),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      const Text('FFmpeg Information',
                          style: AppTypography.titleStyle),
                      const SizedBox(height: 8),
                      FutureBuilder<RuntimeInformation>(
                        future: _ffmpegInfo,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('FFmpeg information not available'),
                                const SizedBox(height: 4),
                                Text('Error: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            );
                          } else if (snapshot.hasData) {
                            final ffmpegInfo = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Version: ${ffmpegInfo.version}'),
                                const SizedBox(height: 8),
                                Text(ffmpegInfo.copyright
                                    .replaceAll('(c)', '©')),
                                const SizedBox(height: 8),
                                Text('Built With: ${ffmpegInfo.builtWith}'),
                                const SizedBox(height: 16),
                                ConfigurationSection(ffmpegInfo: ffmpegInfo),
                                const SizedBox(height: 16),
                                LibrariesSection(ffmpegInfo: ffmpegInfo),
                                const SizedBox(height: 16),
                                const Text('Hardware Acceleration Methods',
                                    style: AppTypography.subtitleStyle),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4.0,
                                  runSpacing: 4.0,
                                  children: ffmpegInfo
                                      .hardwareAccelerationMethods!
                                      .map((config) {
                                    return Chip(
                                      label: Text(
                                        config,
                                      ),
                                      padding: const EdgeInsets.all(0),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          } else {
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FFmpeg information not available'),
                                Text(
                                    '(Will be available when queue service is implemented)'),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      const Stack(
                        children: [
                          YaffuuLogo(width: 250),
                          Positioned(
                            bottom: 0,
                            left: 35,
                            child: Text('by nulkode'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            label: const Text('Donate'),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                              'Half of the donations will be donated to ffmpeg.'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('yet another ffmpeg wrapper, version 0.1.0.'),
                      const SizedBox(height: 8),
                      const Text(
                        '''
Copyright © 2025 nulkode

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
                            ''',
                        style: TextStyle(fontSize: 12.0),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          'FFmpeg is a trademark of Fabrice Bellard. yaffuu is not affiliated with FFmpeg.'),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showLicensePage(
                                context: context,
                              );
                            },
                            label: const Text('Show Licenses'),
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            iconAlignment: IconAlignment.end,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LibrariesSection extends StatelessWidget {
  const LibrariesSection({
    super.key,
    required this.ffmpegInfo,
  });

  final RuntimeInformation ffmpegInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Libraries', style: AppTypography.subtitleStyle),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Library', style: AppTypography.subsubtitleStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Compiled Version',
                      style: AppTypography.subsubtitleStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Runtime Version',
                      style: AppTypography.subsubtitleStyle),
                ),
              ],
            ),
            ...ffmpegInfo.libraries.entries.map((entry) {
              final libName = entry.key;
              final versions = entry.value;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(libName, style: AppTypography.codeStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(versions['compiled']!),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(versions['runtime']!),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}

class ConfigurationSection extends StatefulWidget {
  const ConfigurationSection({
    super.key,
    required this.ffmpegInfo,
  });

  final RuntimeInformation ffmpegInfo;

  @override
  State<ConfigurationSection> createState() => _ConfigurationSectionState();
}

class _ConfigurationSectionState extends State<ConfigurationSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration', style: AppTypography.subtitleStyle),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _toggleExpand,
          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          label: Text(_isExpanded ? 'Hide' : 'Show'),
        ),
        const SizedBox(height: 8),
        SizeTransition(
          sizeFactor: _heightFactor,
          child: Wrap(
            spacing: 2.0,
            runSpacing: 2.0,
            children: widget.ffmpegInfo.configuration.map((config) {
              return Chip(
                label: Text(
                  config,
                  style: const TextStyle(fontSize: 10.0),
                ),
                padding: const EdgeInsets.all(0),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ThemeRadio extends StatelessWidget {
  final ThemeMode value;
  final ThemeMode groupValue;
  final IconData icon;
  final String text;
  final ValueChanged<ThemeMode?> onChanged;

  const ThemeRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Radio<ThemeMode>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          const SizedBox(
            width: 8,
          ),
          Icon(icon),
          const SizedBox(
            width: 8,
          ),
          Text(text),
        ],
      ),
    );
  }
}
