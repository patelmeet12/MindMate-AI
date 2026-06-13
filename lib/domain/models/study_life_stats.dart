class StudyLifeStats {
  final String id;
  final double studyHours;
  final double sleepHours;
  final int breaksTaken;
  final List<String> wellnessActivities;
  final DateTime date;

  const StudyLifeStats({
    required this.id,
    required this.studyHours,
    required this.sleepHours,
    required this.breaksTaken,
    required this.wellnessActivities,
    required this.date,
  });

  int get balanceScore {
    // Core algorithm to calculate Study-Life Balance Score (0 - 100)
    double score = 100.0;

    // 1. Sleep Evaluation: Target is 7-9 hours
    if (sleepHours < 7.0) {
      // Deduct 15 points for every hour short
      score -= (7.0 - sleepHours) * 15.0;
    } else if (sleepHours > 9.0) {
      // Deduct 5 points per extra hour
      score -= (sleepHours - 9.0) * 5.0;
    }

    // 2. Study Overload Evaluation: Target is 5-9 hours
    if (studyHours > 10.0) {
      // Deduct 12 points for every hour above 10 hours
      score -= (studyHours - 10.0) * 12.0;
    } else if (studyHours < 4.0) {
      // Deduct 5 points for every hour below 4 hours (unless it's 0, which might be a recovery day)
      if (studyHours > 0) {
        score -= (4.0 - studyHours) * 5.0;
      }
    }

    // 3. Breaks Taken Evaluation: Target is at least 3 breaks for high study hours
    if (studyHours >= 4.0) {
      if (breaksTaken == 0) {
        score -= 15.0;
      } else if (breaksTaken < 3) {
        score -= 8.0;
      }
    }

    // 4. Wellness Activities Bonus/Deduction
    if (wellnessActivities.isEmpty) {
      score -= 10.0;
    } else {
      // Bonus of 5 points per activity, capped at 10 points
      score += wellnessActivities.length * 5.0;
    }

    // Bound the score between 0 and 100
    return score.clamp(0.0, 100.0).round();
  }

  StudyLifeStats copyWith({
    String? id,
    double? studyHours,
    double? sleepHours,
    int? breaksTaken,
    List<String>? wellnessActivities,
    DateTime? date,
  }) {
    return StudyLifeStats(
      id: id ?? this.id,
      studyHours: studyHours ?? this.studyHours,
      sleepHours: sleepHours ?? this.sleepHours,
      breaksTaken: breaksTaken ?? this.breaksTaken,
      wellnessActivities: wellnessActivities ?? this.wellnessActivities,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studyHours': studyHours,
      'sleepHours': sleepHours,
      'breaksTaken': breaksTaken,
      'wellnessActivities': wellnessActivities,
      'date': date.toIso8601String(),
    };
  }

  factory StudyLifeStats.fromJson(Map<String, dynamic> json) {
    return StudyLifeStats(
      id: json['id'] as String? ?? '',
      studyHours: (json['studyHours'] as num?)?.toDouble() ?? 0.0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0.0,
      breaksTaken: (json['breaksTaken'] as num?)?.toInt() ?? 0,
      wellnessActivities: (json['wellnessActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }
}
