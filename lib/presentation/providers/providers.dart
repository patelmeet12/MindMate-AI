import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/profile.dart';
import '../../domain/models/mood_check_in.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/study_life_stats.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/usecases/ai_analysis_engine.dart';
import '../../domain/usecases/chat_companion_engine.dart';
import '../../data/datasources/local_storage.dart';

// --- Local Storage Providers ---
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override SharedPreferences in main.dart');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// --- Theme Management ---
class ThemeState {
  final bool isDark;
  final bool isHighContrast;

  const ThemeState({required this.isDark, required this.isHighContrast});

  ThemeState copyWith({bool? isDark, bool? isHighContrast}) {
    return ThemeState(
      isDark: isDark ?? this.isDark,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final LocalStorageService _storage;

  ThemeNotifier(this._storage)
      : super(const ThemeState(
          isDark: false,
          isHighContrast: false,
        )) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDarkStored = _storage.getThemeDark();
    final isHighContrast = _storage.getThemeHighContrast();

    if (isDarkStored != null) {
      state = ThemeState(isDark: isDarkStored, isHighContrast: isHighContrast);
    } else {
      // Default initial heuristic based on onboarding profile stress level
      final profile = _storage.getProfile();
      final defaultDark = profile != null && profile.baselineStressLevel >= 7;
      state = ThemeState(isDark: defaultDark, isHighContrast: isHighContrast);
    }
  }

  void toggleTheme() async {
    final nextDark = !state.isDark;
    state = state.copyWith(isDark: nextDark);
    await _storage.saveThemeDark(nextDark);
  }

  void toggleHighContrast() async {
    final nextHC = !state.isHighContrast;
    state = state.copyWith(isHighContrast: nextHC);
    await _storage.saveThemeHighContrast(nextHC);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ThemeNotifier(storage);
});

// --- Profile Provider ---
class ProfileNotifier extends StateNotifier<Profile?> {
  final LocalStorageService _storage;

  ProfileNotifier(this._storage) : super(null) {
    loadProfile();
  }

  void loadProfile() {
    state = _storage.getProfile();
  }

  Future<void> saveProfile(Profile profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }

  Future<void> clearData() async {
    await _storage.clearAllData();
    state = null;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile?>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ProfileNotifier(storage);
});

// --- Mood Logs Provider ---
class MoodHistoryNotifier extends StateNotifier<List<MoodCheckIn>> {
  final LocalStorageService _storage;

  MoodHistoryNotifier(this._storage) : super([]) {
    loadMoods();
  }

  void loadMoods() {
    state = _storage.getMoodCheckIns();
  }

  Future<void> addMood(MoodCheckIn checkIn) async {
    await _storage.saveMoodCheckIn(checkIn);
    loadMoods();
  }
}

final moodHistoryProvider = StateNotifierProvider<MoodHistoryNotifier, List<MoodCheckIn>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return MoodHistoryNotifier(storage);
});

// --- Journal Entries Provider ---
class JournalHistoryNotifier extends StateNotifier<List<JournalEntry>> {
  final LocalStorageService _storage;

  JournalHistoryNotifier(this._storage) : super([]) {
    loadJournals();
  }

  void loadJournals() {
    state = _storage.getJournalEntries();
  }

  Future<JournalEntry> addJournal(String content) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();

    // Call local AI analysis engine
    final entry = AIAnalysisEngine.analyze(id, content, timestamp);
    await _storage.saveJournalEntry(entry);
    loadJournals();
    return entry;
  }
}

final journalHistoryProvider = StateNotifierProvider<JournalHistoryNotifier, List<JournalEntry>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return JournalHistoryNotifier(storage);
});

// --- Study Life Stats Provider ---
class StudyStatsNotifier extends StateNotifier<List<StudyLifeStats>> {
  final LocalStorageService _storage;

  StudyStatsNotifier(this._storage) : super([]) {
    loadStats();
  }

  void loadStats() {
    state = _storage.getStudyLifeStats();
  }

  Future<void> addStats(StudyLifeStats stats) async {
    await _storage.saveStudyLifeStats(stats);
    loadStats();
  }
}

final studyStatsProvider = StateNotifierProvider<StudyStatsNotifier, List<StudyLifeStats>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return StudyStatsNotifier(storage);
});

// --- Conversational Chat Provider ---
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final LocalStorageService _storage;
  final Ref _ref;

  ChatNotifier(this._storage, this._ref) : super([]) {
    loadChats();
  }

  void loadChats() {
    final list = _storage.getChatMessages();
    if (list.isEmpty) {
      // Add default welcome message from companion
      final welcome = ChatMessage(
        id: 'welcome_ai',
        content: "Hi! I am MindMate, your local AI companion. I'm here to listen, support, and help you navigate the pressure of your competitive exams. How are you feeling today?",
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      state = [welcome];
    } else {
      state = list;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Save user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    final updated = [...state, userMsg];
    state = updated;
    await _storage.saveChatMessages(updated);

    // 2. Fetch context variables
    final profile = _ref.read(profileProvider) ?? Profile.empty();
    final stats = _ref.read(studyStatsProvider);
    final moods = _ref.read(moodHistoryProvider);

    // 3. Generate response via local companion rules engine
    final aiResponseText = ChatCompanionEngine.generateResponse(
      userMessage: text,
      profile: profile,
      statsHistory: stats,
      moodHistory: moods,
    );

    // Simulate small thinking delay for empathy/immersion
    await Future.delayed(const Duration(milliseconds: 600));

    final aiMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: aiResponseText,
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    state = [...state, aiMsg];
    await _storage.saveChatMessages(state);
  }

  Future<void> clearChat() async {
    state = [];
    await _storage.saveChatMessages([]);
    loadChats();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ChatNotifier(storage, ref);
});
