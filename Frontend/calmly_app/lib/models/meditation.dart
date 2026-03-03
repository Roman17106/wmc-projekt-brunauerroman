class Meditation {
  const Meditation({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
  });

  final int id;
  final String title;
  final String category;
  final int durationSeconds;

  int get durationMinutes => (durationSeconds / 60).round();

  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
