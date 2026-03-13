import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/meditation_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/meditations_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';

class CalmlyApp extends StatelessWidget {
  const CalmlyApp({
    super.key,
    required this.settingsProvider,
  });

  final SettingsProvider settingsProvider;

  ThemeData _buildBaseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  ThemeData _themeForOption(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.blueCalm:
        return _buildBaseTheme(
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF3A78C2),
            brightness: Brightness.light,
          ),
        );
      case AppThemeOption.greenFocus:
        return _buildBaseTheme(
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E8F63),
            brightness: Brightness.light,
          ),
        );
      case AppThemeOption.light:
      case AppThemeOption.dark:
      case AppThemeOption.system:
        return _buildBaseTheme(
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B5AE0),
            brightness: Brightness.light,
          ),
        );
    }
  }

  ThemeData _darkThemeForOption(AppThemeOption option) {
    if (option == AppThemeOption.blueCalm) {
      return _buildBaseTheme(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A78C2),
          brightness: Brightness.dark,
        ),
      );
    }

    if (option == AppThemeOption.greenFocus) {
      return _buildBaseTheme(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8F63),
          brightness: Brightness.dark,
        ),
      );
    }

    return _buildBaseTheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B5AE0),
        brightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<MeditationProvider>(
          create: (_) => MeditationProvider()..fetchMeditations(),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (_) => StatsProvider()..fetchStats(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final selectedTheme = settings.themeOption;

          return MaterialApp(
            title: 'Calmly',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: _themeForOption(selectedTheme),
            darkTheme: _darkThemeForOption(selectedTheme),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    MeditationsScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            label: 'Meditationen',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
