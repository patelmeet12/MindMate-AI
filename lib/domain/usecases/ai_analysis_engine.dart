import 'dart:math';
import '../models/journal_entry.dart';

class AIAnalysisEngine {
  static const Map<String, List<String>> _concernKeywords = {
    'Exam Anxiety': [
      'fail', 'unprepared', 'scared', 'anxious', 'nervous', 'panic',
      'exam', 'test', 'marks', 'syllabus', 'mock', 'performance',
      'result', 'rank', 'percentile', 'scared', 'fear', 'worry',
      'forgetting', 'blank'
    ],
    'Comparison with Peers': [
      'compare', 'friend', 'others', 'batchmate', 'classmate', 'ahead',
      'behind', 'better than me', 'smarter', 'everyone else', 'they are scoring'
    ],
    'Parental Pressure': [
      'parent', 'dad', 'mom', 'expect', 'disappoint', 'father', 'mother',
      'family', 'home', 'pressure', 'relatives', 'parents', 'shame'
    ],
    'Lack of Sleep': [
      'sleep', 'tired', 'exhausted', 'insomnia', 'awake', 'restless',
      'drowsy', 'late night', 'no rest', 'sleepy', 'fatigue', 'insufficient sleep'
    ],
    'Study Overload': [
      'hours', 'syllabus', 'overwhelming', 'no break', 'non-stop',
      'study all day', 'backlog', 'chapters', 'heavy load', 'too much study',
      'stuck', 'burnout', 'fatigued', 'nonstop'
    ],
    'Social Media Distraction': [
      'phone', 'social media', 'instagram', 'youtube', 'distracted',
      'wasting time', 'scrolling', 'screen time', 'distraction', 'reddit',
      'addicted', 'reels', 'shorts'
    ]
  };

  static const List<String> _stressBoosters = [
    'very', 'extremely', 'highly', 'so much', 'can\'t take it', 'crying',
    'depressed', 'give up', 'hopeless', 'overwhelmed', 'terrible', 'worst',
    'crying', 'broken'
  ];

  static const List<String> _positiveBoosters = [
    'confident', 'prepared', 'crush', 'succeed', 'happy', 'relaxed',
    'good', 'better', 'improving', 'hopeful', 'positive', 'excited',
    'understand', 'ready'
  ];

  /// Core method to analyze text and return a [JournalEntry]
  static JournalEntry analyze(String id, String content, DateTime timestamp) {
    if (content.trim().isEmpty) {
      return JournalEntry(
        id: id,
        content: content,
        timestamp: timestamp,
        stressScore: 30,
        burnoutRisk: 'Low',
        confidenceScore: 50,
        emotionalSummary: 'This entry is empty. Please write your feelings to get analysis.',
        detectedConcerns: [],
      );
    }

    final text = content.toLowerCase();

    // 1. Detect Concerns
    final List<String> detected = [];
    _concernKeywords.forEach((concern, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          detected.add(concern);
          break; // Stop looking for keywords of this concern once matched
        }
      }
    });

    // 2. Calculate Stress Score (base 30)
    double stress = 30.0;
    // Add points for each concern detected
    stress += detected.length * 12.0;

    // Check for intensity modifiers (stress boosters)
    int boosterCount = 0;
    for (final booster in _stressBoosters) {
      if (text.contains(booster)) {
        boosterCount++;
      }
    }
    stress += min(boosterCount, 4) * 10.0;

    // Subtract points for positive sentiments
    int positiveCount = 0;
    for (final pos in _positiveBoosters) {
      if (text.contains(pos)) {
        positiveCount++;
      }
    }
    stress -= min(positiveCount, 4) * 8.0;

    final finalStressScore = stress.clamp(0.0, 100.0).round();

    // 3. Calculate Confidence Score (base 50)
    double confidence = 50.0;
    // Boosters add confidence
    confidence += positiveCount * 12.0;
    // Negative concerns and stress boosters reduce confidence
    confidence -= detected.length * 8.0;
    confidence -= boosterCount * 6.0;

    final finalConfidenceScore = confidence.clamp(0.0, 100.0).round();

    // 4. Burnout Risk
    String burnoutRisk = 'Low';
    if (finalStressScore >= 75 &&
        (detected.contains('Study Overload') || detected.contains('Lack of Sleep'))) {
      burnoutRisk = 'High';
    } else if (finalStressScore >= 60 &&
        detected.contains('Study Overload') &&
        detected.contains('Lack of Sleep')) {
      burnoutRisk = 'High';
    } else if (finalStressScore >= 50 ||
        detected.contains('Study Overload') ||
        detected.contains('Lack of Sleep') ||
        detected.length >= 2) {
      burnoutRisk = 'Moderate';
    }

    // 5. Generate Emotional Summary
    final emotionalSummary = _generateSummary(detected, finalStressScore, finalConfidenceScore, text);

    return JournalEntry(
      id: id,
      content: content,
      timestamp: timestamp,
      stressScore: finalStressScore,
      burnoutRisk: burnoutRisk,
      confidenceScore: finalConfidenceScore,
      emotionalSummary: emotionalSummary,
      detectedConcerns: detected,
    );
  }

  static String _generateSummary(
      List<String> concerns, int stressScore, int confidenceScore, String rawText) {
    if (concerns.isEmpty) {
      if (stressScore < 40 && confidenceScore > 60) {
        return 'You seem to be in a calm and productive state of mind. Your thoughts reflect confidence and minimal exam anxiety. Keep up this balanced rhythm!';
      }
      return 'Your entry shows a stable emotional level. You aren\'t voicing major exam stresses right now, which is great for long-term study endurance.';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.write('Detected highlights in your writing: ');

    // Lead sentence
    if (stressScore > 70) {
      buffer.write('You are experiencing high levels of stress. ');
    } else if (stressScore > 45) {
      buffer.write('You have moderate levels of academic pressure. ');
    } else {
      buffer.write('You are maintaining a reasonable handle on stress, though some worries are present. ');
    }

    // Detail concerns
    final List<String> details = [];
    if (concerns.contains('Exam Anxiety')) {
      details.add('anxiety about the upcoming exam syllabus or mock test performance');
    }
    if (concerns.contains('Comparison with Peers')) {
      details.add('feelings of self-doubt stemming from comparing yourself to other students');
    }
    if (concerns.contains('Parental Pressure')) {
      details.add('expectations and pressure from parents or relatives');
    }
    if (concerns.contains('Lack of Sleep')) {
      details.add('underlying physical fatigue and lack of restful sleep');
    }
    if (concerns.contains('Study Overload')) {
      details.add('signs of study overload without adequate restorative breaks');
    }
    if (concerns.contains('Social Media Distraction')) {
      details.add('feelings of distraction or guilt around screen time and scrolling');
    }

    if (details.isNotEmpty) {
      buffer.write('Specifically, we noticed ${details.join(", and ")}. ');
    }

    // Advice / Empowerment
    if (confidenceScore < 40) {
      buffer.write('Your confidence score is slightly dipped. Remind yourself that prep speed varies, and mock test scores are feedback, not your final capability. ');
    } else if (confidenceScore > 70) {
      buffer.write('It\'s encouraging that despite the stress, you maintain a strong core confidence in your ability to succeed. ');
    }

    if (concerns.contains('Study Overload') || concerns.contains('Lack of Sleep')) {
      buffer.write('Prioritizing a consistent sleep schedule and scheduling short, guilt-free breaks will immediately boost your focus tomorrow.');
    } else {
      buffer.write('Focus on setting small, bite-sized goals for today to maintain motivation.');
    }

    return buffer.toString();
  }
}
