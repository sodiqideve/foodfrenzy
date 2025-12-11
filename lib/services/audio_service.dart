import 'package:flame_audio/flame_audio.dart';

/// Service for managing game audio (sound effects and music)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;
  
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  
  /// Initialize audio service and preload audio files
  Future<void> initialize() async {
    if (_initialized) return;
    
    FlameAudio.bgm.initialize();
    
    // Preload sound effects
    await FlameAudio.audioCache.loadAll([
      'collect.wav',
      'deliver.wav',
      'hit.wav',
      'swoosh.wav',
      'combo.wav',
      'click.wav',
      'win.wav',
      'fail.wav',
    ]);
    
    _initialized = true;
  }
  
  /// Play a sound effect
  void playSfx(String filename) {
    if (_soundEnabled) {
      FlameAudio.play(filename);
    }
  }
  
  /// Play collection sound
  void playCollect() => playSfx('collect.wav');
  
  /// Play delivery sound
  void playDeliver() => playSfx('deliver.wav');
  
  /// Play obstacle hit sound
  void playHit() => playSfx('hit.wav');
  
  /// Play lane switch sound
  void playSwoosh() => playSfx('swoosh.wav');
  
  /// Play combo sound
  void playCombo() => playSfx('combo.wav');
  
  /// Play UI click sound
  void playClick() => playSfx('click.wav');
  
  /// Play level win sound
  void playWin() => playSfx('win.wav');
  
  /// Play level fail sound
  void playFail() => playSfx('fail.wav');
  
  /// Start background music
  void playBackgroundMusic() {
    if (_musicEnabled) {
      FlameAudio.bgm.play('bg-sound.mp3', volume: 0.5);
    }
  }
  
  /// Stop background music
  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }
  
  /// Pause background music
  void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }
  
  /// Resume background music
  void resumeBackgroundMusic() {
    if (_musicEnabled) {
      FlameAudio.bgm.resume();
    }
  }
  
  /// Toggle sound effects
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }
  
  /// Toggle music
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }
  
  /// Set sound enabled state
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }
  
  /// Set music enabled state
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }
  
  /// Dispose audio resources
  void dispose() {
    FlameAudio.bgm.dispose();
  }
}

