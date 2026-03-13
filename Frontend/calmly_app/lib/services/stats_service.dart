import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/stats_summary.dart';

class StatsService {
  const StatsService._();

  static List<String> get _apiBaseUrls {
    if (kIsWeb) {
      return ['http://localhost:3000'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return ['http://localhost:3000', 'http://10.0.2.2:3000'];
    }

    return ['http://localhost:3000'];
  }

  static Future<StatsSummary> fetchStats() async {
    Exception? lastException;

    for (final baseUrl in _apiBaseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/stats');
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Fehler beim Laden der Statistik (${response.statusCode})');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return StatsSummary.fromJson(decoded);
      } on Exception catch (error) {
        lastException = error;
      }
    }

    throw lastException ?? Exception('Fehler beim Laden der Statistik.');
  }
}
