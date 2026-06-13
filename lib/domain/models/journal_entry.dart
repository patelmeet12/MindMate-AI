class JournalEntry {
  final String id;
  final String content;
  final DateTime timestamp;

  // AI Generated Fields
  final int stressScore; // 0-100
  final String burnoutRisk; // Low, Moderate, High
  final int confidenceScore; // 0-100
  final String emotionalSummary;
  final List<String> detectedConcerns; // e.g. ["Exam Anxiety", "Peer Comparison"]

  const JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.stressScore,
    required this.burnoutRisk,
    required this.confidenceScore,
    required this.emotionalSummary,
    required this.detectedConcerns,
  });

  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    int? stressScore,
    String? burnoutRisk,
    int? confidenceScore,
    String? emotionalSummary,
    List<String>? detectedConcerns,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      stressScore: stressScore ?? this.stressScore,
      burnoutRisk: burnoutRisk ?? this.burnoutRisk,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      emotionalSummary: emotionalSummary ?? this.emotionalSummary,
      detectedConcerns: detectedConcerns ?? this.detectedConcerns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'stressScore': stressScore,
      'burnoutRisk': burnoutRisk,
      'confidenceScore': confidenceScore,
      'emotionalSummary': emotionalSummary,
      'detectedConcerns': detectedConcerns,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      stressScore: (json['stressScore'] as num?)?.toInt() ?? 0,
      burnoutRisk: json['burnoutRisk'] as String? ?? 'Low',
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 50,
      emotionalSummary: json['emotionalSummary'] as String? ?? '',
      detectedConcerns: (json['detectedConcerns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
