import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _themeLabel(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.light:
        return 'Light';
      case AppThemeOption.dark:
        return 'Dark';
      case AppThemeOption.system:
        return 'System';
      case AppThemeOption.blueCalm:
        return 'Blue Calm';
      case AppThemeOption.greenFocus:
        return 'Green Focus';
    }
  }

  IconData _themeIcon(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.light:
        return Icons.light_mode;
      case AppThemeOption.dark:
        return Icons.dark_mode;
      case AppThemeOption.system:
        return Icons.phone_android;
      case AppThemeOption.blueCalm:
        return Icons.water_drop;
      case AppThemeOption.greenFocus:
        return Icons.park;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wähle ein Theme für deine App.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppThemeOption.values.map((option) {
                      final selected = settings.themeOption == option;
                      return ChoiceChip(
                        selected: selected,
                        onSelected: (_) => settings.setThemeOption(option),
                        avatar: Icon(_themeIcon(option), size: 18),
                        label: Text(_themeLabel(option)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aktuell: ${_themeLabel(settings.themeOption)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Sound aktiviert'),
                  subtitle: const Text('Spiele kurze Signale während der Session.'),
                  value: settings.soundEnabled,
                  onChanged: settings.setSoundEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('Vibration aktiviert'),
                  subtitle: const Text('Vibration bei Session-Start und Ende.'),
                  value: settings.vibrationEnabled,
                  onChanged: settings.setVibrationEnabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
