import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../domain/models/study_life_stats.dart';

class MindfulnessScreen extends ConsumerStatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  ConsumerState<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends ConsumerState<MindfulnessScreen> with TickerProviderStateMixin {
  String _activeTab = 'Breathing'; // Breathing, Gratitude, Affirmations

  // --- Box Breathing State ---
  late AnimationController _breathingController;
  late Animation<double> _breathingSizeAnimation;
  Timer? _countdownTimer;
  int _secondsLeft = 120;
  bool _isBreathingActive = false;
  String _breathingPhase = 'Breathe In'; // Breathe In, Hold (In), Breathe Out, Hold (Out)

  // --- Gratitude Inputs ---
  final _gratitude1 = TextEditingController();
  final _gratitude2 = TextEditingController();
  final _gratitude3 = TextEditingController();

  // --- Affirmations State ---
  int _affirmationIndex = 0;
  static const List<String> _affirmations = [
    "My worth is not defined by a single test score or competitive rank.",
    "I have prepared well, and my efforts will guide me through the challenge.",
    "Stress is just energy; I will channel it into focused concentration.",
    "I am doing my best, and that is more than enough.",
    "Taking breaks is a sign of wisdom, not weakness. I am resting to win.",
    "One conceptual hurdle at a time. I can break the massive backlog into tiny wins.",
    "My mind is clear, my focus is sharp, and my body is rested.",
    "JEE/NEET/UPSC is a stepping stone, not the final destination. I am growing every day."
  ];

  @override
  void initState() {
    super.initState();

    // Breathing Animation Setup (4s Inhale, 4s Hold, 4s Exhale, 4s Hold) -> Total cycle 16s
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    // Custom sequence of animations for breathing
    _breathingSizeAnimation = TweenSequence<double>([
      // 1. Inhale (0 to 4s): grow from 0.4 to 1.0
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // 2. Hold (4s to 8s): stay at 1.0
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 25.0,
      ),
      // 3. Exhale (8s to 12s): shrink from 1.0 to 0.4
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      // 4. Hold (12s to 16s): stay at 0.4
      TweenSequenceItem(
        tween: ConstantTween<double>(0.4),
        weight: 25.0,
      ),
    ]).animate(_breathingController);

