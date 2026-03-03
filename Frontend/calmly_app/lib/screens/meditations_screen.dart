import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/meditation.dart';

class MeditationsScreen extends StatefulWidget {
  const MeditationsScreen({super.key});

  @override
  State<MeditationsScreen> createState() => _MeditationsScreenState();
}

class _MeditationsScreenState extends State<MeditationsScreen> {
  late final Future<List<Meditation>> _meditationsFuture;

  @override
  void initState() {
    super.initState();
    _meditationsFuture = _fetchMeditations();
  }

  Future<List<Meditation>> _fetchMeditations() async {
    final uri = Uri.parse('http://localhost:3000/api/meditations');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Meditationen (${response.statusCode})');
    }

    final List<dynamic> decodedJson = jsonDecode(response.body) as List<dynamic>;
    return decodedJson
        .map((item) => Meditation.fromJson(item as Map<String, dynamic>))
        .toList();
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meditation.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Kategorie: ${meditation.category}'),
                      const SizedBox(height: 4),
                      Text('Dauer: ${meditation.durationMinutes} Min.'),
                    ],
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
