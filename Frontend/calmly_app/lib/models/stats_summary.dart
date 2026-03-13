class StatsSummary {
  const StatsSummary({
    required this.totalMinutes,
    required this.sessions,
    required this.streakDays,
  });

  final int totalMinutes;
  final int sessions;
  final int streakDays;

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return StatsSummary(
      totalMinutes: parseInt(json['totalMinutes'] ?? json['total_minutes']),
      sessions: parseInt(json['sessions']),
      streakDays: parseInt(json['streakDays'] ?? json['streak_days']),
    );
  }
}
