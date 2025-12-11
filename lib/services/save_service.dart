import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving and loading game progress
class SaveService {
  static final SaveService _instance = SaveService._internal();
  factory SaveService() => _instance;
  SaveService._internal();
  
  SharedPreferences? _prefs;
  
  // Keys for stored data
  static const String _keyUnlockedLevels = 'unlocked_levels';
  static const String _keyLevelStars = 'level_stars_';
  static const String _keyHighScore = 'high_score_';
  static const String _keyEndlessBestScore = 'endless_best_score';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  
  /// Initialize the save service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get the highest unlocked level (1-indexed)
  int getUnlockedLevels() {
    return _prefs?.getInt(_keyUnlockedLevels) ?? 1;
  }
  
  /// Unlock a level
  Future<void> unlockLevel(int level) async {
    final currentUnlocked = getUnlockedLevels();
    if (level > currentUnlocked) {
      await _prefs?.setInt(_keyUnlockedLevels, level);
    }
  }
  
  /// Get stars earned for a level (0-3)
  int getLevelStars(int level) {
    return _prefs?.getInt('$_keyLevelStars$level') ?? 0;
  }
  
  /// Set stars for a level (only if better than current)
  Future<void> setLevelStars(int level, int stars) async {
    final currentStars = getLevelStars(level);
    if (stars > currentStars) {
      await _prefs?.setInt('$_keyLevelStars$level', stars);
    }
  }
  
  /// Get high score for a level
  int getLevelHighScore(int level) {
    return _prefs?.getInt('$_keyHighScore$level') ?? 0;
  }
  
  /// Set high score for a level (only if better than current)
  Future<void> setLevelHighScore(int level, int score) async {
    final currentHighScore = getLevelHighScore(level);
    if (score > currentHighScore) {
      await _prefs?.setInt('$_keyHighScore$level', score);
    }
  }
  
  /// Get endless mode best score
  int getEndlessBestScore() {
    return _prefs?.getInt(_keyEndlessBestScore) ?? 0;
  }
  
  /// Set endless mode best score (only if better than current)
  Future<void> setEndlessBestScore(int score) async {
    final currentBest = getEndlessBestScore();
    if (score > currentBest) {
      await _prefs?.setInt(_keyEndlessBestScore, score);
    }
  }
  
  /// Get sound enabled setting
  bool getSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }
  
  /// Set sound enabled setting
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }
  
  /// Get music enabled setting
  bool getMusicEnabled() {
    return _prefs?.getBool(_keyMusicEnabled) ?? true;
  }
  
  /// Set music enabled setting
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs?.setBool(_keyMusicEnabled, enabled);
  }
  
  /// Get vibration enabled setting
  bool getVibrationEnabled() {
    return _prefs?.getBool(_keyVibrationEnabled) ?? true;
  }
  
  /// Set vibration enabled setting
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs?.setBool(_keyVibrationEnabled, enabled);
  }
  
  /// Get total stars earned across all levels
  int getTotalStars() {
    int total = 0;
    final unlockedLevels = getUnlockedLevels();
    for (int i = 1; i <= unlockedLevels; i++) {
      total += getLevelStars(i);
    }
    return total;
  }
  
  /// Reset all progress (with confirmation done in UI)
  Future<void> resetProgress() async {
    await _prefs?.clear();
    // Re-initialize with defaults
    await _prefs?.setInt(_keyUnlockedLevels, 1);
  }
}