    // Monitor breathing controller phases
    _breathingController.addListener(() {
      final double progress = _breathingController.value;
      String newPhase = 'Breathe In';
      if (progress >= 0.25 && progress < 0.50) {
        newPhase = 'Hold';
      } else if (progress >= 0.50 && progress < 0.75) {
        newPhase = 'Breathe Out';
      } else if (progress >= 0.75) {
        newPhase = 'Rest';
      }

      if (_breathingPhase != newPhase) {
        setState(() {
          _breathingPhase = newPhase;
        });
      }
    });

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.repeat();
      }
    });

    // Check dynamic recommended tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyAdaptiveRecommendation();
    });
  }

  void _applyAdaptiveRecommendation() {
    final journals = ref.read(journalHistoryProvider);
    final moods = ref.read(moodHistoryProvider);

    int stress = 50;
    int motivation = 5;

    if (journals.isNotEmpty) {
      stress = journals.last.stressScore;
    }
    if (moods.isNotEmpty) {
      motivation = moods.last.motivationLevel;
    }

    if (stress > 70) {
      setState(() {
        _activeTab = 'Breathing';
      });
    } else if (motivation < 5) {
      setState(() {
        _activeTab = 'Affirmations';
      });
    } else {
      setState(() {
        _activeTab = 'Gratitude';
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _countdownTimer?.cancel();
    _gratitude1.dispose();
    _gratitude2.dispose();
    _gratitude3.dispose();
    super.dispose();
  }

  // Timer helper
  void _startBreathingTimer() {
    setState(() {
      _isBreathingActive = true;
      _secondsLeft = 120;
    });
    _breathingController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _stopBreathing();
        _saveMindfulnessToStats('Breathing Exercise');
      }
    });
  }

  void _stopBreathing() {
    _countdownTimer?.cancel();
    _breathingController.stop();
    setState(() {
      _isBreathingActive = false;
      _secondsLeft = 120;
      _breathingPhase = 'Breathe In';
    });
  }

  // Links Mindfulness Activity to Study-Life Tracker
  void _saveMindfulnessToStats(String activityName) async {
    final statsList = ref.read(studyStatsProvider);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    StudyLifeStats todayStats;
    final index = statsList.indexWhere((element) => element.date.toIso8601String().startsWith(todayStr));

    if (index >= 0) {
      final existing = statsList[index];
      final List<String> updatedAct = List.from(existing.wellnessActivities);
      if (!updatedAct.contains(activityName)) {
        updatedAct.add(activityName);
      }
      todayStats = existing.copyWith(wellnessActivities: updatedAct);
    } else {
      todayStats = StudyLifeStats(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studyHours: 0.0,
        sleepHours: 7.5,
        breaksTaken: 0,
        wellnessActivities: [activityName],
        date: DateTime.now(),
      );
    }

    await ref.read(studyStatsProvider.notifier).addStats(todayStats);
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Exercise Logged!'),
          content: Text('"$activityName" has been added to your daily Study-Life balance score checklist. Keep taking care of yourself!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Great'),
            )
          ],
        ),
      );
    }
  }

  void _submitGratitude() {
    final g1 = _gratitude1.text.trim();
    final g2 = _gratitude2.text.trim();
    final g3 = _gratitude3.text.trim();

    if (g1.isEmpty && g2.isEmpty && g3.isEmpty) return;

    _gratitude1.clear();
    _gratitude2.clear();
    _gratitude3.clear();

    _saveMindfulnessToStats('Gratitude Reflection');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final journals = ref.watch(journalHistoryProvider);
    final moods = ref.watch(moodHistoryProvider);

    int stress = 50;
    if (journals.isNotEmpty) stress = journals.last.stressScore;

    String recommendationNote = "Stress is stable. Write a gratitude log to boost mindset.";
    if (stress > 70) {
      recommendationNote = "High Stress Detected ($stress/100). Focus on 2-Minute Box Breathing to calm anxiety.";
    } else if (moods.isNotEmpty && moods.last.motivationLevel < 5) {
      recommendationNote = "Low Motivation Detected. Review Positive Affirmations cards.";
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Adaptive Mindfulness Hub',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calm down your sympathetic nervous system, reset focus, and build emotional resilience.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Adaptive Suggestion Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Recommendation: $recommendationNote',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Buttons
            Row(
              children: [
                _buildTabButton('Breathing', Icons.air),
                const SizedBox(width: 8),
                _buildTabButton('Gratitude', Icons.favorite_border),
                const SizedBox(width: 8),
                _buildTabButton('Affirmations', Icons.star_border),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _buildActiveTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabName, IconData icon) {
    final isSelected = _activeTab == tabName;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Switch to $tabName exercise',
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
          foregroundColor: isSelected ? Colors.white : colorScheme.onSurface,
          side: isSelected ? BorderSide.none : BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
        ),
        onPressed: () {
          setState(() {
            _activeTab = tabName;
            _stopBreathing(); // stop breathing timer if tab is switched
          });
        },
        icon: Icon(icon),
        label: Text(tabName),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'Breathing':
        return _buildBreathingContent();
      case 'Gratitude':
        return _buildGratitudeContent();
      case 'Affirmations':
        return _buildAffirmationsContent();
      default:
        return Container();
    }
  }

  Widget _buildBreathingContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String phaseInstruction = 'Breathe In (4 seconds)';
    if (_breathingPhase == 'Hold') phaseInstruction = 'Hold Breath (4 seconds)';
    if (_breathingPhase == 'Breathe Out') phaseInstruction = 'Breathe Out (4 seconds)';
    if (_breathingPhase == 'Rest') phaseInstruction = 'Rest / Pause (4 seconds)';

    final minText = (_secondsLeft ~/ 60).toString();
    final secText = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          children: [
            const Text(
              '2-Minute Box Breathing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Calms test panic, slows heart rate, and resets cognitive capacity.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Animated Breathing Circle Canvas
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Guideline
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.1),
                        width: 4,
                      ),
                    ),
                  ),
                  // Animated Circle
                  AnimatedBuilder(
                    animation: _breathingSizeAnimation,
                    builder: (context, child) {
                      final size = 220 * _breathingSizeAnimation.value;
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _breathingPhase == 'Hold' 
                              ? colorScheme.secondary.withOpacity(0.35) 
                              : colorScheme.primary.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: (_breathingPhase == 'Hold' ? colorScheme.secondary : colorScheme.primary).withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  // Center Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _breathingPhase.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _breathingPhase == 'Hold' ? colorScheme.secondary : colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$minText:$secText',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              _isBreathingActive ? phaseInstruction : 'Sit comfortably, align your spine, and tap start.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 40),

            // Actions Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isBreathingActive)
                  ElevatedButton.icon(
                    onPressed: _startBreathingTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start 2 Min Session'),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: _stopBreathing,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Session'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Daily Gratitude Reflection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Focusing on minor accomplishments trains your mind out of comparisons and boosts exam self-efficacy.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            const Divider(height: 32),

            const Text(
              'List 3 small things you are grateful for today:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildGratitudeField(_gratitude1, '1. Something positive that happened...'),
            const SizedBox(height: 12),
            _buildGratitudeField(_gratitude2, '2. A small achievement or concept resolved...'),
            const SizedBox(height: 12),
            _buildGratitudeField(_gratitude3, '3. A supportive friend or general comfort...'),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submitGratitude,
              child: const Text('Record Gratitude'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildAffirmationsContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          children: [
            const Text(
              'Aspirant Affirmations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Repeat these quietly to interrupt loops of test anxiety and self-doubt.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Active Affirmation Card (calming block)
            Container(
              height: 160,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _affirmations[_affirmationIndex],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _affirmationIndex = (_affirmationIndex - 1 + _affirmations.length) % _affirmations.length;
                    });
                  },
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () {
                    _saveMindfulnessToStats('Positive Affirmations');
                  },
                  child: const Text('Affirmed / Log Activity'),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _affirmationIndex = (_affirmationIndex + 1) % _affirmations.length;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
