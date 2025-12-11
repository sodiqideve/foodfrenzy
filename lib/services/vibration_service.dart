import 'package:flutter/services.dart';

import 'save_service.dart';

/// Service for managing haptic feedback (vibration)
/// Uses Flutter's built-in HapticFeedback - NO permissions required
class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  bool _enabled = true;

  /// Initialize vibration service with saved settings
  void initialize() {
    _enabled = SaveService().getVibrationEnabled();
  }

  /// Set vibration enabled state
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Check if vibration is enabled
  bool get isEnabled => _enabled;

  /// Light impact - for collecting ingredients
  void lightImpact() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for successful deliveries
  void mediumImpact() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for hitting obstacles
  void heavyImpact() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for lane switching and UI interactions
  void selectionClick() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Vibrate - generic vibration for important events
  void vibrate() {
    if (!_enabled) return;
    HapticFeedback.vibrate();
  }
}

