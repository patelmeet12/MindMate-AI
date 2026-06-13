class MoodCheckIn {
  final String id;
  final String mood; // Happy, Calm, Focused, Stressed, Anxious, Burned Out
  final int energyLevel; // 1-10
  final int motivationLevel; // 1-10
  final int confidenceLevel; // 1-10
  final int sleepQuality; // 1-10
  final int studySatisfaction; // 1-10
  final DateTime timestamp;

  const MoodCheckIn({
    required this.id,
    required this.mood,
    required this.energyLevel,
    required this.motivationLevel,
    required this.confidenceLevel,
    required this.sleepQuality,
    required this.studySatisfaction,
    required this.timestamp,
  });

  MoodCheckIn copyWith({
    String? id,
    String? mood,
    int? energyLevel,
    int? motivationLevel,
    int? confidenceLevel,
    int? sleepQuality,
    int? studySatisfaction,
    DateTime? timestamp,
  }) {
    return MoodCheckIn(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      motivationLevel: motivationLevel ?? this.motivationLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      studySatisfaction: studySatisfaction ?? this.studySatisfaction,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'energyLevel': energyLevel,
      'motivationLevel': motivationLevel,
      'confidenceLevel': confidenceLevel,
      'sleepQuality': sleepQuality,
      'studySatisfaction': studySatisfaction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    return MoodCheckIn(
      id: json['id'] as String? ?? '',
      mood: json['mood'] as String? ?? 'Calm',
      energyLevel: (json['energyLevel'] as num?)?.toInt() ?? 5,
      motivationLevel: (json['motivationLevel'] as num?)?.toInt() ?? 5,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toInt() ?? 5,
      sleepQuality: (json['sleepQuality'] as num?)?.toInt() ?? 5,
      studySatisfaction: (json['studySatisfaction'] as num?)?.toInt() ?? 5,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  static const List<String> moodOptions = [
    'Happy',
    'Calm',
    'Focused',
    'Stressed',
    'Anxious',
    'Burned Out',
  ];
}
