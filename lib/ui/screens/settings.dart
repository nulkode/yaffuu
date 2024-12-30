import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/queue.dart';
import 'package:yaffuu/logic/ffmpeg.dart';
import 'package:yaffuu/logic/managers/cuda.dart';
import 'package:yaffuu/logic/managers/ffmpeg.dart';
import 'package:yaffuu/main.dart';
import 'package:yaffuu/styles/text.dart';
import 'package:yaffuu/ui/components/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/ui/components/help.dart';
import 'package:yaffuu/logic/bloc/theme.dart';
import 'package:yaffuu/logic/bloc/hardware_acceleration.dart';
import 'package:yaffuu/ui/screens/loading.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FFmpegInfo get _ffmpegInfo {
    return getIt<AppInfo>().ffmpegInfo;
  }

  @override
  void initState() {
    super.initState();
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
                      const Text('App Theme', style: titleStyle),
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
                          Text('Hardware Acceleration', style: titleStyle),
                          SizedBox(width: 8),
                          HelpButton(
                            title: 'Hardware Acceleration',
                            content:
                                'Hardware acceleration is like activating some special parts that are specialized in video processing. For example, if you have a dedicated graphics card, you can use it to speed up video processing. Beware that only some codecs are available for hardware acceleration.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<HardwareAccelerationBloc,
                          HardwareAccelerationState>(
                        builder: (context, selectedMethod) {
                          final hardwareAccelerations = {
                            'none': 'None',
                          }; // TODO: make this dynamic

                          return Column(
                            children:
                                hardwareAccelerations.entries.map((entry) {
                              final id = entry.key;
                              final friendlyName = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: id,
                                          groupValue: selectedMethod.method,
                                          onChanged: (value) {
                                            context
                                                .read<
                                                    HardwareAccelerationBloc>()
                                                .add(HardwareAccelerationEvent(
                                                    value!));

                                            if (value == 'none') {
                                              context.read<QueueBloc>().add(
                                                    SetManagerEvent(
                                                      FFmpegManager(
                                                          getIt<AppInfo>()
                                                              .ffmpegInfo),
                                                    ),
                                                  );
                                            } else if (value == 'cuda') {
                                              context.read<QueueBloc>().add(
                                                    SetManagerEvent(
                                                      CUDAManager(
                                                          getIt<AppInfo>()
                                                              .ffmpegInfo),
                                                    ),
                                                  );
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(friendlyName),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text('FFmpeg Information', style: titleStyle),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Version: ${_ffmpegInfo.version}'),
                            const SizedBox(height: 8),
                            Text(_ffmpegInfo.copyright.replaceAll('(c)', '©')),
                            const SizedBox(height: 8),
                            Text('Built With: ${_ffmpegInfo.builtWith}'),
                            const SizedBox(height: 16),
                            ConfigurationSection(ffmpegInfo: _ffmpegInfo),
                            const SizedBox(height: 16),
                            LibrariesSection(ffmpegInfo: _ffmpegInfo),
                            const SizedBox(height: 16),
                            const Text('Hardware Acceleration Methods',
                                style: subtitleStyle),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4.0,
                              runSpacing: 4.0,
                              children: _ffmpegInfo.hardwareAccelerationMethods!
                                  .map((config) {
                                return Chip(
                                  label: Text(
                                    config,
                                  ),
                                  padding: const EdgeInsets.all(0),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
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
    required FFmpegInfo? ffmpegInfo,
  }) : _ffmpegInfo = ffmpegInfo;

  final FFmpegInfo? _ffmpegInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Libraries', style: subtitleStyle),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Library', style: subsubtitleStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Compiled Version', style: subsubtitleStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Runtime Version', style: subsubtitleStyle),
                ),
              ],
            ),
            ..._ffmpegInfo!.libraries.entries.map((entry) {
              final libName = entry.key;
              final versions = entry.value;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(libName, style: codeStyle),
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
    required FFmpegInfo? ffmpegInfo,
  }) : _ffmpegInfo = ffmpegInfo;

  final FFmpegInfo? _ffmpegInfo;

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
        const Text('Configuration', style: subtitleStyle),
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
            children: widget._ffmpegInfo!.configuration.map((config) {
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
