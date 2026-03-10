 import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/meditation.dart';
import 'meditation_detail_screen.dart';

class MeditationsScreen extends StatefulWidget {
  const MeditationsScreen({super.key});

  @override
  State<MeditationsScreen> createState() => _MeditationsScreenState();
}

class _MeditationsScreenState extends State<MeditationsScreen> {
  late final Future<List<Meditation>> _meditationsFuture;

  void _openMeditationDetail(Meditation meditation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeditationDetailScreen(meditation: meditation),
      ),
    );
  }

  List<String> get _apiBaseUrls {
    if (kIsWeb) {
      return ['http://localhost:3000'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Prefer adb reverse mapping, fallback to emulator host loopback.
      return ['http://localhost:3000', 'http://10.0.2.2:3000'];
    }

    return ['http://localhost:3000'];
  }

  @override
  void initState() {
    super.initState();
    _meditationsFuture = _fetchMeditations();
  }

  Future<List<Meditation>> _fetchMeditations() async {
    Exception? lastException;

    for (final baseUrl in _apiBaseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/meditations');
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Fehler beim Laden der Meditationen (${response.statusCode})');
        }

        final List<dynamic> decodedJson =
            jsonDecode(response.body) as List<dynamic>;
        return decodedJson
            .map((item) => Meditation.fromJson(item as Map<String, dynamic>))
            .toList();
      } on Exception catch (error) {
        lastException = error;
      }
    }

    throw lastException ?? Exception('Fehler beim Laden der Meditationen.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditationen'),
      ),
      body: FutureBuilder<List<Meditation>>(
        future: _meditationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
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
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final meditations = snapshot.data ?? <Meditation>[];

          if (meditations.isEmpty) {
            return const Center(
              child: Text('Keine Meditationen verfügbar.'),
            );
          }

          return ListView.builder(
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
                        Text(
                          meditation.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
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
          );
        },
      ),
    );
  }
}
