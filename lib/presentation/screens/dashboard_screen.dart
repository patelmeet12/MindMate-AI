import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/profile.dart';
import '../../domain/models/mood_check_in.dart';
import '../../domain/models/study_life_stats.dart';
import '../../domain/models/journal_entry.dart';
import '../providers/providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Study-Life live input controllers
  double _inputStudyHours = 0.0;
  double _inputSleepHours = 7.0;
  int _inputBreaks = 0;
  final List<String> _inputWellness = [];

  @override
  void initState() {
    super.initState();
    // Schedule initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestStatsForInputs();
    });
  }

  void _loadLatestStatsForInputs() {
    final statsList = ref.read(studyStatsProvider);
    if (statsList.isNotEmpty) {
      final latest = statsList.last;
      setState(() {
        _inputStudyHours = latest.studyHours;
        _inputSleepHours = latest.sleepHours;
        _inputBreaks = latest.breaksTaken;
        _inputWellness.clear();
        _inputWellness.addAll(latest.wellnessActivities);
      });
    }
  }

  int _calculateWellnessScore(List<MoodCheckIn> moodLogs, List<JournalEntry> journals) {
    if (moodLogs.isEmpty) return 70; // baseline default

    final latestMood = moodLogs.last;
    double score = (latestMood.energyLevel +
            latestMood.motivationLevel +
            latestMood.confidenceLevel +
            latestMood.sleepQuality +
            latestMood.studySatisfaction) *
        2.0; // scales 10-50 to 20-100

    if (journals.isNotEmpty) {
      final latestJournal = journals.last;
      // High stress penalizes wellness score
      score -= (latestJournal.stressScore - 30) * 0.3;
    }

    return score.clamp(0.0, 100.0).round();
  }

  void _saveStudyLifeBalance() async {
    final todayStats = StudyLifeStats(
      id: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      studyHours: _inputStudyHours,
      sleepHours: _inputSleepHours,
      breaksTaken: _inputBreaks,
      wellnessActivities: _inputWellness,
      date: DateTime.now(),
    );

    await ref.read(studyStatsProvider.notifier).addStats(todayStats);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study-Life Tracker updated! Balance Score calculated.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMoodCheckInModal() {
    showDialog(
      context: context,
      builder: (context) {
        String modalMood = 'Calm';
        int modalEnergy = 5;
        int modalMotivation = 5;
        int modalConfidence = 5;
        int modalSleep = 5;
        int modalStudy = 5;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              title: const Text('Daily Wellness Check-In'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('How are you feeling right now?', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // Mood Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MoodCheckIn.moodOptions.map((moodStr) {
                        final isSelected = modalMood == moodStr;
                        return ChoiceChip(
                          label: Text(moodStr),
                          selected: isSelected,
                          selectedColor: colorScheme.primary.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                modalMood = moodStr;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Sliders
                    _buildModalSlider(
                      title: 'Energy Level',
                      value: modalEnergy,
                      onChanged: (val) => setModalState(() => modalEnergy = val),
                    ),
                    _buildModalSlider(
                      title: 'Motivation Level',
                      value: modalMotivation,
                      onChanged: (val) => setModalState(() => modalMotivation = val),
                    ),
                    _buildModalSlider(
                      title: 'Confidence Level',
                      value: modalConfidence,
                      onChanged: (val) => setModalState(() => modalConfidence = val),
                    ),
                    _buildModalSlider(
                      title: 'Sleep Quality',
                      value: modalSleep,
                      onChanged: (val) => setModalState(() => modalSleep = val),
                    ),
                    _buildModalSlider(
                      title: 'Study Satisfaction',
                      value: modalStudy,
                      onChanged: (val) => setModalState(() => modalStudy = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final log = MoodCheckIn(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      mood: modalMood,
                      energyLevel: modalEnergy,
                      motivationLevel: modalMotivation,
                      confidenceLevel: modalConfidence,
                      sleepQuality: modalSleep,
                      studySatisfaction: modalStudy,
                      timestamp: DateTime.now(),
                    );
                    await ref.read(moodHistoryProvider.notifier).addMood(log);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily Check-In saved!')),
                    );
                  },
                  child: const Text('Save Check-In'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModalSlider({required String title, required int value, required ValueChanged<int> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('$value/10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1.0,
          max: 10.0,
          divisions: 9,
          onChanged: (val) => onChanged(val.round()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profile = ref.watch(profileProvider) ?? Profile.empty();
    final moodLogs = ref.watch(moodHistoryProvider);
    final journals = ref.watch(journalHistoryProvider);

    final wellnessScore = _calculateWellnessScore(moodLogs, journals);
    final latestMood = moodLogs.isNotEmpty ? moodLogs.last : null;
    final latestJournal = journals.isNotEmpty ? journals.last : null;

    final String activeMood = latestMood?.mood ?? 'Not Checked-In';
    final int confidenceScore = latestJournal?.confidenceScore ?? (latestMood != null ? latestMood.confidenceLevel * 10 : 60);
    final String burnoutRisk = latestJournal?.burnoutRisk ?? 'Low';
    final int stressScore = latestJournal?.stressScore ?? (profile.baselineStressLevel * 10);

    // Dynamic Clinical Wellness Recommendations
    String recommendationTitle = "Daily Mindful Guidance";
    String recommendationText = "Ensure you are taking structured study blocks of 50 minutes followed by 10-minute screen-free breaks. A short walk outside helps reset ocular strain.";
    String recommendationReason = "Taking breaks helps sustain concentration and mitigates cognitive fatigue during extensive exam prep.";

    if (stressScore > 70) {
      recommendationTitle = "High Stress Intervention";
      recommendationText = "Please attempt our 2-Minute Box Breathing exercise right now. Consider shortening your study sessions for today by 1.5 hours to recover.";
      recommendationReason = "High academic anxiety triggers stress responses that block retrieval of facts. Calming your vagus nerve via breathing restores mental clarity.";
    } else if (burnoutRisk == 'High' || burnoutRisk == 'Moderate') {
      recommendationTitle = "Burnout Pre-warning Alert";
      recommendationText = "Schedule a physical recovery day. Log off screens by 9:00 PM tonight. Engage in a brief 10-minute stretching session.";
      recommendationReason = "Physical symptoms of exhaustion indicate neural fatigue. Rest consolidates your long-term memory patterns.";
    } else if (latestMood != null && latestMood.motivationLevel < 5) {
      recommendationTitle = "Motivation Support Suggestion";
      recommendationText = "Write down 3 tiny accomplishments for today. Create a small reward (like a healthy snack or chatting with a friend) after a 45-minute study block.";
      recommendationReason = "When internal drive dips, setting micro-goals and immediate feedback loops provides necessary dopamine boosts.";
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe Distress Banner at very top
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you\'re experiencing severe distress, please reach out to a qualified mental health professional or call the national hotline (14416). Your wellness matters.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Header Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take a deep breath, ${profile.name}.',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${profile.examTarget} Aspirant • Daily Wellness Hub',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showMoodCheckInModal,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Log Mood'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score Dashboard Cards (Wellness, Confidence, Burnout)
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final crossAxisCount = width > 800 ? 3 : (width > 550 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  children: [
                    // Wellness Score Ring
                    _buildMetricCard(
                      title: 'Wellness Score',
                      value: '$wellnessScore%',
                      subText: 'Based on mood & stress logs',
                      color: _getScoreColor(wellnessScore, isLowGood: false),
                      icon: const Icon(Icons.favorite_outline),
                    ),
                    // Confidence Ring
                    _buildMetricCard(
                      title: 'Confidence Level',
                      value: '$confidenceScore%',
                      subText: 'Self-belief baseline',
                      color: _getScoreColor(confidenceScore, isLowGood: false),
                      icon: const Icon(Icons.psychology_outlined),
                    ),
                    // Burnout Risk
                    _buildMetricCard(
                      title: 'Burnout Risk',
                      value: burnoutRisk,
                      subText: 'Analysis of physical habits',
                      color: burnoutRisk == 'High' 
                          ? Colors.red 
                          : (burnoutRisk == 'Moderate' ? Colors.orange : Colors.green),
                      icon: const Icon(Icons.battery_alert_outlined),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Recommendations & Study-Life Tracker side-by-side or stacked
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                if (width > 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildAIRecommendationCard(
                          title: recommendationTitle,
                          recommendation: recommendationText,
                          reason: recommendationReason,
                          stress: stressScore,
                          mood: activeMood,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: _buildStudyLifeBalanceTracker(),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildAIRecommendationCard(
                        title: recommendationTitle,
                        recommendation: recommendationText,
                        reason: recommendationReason,
                        stress: stressScore,
                        mood: activeMood,
                      ),
                      const SizedBox(height: 16),
                      _buildStudyLifeBalanceTracker(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subText,
    required Color color,
    required Icon icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                icon,
              ],
            ),
            Row(
              children: [
                // Minimal visual circle indicator
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Text(
              subText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationCard({
    required String title,
    required String recommendation,
    required String reason,
    required int stress,
    required String mood,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.secondary),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              recommendation,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clinical Reason:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last Stated Mood: $mood', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('Stress Metric: $stress/100', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStudyLifeBalanceTracker() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build temporary local stats to calculate balance score live
    final tempStats = StudyLifeStats(
      id: 'temp',
      studyHours: _inputStudyHours,
      sleepHours: _inputSleepHours,
      breaksTaken: _inputBreaks,
      wellnessActivities: _inputWellness,
      date: DateTime.now(),
    );
    final currentBalance = tempStats.balanceScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study-Life Balance Tracker',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(currentBalance, isLowGood: false).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: $currentBalance/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(currentBalance, isLowGood: false),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Study hours row input
            Row(
              children: [
                const Expanded(flex: 3, child: Text('Study Hours today:', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  flex: 5,
                  child: Slider(
                    value: _inputStudyHours,
                    min: 0.0,
                    max: 16.0,
                    divisions: 32,
                    label: '${_inputStudyHours.toStringAsFixed(1)}h',
                    onChanged: (val) {
                      setState(() {
                        _inputStudyHours = val;
                      });
                    },
                  ),
                ),
                Text('${_inputStudyHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            // Sleep hours row input
            Row(
              children: [
                const Expanded(flex: 3, child: Text('Sleep hours last night:', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  flex: 5,
                  child: Slider(
                    value: _inputSleepHours,
                    min: 3.0,
                    max: 11.0,
                    divisions: 16,
                    label: '${_inputSleepHours.toStringAsFixed(1)}h',
                    activeColor: colorScheme.secondary,
                    onChanged: (val) {
                      setState(() {
                        _inputSleepHours = val;
                      });
                    },
                  ),
                ),
                Text('${_inputSleepHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            // Breaks counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Short Recovery Breaks Taken:', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_inputBreaks > 0) {
                          setState(() {
                            _inputBreaks--;
                          });
                        }
                      },
                    ),
                    Text('$_inputBreaks', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _inputBreaks++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wellness activities chips
            const Text('Today\'s Wellness Activities:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Breathing Exercise',
                '15m Outdoor Walk',
                'Positive Affirmation',
                'Stretching',
                'Hydrated Well',
                'Social Connection',
              ].map((activity) {
                final isSelected = _inputWellness.contains(activity);
                return ChoiceChip(
                  label: Text(activity, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: colorScheme.primary.withOpacity(0.25),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _inputWellness.add(activity);
                      } else {
                        _inputWellness.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveStudyLifeBalance,
              child: const Text('Save Daily Balances'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int val, {required bool isLowGood}) {
    if (isLowGood) {
      if (val < 40) return Colors.green;
      if (val < 70) return Colors.orange;
      return Colors.red;
    } else {
      if (val > 75) return Colors.green;
      if (val > 45) return Colors.orange;
      return Colors.red;
    }
  }
}
