import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/mood_check_in.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/study_life_stats.dart';
import '../../domain/models/chat_message.dart';

class LocalStorageService {
  static const String _keyProfile = 'mindmate_profile';
  static const String _keyMoods = 'mindmate_moods';
  static const String _keyJournals = 'mindmate_journals';
  static const String _keyStats = 'mindmate_stats';
  static const String _keyChats = 'mindmate_chats';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Profile methods
  Future<void> saveProfile(Profile profile) async {
    final data = jsonEncode(profile.toJson());
    await _prefs.setString(_keyProfile, data);
  }

  Profile? getProfile() {
    final data = _prefs.getString(_keyProfile);
    if (data == null) return null;
    try {
      return Profile.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Mood Check In methods
  Future<void> saveMoodCheckIn(MoodCheckIn checkIn) async {
    final checkIns = getMoodCheckIns();
    // Check if we already have a check-in for the exact ID to avoid duplicates
    final index = checkIns.indexWhere((element) => element.id == checkIn.id);
    if (index >= 0) {
      checkIns[index] = checkIn;
    } else {
      checkIns.add(checkIn);
    }
    await _saveMoodsList(checkIns);
  }

  List<MoodCheckIn> getMoodCheckIns() {
    final list = _prefs.getStringList(_keyMoods);
    if (list == null) return [];
    return list.map((item) {
      try {
        return MoodCheckIn.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<MoodCheckIn>().toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _saveMoodsList(List<MoodCheckIn> list) async {
    final rawList = list.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_keyMoods, rawList);
  }

  // Journal Entry methods
  Future<void> saveJournalEntry(JournalEntry entry) async {
    final entries = getJournalEntries();
    final index = entries.indexWhere((element) => element.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    await _saveJournalsList(entries);
  }

  List<JournalEntry> getJournalEntries() {
    final list = _prefs.getStringList(_keyJournals);
    if (list == null) return [];
    return list.map((item) {
      try {
        return JournalEntry.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<JournalEntry>().toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _saveJournalsList(List<JournalEntry> list) async {
    final rawList = list.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_keyJournals, rawList);
  }

  // Study Life Stats methods
  Future<void> saveStudyLifeStats(StudyLifeStats stats) async {
    final allStats = getStudyLifeStats();
    final index = allStats.indexWhere((element) => element.id == stats.id);
    if (index >= 0) {
      allStats[index] = stats;
    } else {
      allStats.add(stats);
    }
    await _saveStatsList(allStats);
  }

  List<StudyLifeStats> getStudyLifeStats() {
    final list = _prefs.getStringList(_keyStats);
    if (list == null) return [];
    return list.map((item) {
      try {
        return StudyLifeStats.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<StudyLifeStats>().toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _saveStatsList(List<StudyLifeStats> list) async {
    final rawList = list.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_keyStats, rawList);
  }

  // Chat message methods
  Future<void> saveChatMessages(List<ChatMessage> messages) async {
    final rawList = messages.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_keyChats, rawList);
  }

  List<ChatMessage> getChatMessages() {
    final list = _prefs.getStringList(_keyChats);
    if (list == null) return [];
    return list.map((item) {
      try {
        return ChatMessage.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<ChatMessage>().toList();
  }

  // Clear data
  Future<void> clearAllData() async {
    await _prefs.remove(_keyProfile);
    await _prefs.remove(_keyMoods);
    await _prefs.remove(_keyJournals);
    await _prefs.remove(_keyStats);
    await _prefs.remove(_keyChats);
  }
}
