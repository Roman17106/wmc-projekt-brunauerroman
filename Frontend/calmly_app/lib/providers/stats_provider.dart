import 'package:flutter/material.dart';

import '../models/stats_summary.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  StatsSummary? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  StatsSummary? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStats() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await StatsService.fetchStats();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    await fetchStats();
  }

  void markStatsDirty() {
    refreshStats();
  }
}
