import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../services/vibration_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _vibrationEnabled;

  final SaveService _saveService = SaveService();
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _soundEnabled = _saveService.getSoundEnabled();
    _musicEnabled = _saveService.getMusicEnabled();
    _vibrationEnabled = _saveService.getVibrationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameColors.background, GameColors.surface],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 32),
            // Settings options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSettingTile(
                      'Sound Effects',
                      Icons.volume_up_rounded,
                      _soundEnabled,
                      (value) {
                        setState(() => _soundEnabled = value);
                        _saveService.setSoundEnabled(value);
                        _audioService.setSoundEnabled(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      'Music',
                      Icons.music_note_rounded,
                      _musicEnabled,
                      (value) {
                        setState(() => _musicEnabled = value);
                        _saveService.setMusicEnabled(value);
                        _audioService.setMusicEnabled(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      'Vibration',
                      Icons.vibration_rounded,
                      _vibrationEnabled,
                      (value) {
                        setState(() => _vibrationEnabled = value);
                        _saveService.setVibrationEnabled(value);
                        _vibrationService.setEnabled(value);
                        // Give feedback when toggling on
                        if (value) {
                          _vibrationService.mediumImpact();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    // Privacy Policy button
                    _buildPrivacyPolicyButton(context),
                    const Spacer(),
                    // Reset progress button
                    _buildResetButton(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _audioService.playClick();
              widget.onBack();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: GameColors.textPrimary,
              size: 28,
            ),
          ),
          const Expanded(
            child: Text(
              'SETTINGS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: GameColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: GameColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: GameColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              _audioService.playClick();
              onChanged(newValue);
            },
            activeThumbColor: GameColors.primary,
            activeTrackColor: GameColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: GameColors.textSecondary,
            inactiveTrackColor: GameColors.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPrivacyPolicyDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: GameColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.privacy_tip_rounded, color: GameColors.primary, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, 
                color: GameColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    _audioService.playClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_rounded, color: GameColors.primary),
            SizedBox(width: 12),
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Food Truck Frenzy',
                style: TextStyle(
                  color: GameColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Your privacy matters to us. Here\'s what you need to know:',
                style: TextStyle(color: GameColors.textPrimary),
              ),
              SizedBox(height: 16),
              _PolicyItem(
                icon: Icons.storage_rounded,
                title: 'Data Storage',
                description: 'All game data (progress, settings, scores) is stored locally on your device. We do not collect or transmit any personal information.',
              ),
              SizedBox(height: 12),
              _PolicyItem(
                icon: Icons.wifi_off_rounded,
                title: 'Offline Play',
                description: 'This game works completely offline. No internet connection is required.',
              ),
              SizedBox(height: 12),
              _PolicyItem(
                icon: Icons.no_accounts_rounded,
                title: 'No Accounts',
                description: 'We don\'t require any registration or personal information to play.',
              ),
              SizedBox(height: 12),
              _PolicyItem(
                icon: Icons.child_care_rounded,
                title: 'Family Friendly',
                description: 'Food Truck Frenzy is suitable for all ages and contains no ads or in-app purchases.',
              ),
              SizedBox(height: 16),
              Divider(color: GameColors.surfaceLight),
              SizedBox(height: 12),
              Text(
                'Contact Us',
                style: TextStyle(
                  color: GameColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'For questions or concerns, visit our hub at:\nsupport@foodtruckfrenzy.com',
                style: TextStyle(color: GameColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioService.playClick();
              Navigator.of(context).pop();
            },
            child: const Text(
              'GOT IT',
              style: TextStyle(
                color: GameColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _showResetDialog(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: GameColors.error,
          side: const BorderSide(color: GameColors.error, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restart_alt_rounded, size: 24),
            SizedBox(width: 12),
            Text(
              'RESET PROGRESS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    _audioService.playClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Progress?',
          style: TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will delete all your saved progress, including level completions and high scores. This action cannot be undone.',
          style: TextStyle(color: GameColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioService.playClick();
              Navigator.of(context).pop();
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(color: GameColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              _audioService.playClick();
              await _saveService.resetProgress();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress has been reset'),
                    backgroundColor: GameColors.surfaceLight,
                  ),
                );
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(
                color: GameColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Privacy policy item widget
class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GameColors.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
