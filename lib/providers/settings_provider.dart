import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'game_settings';
  static const String _statsKey = 'game_stats';

  GameSettings _settings = GameSettings();
  GameStats _stats = GameStats();
  bool _isLoaded = false;

  GameSettings get settings => _settings;
  GameStats get stats => _stats;
  bool get isLoaded => _isLoaded;

  // Settings getters
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  DifficultyConfig get currentDifficulty => _settings.currentDifficulty;

  // Stats getters
  int get gamesPlayed => _stats.gamesPlayed;
  int get gamesWon => _stats.gamesWon;
  double get winRate => _stats.winRate;
  int get currentStreak => _stats.currentStreak;
  int get bestStreak => _stats.bestStreak;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load settings
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _settings = GameSettings.fromJson(jsonDecode(settingsJson));
      }

      // Load stats
      final statsJson = prefs.getString(_statsKey);
      if (statsJson != null) {
        _stats = GameStats.fromJson(jsonDecode(statsJson));
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, jsonEncode(_stats.toJson()));
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _settings.soundEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setVibrationEnabled(bool enabled) {
    _settings.vibrationEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setDifficulty(DifficultyConfig difficulty) {
    _settings = _settings.copyWith(currentDifficulty: difficulty);
    _saveSettings();
    notifyListeners();
  }

  int? getBestTime(String difficulty) {
    return _settings.getBestTime(difficulty);
  }

  void updateBestTime(String difficulty, int time) {
    _settings.updateBestTime(difficulty, time);
    _saveSettings();
    notifyListeners();
  }

  void recordGame(bool won, int timePlayed) {
    _stats.recordGame(won, timePlayed);
    _saveStats();
    notifyListeners();
  }

  String formatBestTime(String difficulty) {
    final time = getBestTime(difficulty);
    if (time == null) return '--:--';
    final minutes = (time ~/ 60).toString().padLeft(2, '0');
    final seconds = (time % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
