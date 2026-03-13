import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _hasShownLoadErrorSnackBar = false;

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.16),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: Builder(
        builder: (context) {
          if (statsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (statsProvider.errorMessage != null) {
            if (!_hasShownLoadErrorSnackBar) {
              _hasShownLoadErrorSnackBar = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fehler beim Laden der Daten'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 44),
                    const SizedBox(height: 10),
                    const Text(
                      'Statistik konnte nicht geladen werden.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statsProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.read<StatsProvider>().refreshStats(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }

          _hasShownLoadErrorSnackBar = false;

          final stats = statsProvider.stats;
          if (stats == null) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => context.read<StatsProvider>().refreshStats(),
                icon: const Icon(Icons.refresh),
                label: const Text('Neu laden'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<StatsProvider>().refreshStats(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Dein Fortschritt',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aktuelle Werte aus dem Backend.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context: context,
                  label: 'Gesamtminuten',
                  value: '${stats.totalMinutes}',
                  icon: Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context: context,
                  label: 'Sessions',
                  value: '${stats.sessions}',
                  icon: Icons.self_improvement,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context: context,
                  label: 'Streak-Tage',
                  value: '${stats.streakDays}',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFEA9D1A),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.read<StatsProvider>().refreshStats(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Jetzt aktualisieren'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
