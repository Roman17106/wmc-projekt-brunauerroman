import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meditation.dart';

class SessionService {
  const SessionService._();

  static Future<void> postCompletedSession({
    required Meditation meditation,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final uri = Uri.parse('http://10.0.2.2:3000/api/sessions');

    final payload = {
      'userId': 1,
      'meditationId': meditation.id,
      'durationSeconds': meditation.durationSeconds,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'endedAt': endedAt.toUtc().toIso8601String(),
      'completed': true,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Session konnte nicht gespeichert werden (${response.statusCode}).',
      );
    }
  }
}
