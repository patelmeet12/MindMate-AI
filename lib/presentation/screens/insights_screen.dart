import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/profile.dart';
import '../../domain/models/mood_check_in.dart';
import '../../domain/models/study_life_stats.dart';
import '../../domain/models/journal_entry.dart';
import '../providers/providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profile = ref.watch(profileProvider) ?? Profile.empty();
    final List<MoodCheckIn> moodLogs = ref.watch(moodHistoryProvider);
    final journals = ref.watch(journalHistoryProvider);
    final statsList = ref.watch(studyStatsProvider);

    // --- Heuristic Trend Analytics ---
    String confidenceInsight = "Not enough data yet. Complete at least 2 check-ins to track trends.";
    int confidenceDiff = 0;
    if (moodLogs.length >= 2) {
      final oldest = moodLogs.first.confidenceLevel;
      final newest = moodLogs.last.confidenceLevel;
      confidenceDiff = ((newest - oldest) / (oldest == 0 ? 1 : oldest) * 100).round();
      if (confidenceDiff > 0) {
        confidenceInsight = "Your confidence improved by $confidenceDiff% since your first check-in. Keep celebrating small wins!";
      } else if (confidenceDiff < 0) {
        confidenceInsight = "Your confidence decreased by ${confidenceDiff.abs()}% recently. Review your affirmations deck to boost self-belief.";
      } else {
        confidenceInsight = "Your confidence level is stable. Continue consistent practice.";
      }
    }

    String sleepStressInsight = "Increase sleep logs to map emotional recovery trends.";
    if (statsList.isNotEmpty && journals.isNotEmpty) {
      double avgStressLowSleep = 0;
      double avgStressHighSleep = 0;
      int countLowSleep = 0;
      int countHighSleep = 0;

      for (final stat in statsList) {
        final journalForDay = journals.firstWhere(
          (j) => DateFormat('yyyy-MM-dd').format(j.timestamp) == DateFormat('yyyy-MM-dd').format(stat.date),
          orElse: () => JournalEntry(
            id: '',
            content: '',
            timestamp: DateTime.now(),
            stressScore: -1,
            burnoutRisk: '',
            confidenceScore: 0,
            emotionalSummary: '',
            detectedConcerns: [],
          ),
        );

        if (journalForDay.stressScore != -1) {
          if (stat.sleepHours < 7.0) {
            avgStressLowSleep += journalForDay.stressScore;
            countLowSleep++;
          } else {
            avgStressHighSleep += journalForDay.stressScore;
            countHighSleep++;
          }
        }
      }

      if (countLowSleep > 0 && countHighSleep > 0) {
        avgStressLowSleep /= countLowSleep;
        avgStressHighSleep /= countHighSleep;
        
        final diff = (avgStressLowSleep - avgStressHighSleep).round();
        if (diff > 5) {
          sleepStressInsight = "Stress decreased by $diff% on days when you slept 7+ hours. Rest is directly stabilizing your mood.";
        } else {
          sleepStressInsight = "Sleep durations are stabilizing. Ensure you keep study hours below 10 hours for optimal retention.";
        }
      } else {
        sleepStressInsight = "Stress is lower when sleep meets your ${profile.targetSleepHours}h target. Complete more logs to verify.";
      }
    }

    String studyMotivationInsight = "Log daily study hours to find your productivity threshold.";
    if (statsList.length >= 2 && moodLogs.length >= 2) {
      double studyOnHighMot = 0;
      int countHighMot = 0;
      for (final MoodCheckIn mood in moodLogs) {
        if (mood.motivationLevel >= 6) {
          final statForDay = statsList.firstWhere(
            (s) => DateFormat('yyyy-MM-dd').format(s.date) == DateFormat('yyyy-MM-dd').format(mood.timestamp),
            orElse: () => StudyLifeStats(id: '', studyHours: -1, sleepHours: 0, breaksTaken: 0, wellnessActivities: [], date: DateTime.now()),
          );
          if (statForDay.studyHours != -1) {
            studyOnHighMot += statForDay.studyHours;
            countHighMot++;
          }
        }
      }
      if (countHighMot > 0) {
        final avgStudy = (studyOnHighMot / countHighMot).toStringAsFixed(1);
        studyMotivationInsight = "Motivation is highest on days when study sessions average around $avgStudy hours (vs your $profile target of ${profile.targetStudyHours}h).";
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Progress Insights',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Weekly wellness metrics derived mathematically from sleep, study ratio, and AI analysis logs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Heuristic Summary Card Panels
            Text(
              'Weekly Smart Summaries',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWide ? 1.6 : 2.5,
                  ),
                  children: [
                    _buildInsightTrendCard(
                      title: 'Confidence Trend',
                      desc: confidenceInsight,
                      icon: const Icon(Icons.show_chart, color: Colors.green),
                      color: Colors.green.withOpacity(0.08),
                    ),
                    _buildInsightTrendCard(
                      title: 'Sleep & Stress Correlation',
                      desc: sleepStressInsight,
                      icon: const Icon(Icons.bedtime_outlined, color: Colors.blue),
                      color: Colors.blue.withOpacity(0.08),
                    ),
                    _buildInsightTrendCard(
                      title: 'Syllabus Focus Threshold',
                      desc: studyMotivationInsight,
                      icon: const Icon(Icons.timer_outlined, color: Colors.orange),
                      color: Colors.orange.withOpacity(0.08),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Custom Charting section
            Text(
              'Recent Study vs Sleep Patterns',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: statsList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text('No daily logs recorded yet. Track study metrics on the Dashboard to see charts.'),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.square, color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text('Study Hours', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                              SizedBox(width: 16),
                              Row(
                                children: [
                                  Icon(Icons.square, color: Colors.blue, size: 12),
                                  SizedBox(width: 4),
                                  Text('Sleep Hours', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Custom Bar Chart representation using Flutter Columns
                          SizedBox(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: statsList.map((stat) {
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // Study Bar
                                          Container(
                                            width: 12,
                                            height: (stat.studyHours * 10).clamp(2.0, 150.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.8),
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          // Sleep Bar
                                          Container(
                                            width: 12,
                                            height: (stat.sleepHours * 10).clamp(2.0, 150.0),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.8),
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        DateFormat('E').format(stat.date),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Goal targets: Try to match study blocks to sleep blocks. When study hours double your sleep hours, retention drops and burnout indices rise.',
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTrendCard({
    required String title,
    required String desc,
    required Icon icon,
    required Color color,
  }) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                desc,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
