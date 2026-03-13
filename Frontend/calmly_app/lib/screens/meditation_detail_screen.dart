import 'package:flutter/material.dart';

import '../models/meditation.dart';
import 'meditation_session_screen.dart';

class MeditationDetailScreen extends StatelessWidget {
  const MeditationDetailScreen({
    super.key,
    required this.meditation,
  });

  final Meditation meditation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation starten'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.category, size: 18),
                          label: Text(meditation.category),
                        ),
                        Chip(
                          avatar: const Icon(Icons.schedule, size: 18),
                          label: Text('${meditation.durationMinutes} Min'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bereit fuer deine Session?',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nimm dir einen ruhigen Moment und starte dann deine Meditation.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MeditationSessionScreen(
                        meditation: meditation,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Start Meditation'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
