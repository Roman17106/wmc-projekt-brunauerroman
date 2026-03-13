import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';

import '../models/meditation.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/session_service.dart';

class MeditationSessionScreen extends StatefulWidget {
  const MeditationSessionScreen({
    super.key,
    required this.meditation,
  });

  final Meditation meditation;

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
  Timer? _timer;
  late final DateTime _startedAt;
  late int _remainingSeconds;

  bool _isFinishing = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _playStartSoundIfEnabled() async {
    if (!mounted) {
      return;
    }

    final soundEnabled = context.read<SettingsProvider>().soundEnabled;
    if (!soundEnabled) {
      return;
    }

    FlutterRingtonePlayer().playNotification();
  }

  Future<void> _playEndSoundIfEnabled() async {
    if (!mounted) {
      return;
    }

    final soundEnabled = context.read<SettingsProvider>().soundEnabled;
    if (!soundEnabled) {
      return;
    }

    FlutterRingtonePlayer().playAlarm();
  }

  Future<void> _vibrateStartIfEnabled() async {
    if (!mounted) {
      return;
    }

    final vibrationEnabled = context.read<SettingsProvider>().vibrationEnabled;
    if (!vibrationEnabled) {
      return;
    }

    await HapticFeedback.lightImpact();
  }

  Future<void> _vibrateEndIfEnabled() async {
    if (!mounted) {
      return;
    }

    final vibrationEnabled = context.read<SettingsProvider>().vibrationEnabled;
    if (!vibrationEnabled) {
      return;
    }

    await HapticFeedback.heavyImpact();
  }

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _remainingSeconds = widget.meditation.durationSeconds;
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _playStartSoundIfEnabled();
      _vibrateStartIfEnabled();
      _showSnackBar('Meditation gestartet');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        await _finishSession();
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  Future<void> _finishSession() async {
    if (_isFinishing) {
      return;
    }

    _isFinishing = true;

    if (mounted) {
      _playEndSoundIfEnabled();
      _vibrateEndIfEnabled();
      _showSnackBar('Meditation beendet');
    }

    try {
      final endedAt = DateTime.now();
      await SessionService.postCompletedSession(
        meditation: widget.meditation,
        startedAt: _startedAt,
        endedAt: endedAt,
      );

      if (mounted) {
        context.read<StatsProvider>().markStatsDirty();
        _showSnackBar('Session gespeichert');
      }

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Super!'),
            content: const Text('Meditation erfolgreich abgeschlossen.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $error'),
        ),
      );
      _isFinishing = false;
    }
  }

  void _cancelSession() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesText = minutes.toString().padLeft(2, '0');
    final secondsText = seconds.toString().padLeft(2, '0');
    return '$minutesText:$secondsText';
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.meditation.durationSeconds;
    final progress = total == 0 ? 1.0 : (total - _remainingSeconds) / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Session'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.meditation.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.meditation.durationMinutes} Minuten Fokuszeit',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress.clamp(0, 1),
                            strokeWidth: 10,
                          ),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isFinishing ? 'Session wird gespeichert...' : 'Bleib ruhig und atme tief ein.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _isFinishing ? null : _cancelSession,
                icon: const Icon(Icons.close),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Session abbrechen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
