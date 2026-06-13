class Profile {
  final String name;
  final String examTarget;
  final double targetStudyHours;
  final double targetSleepHours;
  final int baselineStressLevel; // 1-10

  const Profile({
    required this.name,
    required this.examTarget,
    required this.targetStudyHours,
    required this.targetSleepHours,
    required this.baselineStressLevel,
  });

  Profile copyWith({
    String? name,
    String? examTarget,
    double? targetStudyHours,
    double? targetSleepHours,
    int? baselineStressLevel,
  }) {
    return Profile(
      name: name ?? this.name,
      examTarget: examTarget ?? this.examTarget,
      targetStudyHours: targetStudyHours ?? this.targetStudyHours,
      targetSleepHours: targetSleepHours ?? this.targetSleepHours,
      baselineStressLevel: baselineStressLevel ?? this.baselineStressLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'examTarget': examTarget,
      'targetStudyHours': targetStudyHours,
      'targetSleepHours': targetSleepHours,
      'baselineStressLevel': baselineStressLevel,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String? ?? '',
      examTarget: json['examTarget'] as String? ?? 'Other',
      targetStudyHours: (json['targetStudyHours'] as num?)?.toDouble() ?? 8.0,
      targetSleepHours: (json['targetSleepHours'] as num?)?.toDouble() ?? 7.0,
      baselineStressLevel: (json['baselineStressLevel'] as num?)?.toInt() ?? 5,
    );
  }

  factory Profile.empty() {
    return const Profile(
      name: '',
      examTarget: 'Other',
      targetStudyHours: 8.0,
      targetSleepHours: 7.0,
      baselineStressLevel: 5,
    );
  }

  static const List<String> examOptions = [
    'JEE',
    'NEET',
    'UPSC',
    'CAT',
    'GATE',
    'CUET',
    'Other',
  ];
}
