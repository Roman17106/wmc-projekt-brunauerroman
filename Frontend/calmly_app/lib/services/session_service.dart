import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/meditation.dart';

class SessionService {
  const SessionService._();

  static List<String> get _apiBaseUrls {
    if (kIsWeb) {
      return ['http://localhost:3000'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return ['http://localhost:3000', 'http://10.0.2.2:3000'];
    }

    return ['http://localhost:3000'];
  }

  static Future<void> postCompletedSession({
    required Meditation meditation,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final payload = {
      'userId': 1,
      'meditationId': meditation.id,
      'durationSeconds': meditation.durationSeconds,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'endedAt': endedAt.toUtc().toIso8601String(),
      'completed': true,
    };

    Exception? lastException;

    for (final baseUrl in _apiBaseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/sessions');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return;
        }

        throw Exception(
          'Session konnte nicht gespeichert werden (${response.statusCode}).',
        );
      } on Exception catch (error) {
        lastException = error;
      }
    }

    throw lastException ?? Exception('Session konnte nicht gespeichert werden.');
  }
}
