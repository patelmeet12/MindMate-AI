import '../models/journal_entry.dart';

class StressTriggerInsight {
  final String trigger;
  final String message;
  final int count;
  final int totalEntriesAnalyzed;
  final bool isHighPriority;

  StressTriggerInsight({
    required this.trigger,
    required this.message,
    required this.count,
    required this.totalEntriesAnalyzed,
    required this.isHighPriority,
  });
}

class StressTriggerAnalyzer {
  /// Analyzes a list of journal entries (typically the last 7) for recurring triggers
  static List<StressTriggerInsight> analyzeTriggers(List<JournalEntry> entries) {
    if (entries.isEmpty) return [];

    // Take at most the last 7 entries for analysis
    final recentEntries = entries.length <= 7 ? entries : entries.sublist(entries.length - 7);
    final total = recentEntries.length;

    // Count occurrences of each concern
    final Map<String, int> concernCounts = {};
    for (final entry in recentEntries) {
      for (final concern in entry.detectedConcerns) {
        concernCounts[concern] = (concernCounts[concern] ?? 0) + 1;
      }
    }

    final List<StressTriggerInsight> insights = [];

    concernCounts.forEach((concern, count) {
      // If a concern is mentioned in at least 30% of entries, we generate an insight
      final double ratio = count / total;
      final bool isHighPriority = ratio >= 0.50; // Mentions in half or more entries

      if (count >= 2) {
        String advice = '';
        switch (concern) {
          case 'Exam Anxiety':
            advice = 'You\'ve expressed exam anxiety in $count of your last $total journal entries. Try to separate your self-worth from mock test scores—they are diagnostic tools, not final results. Consider practice testing in a relaxed environment.';
            break;
          case 'Comparison with Peers':
            advice = 'You mentioned peer comparison in $count of your last $total entries. Remember, everyone\'s preparation path is unique. Consider a "social media fast" or reducing chat groups where mock scores are constantly discussed.';
            break;
          case 'Parental Pressure':
            advice = 'Parental or family expectations were noted in $count of your last $total entries. It might help to share your daily study progress charts with them, reassuring them of your dedicated effort rather than just outcomes.';
            break;
          case 'Lack of Sleep':
            advice = 'Sleep fatigue was flagged in $count of your last $total entries. This is a critical trigger. Studying while sleep-deprived degrades retention by up to 40%. Prioritize a minimum of 7 hours tonight.';
            break;
          case 'Study Overload':
            advice = 'Study overload was detected in $count of your last $total entries. Continuous cramming triggers mental fatigue. Try implementing the Pomodoro technique (50 mins study, 10 mins break) to rest your mind.';
            break;
          case 'Social Media Distraction':
            advice = 'Digital distraction was mentioned in $count of your last $total entries. Try using website blockers during study blocks or physically keeping your device in another room to prevent passive scrolling.';
            break;
          default:
            advice = 'You mentioned concerns about $concern in $count of your last $total entries. Consider dedicating your next mindfulness session to reflecting on this specific area.';
        }

        insights.add(StressTriggerInsight(
          trigger: concern,
          message: advice,
          count: count,
          totalEntriesAnalyzed: total,
          isHighPriority: isHighPriority,
        ));
      }
    });

    // Sort by priority (high priority first) and then by count descending
    insights.sort((a, b) {
      if (a.isHighPriority != b.isHighPriority) {
        return a.isHighPriority ? -1 : 1;
      }
      return b.count.compareTo(a.count);
    });

    return insights;
  }
}
