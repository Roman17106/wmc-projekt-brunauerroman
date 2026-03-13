 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meditation.dart';
import '../providers/meditation_provider.dart';
import 'meditation_detail_screen.dart';

class MeditationsScreen extends StatefulWidget {
  const MeditationsScreen({super.key});

  @override
  State<MeditationsScreen> createState() => _MeditationsScreenState();
}

class _MeditationsScreenState extends State<MeditationsScreen> {
  bool _hasShownLoadErrorSnackBar = false;

  void _openMeditationDetail(Meditation meditation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeditationDetailScreen(meditation: meditation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meditationProvider = context.watch<MeditationProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditationen'),
      ),
      body: Builder(
        builder: (context) {
          if (meditationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (meditationProvider.errorMessage != null) {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Die Meditationen konnten nicht geladen werden.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meditationProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.read<MeditationProvider>().reloadMeditations(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }

          _hasShownLoadErrorSnackBar = false;

          final meditations = meditationProvider.meditations;

          if (meditations.isEmpty) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => context.read<MeditationProvider>().reloadMeditations(),
                icon: const Icon(Icons.refresh),
                label: const Text('Meditationen laden'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MeditationProvider>().reloadMeditations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meditations.length,
              itemBuilder: (context, index) {
                final meditation = meditations[index];
                final textTheme = Theme.of(context).textTheme;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openMeditationDetail(meditation),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  meditation.title,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? Theme.of(context).colorScheme.onSurface
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nimm dir bewusst Zeit für diese Session.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(meditation.category),
                              ),
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text('${meditation.durationMinutes} Min'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _openMeditationDetail(meditation),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
