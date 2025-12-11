import 'package:flutter/material.dart';

import '../game/config/level_config.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../utils/constants.dart';

class LevelSelectScreen extends StatelessWidget {
  final void Function(int level) onLevelSelected;
  final VoidCallback onEndlessModeSelected;
  final VoidCallback onBack;

  const LevelSelectScreen({
    super.key,
    required this.onLevelSelected,
    required this.onEndlessModeSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final saveService = SaveService();
    final unlockedLevels = saveService.getUnlockedLevels();
    final totalStars = saveService.getTotalStars();
    final endlessModeUnlocked = LevelConfigs.isEndlessModeUnlocked(unlockedLevels);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.background,
            GameColors.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, totalStars),
            // Level grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: LevelConfigs.totalLevels,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final isUnlocked = levelNumber <= unlockedLevels;
                    final stars = saveService.getLevelStars(levelNumber);
                    return _buildLevelTile(
                      levelNumber,
                      isUnlocked,
                      stars,
                    );
                  },
                ),
              ),
            ),
            // Endless mode button
            if (endlessModeUnlocked)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEndlessModeButton(),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalStars) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AudioService().playClick();
              onBack();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: GameColors.textPrimary,
              size: 28,
            ),
          ),
          const Expanded(
            child: Text(
              'SELECT LEVEL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          // Total stars display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: GameColors.starFilled,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalStars',
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTile(int levelNumber, bool isUnlocked, int stars) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              AudioService().playClick();
              onLevelSelected(levelNumber);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? GameColors.surfaceLight : GameColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? GameColors.primary.withValues(alpha: 0.5)
                : GameColors.surfaceLight.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: GameColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                '$levelNumber',
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: index < stars
                        ? GameColors.starFilled
                        : GameColors.starEmpty,
                  );
                }),
              ),
            ] else ...[
              Icon(
                Icons.lock_rounded,
                size: 40,
                color: GameColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEndlessModeButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          AudioService().playClick();
          onEndlessModeSelected();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.accent,
          foregroundColor: GameColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: GameColors.accent.withValues(alpha: 0.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.all_inclusive_rounded, size: 28),
            SizedBox(width: 12),
            Text(
              'ENDLESS MODE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

