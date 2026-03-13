import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/meditation.dart';

class MeditationProvider extends ChangeNotifier {
  List<Meditation> _meditations = <Meditation>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Meditation> get meditations => _meditations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get _apiBaseUrls {
    if (kIsWeb) {
      return ['http://localhost:3000'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return ['http://localhost:3000', 'http://10.0.2.2:3000'];
    }

    return ['http://localhost:3000'];
  }

  Future<void> fetchMeditations() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    Exception? lastException;

    for (final baseUrl in _apiBaseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/meditations');
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Fehler beim Laden der Meditationen (${response.statusCode})');
        }

        final decodedJson = jsonDecode(response.body) as List<dynamic>;
        _meditations = decodedJson
            .map((item) => Meditation.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return;
      } on Exception catch (error) {
        lastException = error;
      }
    }

    _isLoading = false;
    _errorMessage = (lastException ?? Exception('Fehler beim Laden der Meditationen.')).toString();
    notifyListeners();
  }

  Future<void> reloadMeditations() async {
    await fetchMeditations();
  }
}
