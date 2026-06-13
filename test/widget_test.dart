import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate_ai/domain/models/profile.dart';
import 'package:mindmate_ai/domain/models/study_life_stats.dart';
import 'package:mindmate_ai/domain/models/journal_entry.dart';
import 'package:mindmate_ai/domain/usecases/ai_analysis_engine.dart';
import 'package:mindmate_ai/domain/usecases/stress_trigger_analyzer.dart';
import 'package:mindmate_ai/domain/usecases/chat_companion_engine.dart';

void main() {
  group('AI Analysis Engine Heuristic Tests', () {
    test('Empty journal entry returns default low stress levels', () {
      final entry = AIAnalysisEngine.analyze('1', '', DateTime.now());
      expect(entry.stressScore, 30);
      expect(entry.burnoutRisk, 'Low');
      expect(entry.detectedConcerns, isEmpty);
    });

    test('Journal entry expressing exam anxiety increases stress metrics', () {
      final entry = AIAnalysisEngine.analyze(
        '2',
        'I feel very anxious about mock tests and failing NEET syllabus.',
        DateTime.now(),
      );
      expect(entry.detectedConcerns, contains('Exam Anxiety'));
      expect(entry.stressScore, greaterThan(30));
    });

    test('Journal entry expressing severe overload and lack of sleep triggers high burnout', () {
      final entry = AIAnalysisEngine.analyze(
        '3',
        'Studying non-stop for 14 hours. I am extremely tired and sleep deprived.',
        DateTime.now(),
      );
      expect(entry.detectedConcerns, contains('Lack of Sleep'));
      expect(entry.detectedConcerns, contains('Study Overload'));
      expect(entry.burnoutRisk, 'High');
    });

    test('Positive comments reduce stress score and boost confidence score', () {
      final entry = AIAnalysisEngine.analyze(
        '4',
        'I feel confident and prepared for JEE, study blocks are going good.',
        DateTime.now(),
      );
      expect(entry.stressScore, lessThan(40));
      expect(entry.confidenceScore, greaterThan(60));
    });
  });

  group('Study-Life Balance Scoring Math Tests', () {
    test('Perfect daily habits lead to 100/100 score', () {
      final stats = StudyLifeStats(
        id: '1',
        studyHours: 7.0, // perfect range
        sleepHours: 8.0, // perfect range (7-9)
        breaksTaken: 3,  // enough breaks
        wellnessActivities: ['Breathing Exercise'], // wellness bonus
        date: DateTime.now(),
      );
      expect(stats.balanceScore, 100);
    });

    test('Severe sleep deprivation penalizes balance score', () {
      final stats = StudyLifeStats(
        id: '2',
        studyHours: 8.0,
        sleepHours: 4.5, // low sleep (short 2.5 hours)
        breaksTaken: 2,
        wellnessActivities: [],
        date: DateTime.now(),
      );
      // Deducts 15 points per hour short (2.5 * 15 = 37.5), plus 10 deduction for no wellness, plus break penalty
      expect(stats.balanceScore, lessThan(60));
    });

    test('Massive study overload without breaks penalizes balance score', () {
      final stats = StudyLifeStats(
        id: '3',
        studyHours: 14.0, // overload (>10h deducts 12 points per hour = 48)
        sleepHours: 7.0,
        breaksTaken: 0,   // no breaks penalty (15)
        wellnessActivities: [],
        date: DateTime.now(),
      );
      expect(stats.balanceScore, lessThan(40));
    });
  });

  group('Stress Trigger Analyzer Heuristic Tests', () {
    test('Scans history and extracts concerns repeating in >= 30% entries', () {
      final now = DateTime.now();
      final entries = [
        JournalEntry(
          id: '1',
          content: 'sleepy',
          timestamp: now,
          stressScore: 40,
          burnoutRisk: 'Low',
          confidenceScore: 50,
          emotionalSummary: '',
          detectedConcerns: ['Lack of Sleep'],
        ),
        JournalEntry(
          id: '2',
          content: 'tired',
          timestamp: now,
          stressScore: 40,
          burnoutRisk: 'Low',
          confidenceScore: 50,
          emotionalSummary: '',
          detectedConcerns: ['Lack of Sleep'],
        ),
        JournalEntry(
          id: '3',
          content: 'unprepared for exam',
          timestamp: now,
          stressScore: 50,
          burnoutRisk: 'Low',
          confidenceScore: 50,
          emotionalSummary: '',
          detectedConcerns: ['Exam Anxiety'],
        ),
      ];

      final insights = StressTriggerAnalyzer.analyzeTriggers(entries);
      // Lack of Sleep is mentioned in 2/3 entries (>= 2 times total)
      final sleepInsight = insights.firstWhere((element) => element.trigger == 'Lack of Sleep');
      expect(sleepInsight.count, 2);
      expect(sleepInsight.isHighPriority, isTrue); // 2/3 is 66% >= 50%
    });
  });

  group('Conversational AI Companion Rules & Safety Tests', () {
    final profile = const Profile(
      name: 'Test Aspirant',
      examTarget: 'NEET',
      targetStudyHours: 8.0,
      targetSleepHours: 7.5,
      baselineStressLevel: 5,
    );

    test('Triggering words of self-harm returns strict clinical safety disclaimer', () {
      final response = ChatCompanionEngine.generateResponse(
        userMessage: 'I want to kill myself, this pressure is too high.',
        profile: profile,
        statsHistory: [],
        moodHistory: [],
      );
      expect(response, contains('Tele-MANAS'));
      expect(response, contains('Safety Note'));
    });

    test('Inquiries about fatigue check physical stats history', () {
      final stats = [
        StudyLifeStats(
          id: '1',
          studyHours: 8.0,
          sleepHours: 5.0, // sleep deficit
          breaksTaken: 1,
          wellnessActivities: [],
          date: DateTime.now(),
        )
      ];
      final response = ChatCompanionEngine.generateResponse(
        userMessage: 'I am so tired.',
        profile: profile,
        statsHistory: stats,
        moodHistory: [],
      );
      expect(response, contains('logged only 5.0 hours of sleep'));
      expect(response, contains('Rest is a weapon'));
    });
  });
}
