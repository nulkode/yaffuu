import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/bloc/app.dart';
import 'package:yaffuu/logic/user_preferences.dart';
import 'package:yaffuu/styles/text.dart';
import 'package:yaffuu/ui/components/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/ui/components/help.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    UserPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('App Theme', style: titleStyle),
                const SizedBox(height: 8),
                BlocBuilder<ThemeBloc, ThemeMode>(
                  builder: (context, themeMode) {
                    return Column(
                      children: [
                        ThemeRadio(
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          icon: Icons.settings,
                          text: 'System Theme',
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(ThemeEvent.system);
                          },
                        ),
                        const SizedBox(height: 16),
                        ThemeRadio(
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          icon: Icons.wb_sunny,
                          text: 'Light Theme',
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(ThemeEvent.light);
                          },
                        ),
                        const SizedBox(height: 16),
                        ThemeRadio(
                          value: ThemeMode.dark,
                          groupValue: themeMode,
                          icon: Icons.nights_stay,
                          text: 'Dark Theme',
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(ThemeEvent.dark);
                          },
                        ),
                      ],
                    );
                  },
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
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    if (state is AppStartSuccess) {
                      if (_prefs == null) {
                        return const CircularProgressIndicator();
                      }
                      final hardwareMethods =
                          state.ffmpegInfo.hardwareAccelerations;
                      final selectedMethod =
                          _prefs!.selectedHardwareAcceleration;
                      return Column(
                        children: hardwareMethods.map((method) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: method,
                                      groupValue: selectedMethod,
                                      onChanged: (value) async {
                                        await _prefs!
                                            .setSelectedHardwareAcceleration(
                                                value!);
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(method),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Text(
                          'Loading hardware acceleration options...');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
