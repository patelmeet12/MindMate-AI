import '../models/profile.dart';
import '../models/study_life_stats.dart';
import '../models/mood_check_in.dart';

class ChatCompanionEngine {
  static const String safetyDisclaimer = 
      "\n\n*Safety Note: If you're experiencing severe distress, please consider reaching out to a qualified mental health professional or a support helpline immediately. Your well-being is the number one priority.*";

  /// Evaluates user message and returns a conversational response
  static String generateResponse({
    required String userMessage,
    required Profile profile,
    required List<StudyLifeStats> statsHistory,
    required List<MoodCheckIn> moodHistory,
  }) {
    final text = userMessage.toLowerCase().trim();

    // 1. Critical Safety Check First
    if (_containsSafetyTrigger(text)) {
      return "I hear how incredibly heavy and hopeless things feel right now, and I want you to know you are not alone. However, as your wellness companion, I cannot provide medical counseling. Your life and well-being are far more valuable than any exam score.\n\n"
          "Please reach out to a trusted adult, family member, or a professional counselor immediately. You can also connect with toll-free mental health support helplines (like Tele-MANAS in India at 14416 or 1800-891-4416, or your local national crisis line)."
          "$safetyDisclaimer";
    }

    // Grab latest stats if available
    final latestStats = statsHistory.isNotEmpty ? statsHistory.last : null;
    final latestMood = moodHistory.isNotEmpty ? moodHistory.last : null;

    // 2. Greeting check
    if (text == 'hi' || text == 'hello' || text == 'hey' || text.startsWith('hello ') || text.startsWith('hi ')) {
      final nameStr = profile.name.isNotEmpty ? ", ${profile.name}" : "";
      return "Hello$nameStr! I'm here as your MindMate. How has your preparation for ${profile.examTarget} been feeling today? Tell me what's on your mind—whether it is study fatigue, mock test anxiety, or just needing a moment to vent.";
    }

    // 3. Sleep & Fatigue Trigger
    if (text.contains('tired') ||
        text.contains('exhausted') ||
        text.contains('sleepy') ||
        text.contains('fatigue') ||
        text.contains('drained') ||
        text.contains('sleep') ||
        text.contains('insomnia') ||
        text.contains('no energy')) {
      
      if (latestStats != null && latestStats.sleepHours < 6.0) {
        return "I hear you, and it makes complete sense. Looking at your tracker, you logged only ${latestStats.sleepHours} hours of sleep recently. "
            "Sleep is when your brain moves information into long-term memory. Studying on a sleep deficit is like pouring water into a leaky cup.\n\n"
            "Can you make a promise to wrap up your study desk 1 hour earlier tonight and prioritize 7-8 hours of sleep? Rest is a weapon in competitive exams.";
      }
      
      if (latestStats != null && latestStats.studyHours > 10.0) {
        return "You've logged ${latestStats.studyHours} study hours today. That's a massive shift, and your fatigue is your body's alarm telling you to slow down. "
            "Burnout doesn't build character; it breaks focus. Let's do a 5-minute visual breathing exercise right now, and plan to take a longer break. What do you think?";
      }

      return "It sounds like you are completely drained. When preparing for high-stakes exams like ${profile.examTarget}, we often treat sleep and rest as rewards we must earn. "
          "But sleep is actually a fundamental part of the prep cycle. Let's try to plan a 15-minute off-screen break right now. Go grab some water, stretch, and step away from your books.";
    }

    // 4. Mock test & anxiety triggers
    if (text.contains('mock') ||
        text.contains('test') ||
        text.contains('marks') ||
        text.contains('rank') ||
        text.contains('score') ||
        text.contains('percentile') ||
        text.contains('fail') ||
        text.contains('result')) {
      
      return "I know how crushing it feels when a mock test score doesn't match your hard work. It's easy to look at that number and feel like you'll never clear ${profile.examTarget}.\n\n"
          "But remember: mock tests are designed to expose weak spots *before* the actual exam day. They are diagnostics, not final judgment. "
          "Instead of stressing about the total score, let's look at the errors: were they conceptual gaps or silly reading mistakes? We can review and fix them step-by-step.";
    }

    // 5. Comparison with peers
    if (text.contains('compare') ||
        text.contains('friend') ||
        text.contains('others') ||
        text.contains('classmate') ||
        text.contains('smarter') ||
        text.contains('ahead') ||
        text.contains('behind')) {
      
      return "Comparing your progress to others is one of the fastest ways to build anxiety. You see their highlight reels—the chapters they've finished, the mock scores they boast about—but you don't see their struggles.\n\n"
          "The only student you are competing with is the one you were yesterday. Focus on checking off *your* daily micro-tasks. Would you like to set one small, achievable goal for the next 2 hours and block out the noise?";
    }

    // 6. Parental / Family Pressure
    if (text.contains('parent') ||
        text.contains('mom') ||
        text.contains('dad') ||
        text.contains('family') ||
        text.contains('expect') ||
        text.contains('disappoint') ||
        text.contains('pressure')) {
      
      return "Carrying the weight of parental expectations makes exam preparation twice as heavy. You want to make them proud, and the fear of letting them down can feel paralyzing.\n\n"
          "Most parents pressure their kids out of worry, not malice—they just don't know how else to help. Sometimes, sharing your daily study log proactively (e.g., 'Look, I completed these chemistry modules today') helps them see your effort, which builds trust and lowers the heat. Hang in there.";
    }

    // 7. General Overwhelm / Backlog
    if (text.contains('backlog') ||
        text.contains('syllabus') ||
        text.contains('overwhelm') ||
        text.contains('stressed') ||
        text.contains('anxious') ||
        text.contains('panic') ||
        text.contains('worry')) {
      
      String advice = "";
      if (latestMood != null && latestMood.mood == 'Stressed') {
        advice = "Since you logged your mood as Stressed, this is a signal to pause. ";
      }

      return "${advice}When a syllabus is massive, looking at the mountain as a whole causes panic. "
          "Let's break it down. What is *one* small topic or single numerical equation you can resolve in the next 30 minutes? "
          "Forget about the remaining 95% of the syllabus for just that half-hour. Win the small battles first.";
    }

    // 8. Low motivation
    if (text.contains('motivation') ||
        text.contains('give up') ||
        text.contains('quit') ||
        text.contains('lazy') ||
        text.contains('bored') ||
        text.contains('hopeless') ||
        text.contains('pointless')) {
      
      return "It's normal for motivation to dip. No student maintains high motivation for months on end. "
          "When motivation fades, systems and habits carry you forward. Don't worry about studying for 8 hours today. "
          "Can we aim for a '5-minute rule'? Open your notes and read for just 5 minutes. If you want to stop after that, you can. Usually, starting is the hardest part.";
    }

    // 9. positive feedback
    if (text.contains('thanks') ||
        text.contains('thank you') ||
        text.contains('helpful') ||
        text.contains('good') ||
        text.contains('better') ||
        text.contains('happy')) {
      
      return "I'm so glad that helped! Remember, I'm always here in your corner. Preparing for ${profile.examTarget} is a long journey, and it's okay to have tough days. "
          "Take it one day, one study block at a time. What would you like to focus on next?";
    }

    // 10. Fallback response
    return "Thank you for sharing that with me. It takes courage to put your thoughts into words. "
        "As you prepare for ${profile.examTarget}, remember that your intelligence isn't measured solely by exam papers. "
        "How can I help you support your wellness right now? We can practice box breathing, look at your progress trends, or set up a healthier routine.";
  }

  static bool _containsSafetyTrigger(String text) {
    final List<String> triggers = [
      'suicide', 'kill myself', 'end my life', 'want to die', 'harm myself',
      'self-harm', 'cut myself', 'hang myself', 'taking my life', 'overdose'
    ];
    for (final trigger in triggers) {
      if (text.contains(trigger)) {
        return true;
      }
    }
    return false;
  }
}
