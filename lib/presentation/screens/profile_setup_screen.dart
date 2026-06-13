import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/study_life_stats.dart';
import '../providers/providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedExam = 'JEE';
  double _studyHours = 8.0;
  double _sleepHours = 7.5;
  int _baselineStress = 5;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      final newProfile = Profile(
        name: _nameController.text.trim(),
        examTarget: _selectedExam,
        targetStudyHours: _studyHours,
        targetSleepHours: _sleepHours,
        baselineStressLevel: _baselineStress,
      );

      // Save Profile
      await ref.read(profileProvider.notifier).saveProfile(newProfile);

      // Initialize initial Study-Life Stats for the day so dashboard has data
      final initialStats = StudyLifeStats(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studyHours: 0.0,
        sleepHours: _sleepHours, // assume baseline sleep
        breaksTaken: 0,
        wellnessActivities: [],
        date: DateTime.now(),
      );
      await ref.read(studyStatsProvider.notifier).addStats(initialStats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: theme.brightness == Brightness.dark 
                  ? Border.all(color: Colors.white12, width: 1)
                  : Border.all(color: Colors.black.withOpacity(0.03), width: 1),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Welcome to MindMate AI',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your personal clinical wellness companion. Let\'s align your study goals with a healthy mental balance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  Semantics(
                    label: 'Name Input Field',
                    hint: 'Enter your preferred name',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'What should we call you?',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Exam Selection
                  Semantics(
                    label: 'Select Exam Target Dropdown',
                    child: DropdownButtonFormField<String>(
                      value: _selectedExam,
                      decoration: const InputDecoration(
                        labelText: 'Which exam are you targetting?',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: Profile.examOptions.map((String exam) {
                        return DropdownMenuItem<String>(
                          value: exam,
                          child: Text(exam),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedExam = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Target Study Hours Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Study Hours / Day',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_studyHours.toStringAsFixed(1)} hrs',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Semantics(
                        label: 'Study Hours Target Slider',
                        value: '${_studyHours.toStringAsFixed(1)} hours',
                        child: Slider(
                          value: _studyHours,
                          min: 2.0,
                          max: 16.0,
                          divisions: 28,
                          onChanged: (val) {
                            setState(() {
                              _studyHours = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Target Sleep Hours Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Sleep Hours / Night',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_sleepHours.toStringAsFixed(1)} hrs',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Semantics(
                        label: 'Sleep Hours Target Slider',
                        value: '${_sleepHours.toStringAsFixed(1)} hours',
                        child: Slider(
                          value: _sleepHours,
                          min: 4.0,
                          max: 10.0,
                          divisions: 12,
                          activeColor: colorScheme.secondary,
                          onChanged: (val) {
                            setState(() {
                              _sleepHours = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Baseline Stress Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Baseline Stress Level',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Level $_baselineStress/10',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Semantics(
                        label: 'Baseline Stress Level Slider',
                        value: 'Level $_baselineStress out of 10',
                        child: Slider(
                          value: _baselineStress.toDouble(),
                          min: 1.0,
                          max: 10.0,
                          divisions: 9,
                          activeColor: Colors.orange,
                          onChanged: (val) {
                            setState(() {
                              _baselineStress = val.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Semantics(
                    button: true,
                    label: 'Create Profile Button',
                    child: ElevatedButton(
                      onPressed: _submitProfile,
                      child: const Text('Begin Journey'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
