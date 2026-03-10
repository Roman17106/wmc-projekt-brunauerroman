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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meditation.title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(
                    label: Text(meditation.category),
                  ),
                  Chip(
                    label: Text('${meditation.durationMinutes} Min'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Bereit fuer deine Session?',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Nimm dir einen ruhigen Moment und starte dann deine Meditation.',
                style: textTheme.bodyMedium,
              ),
              const Spacer(),
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
      ),
    );
  }
}
