import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/constants.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TutorialPage> _pages = const [
    TutorialPage(
      icon: Icons.swipe,
      title: 'SWIPE TO MOVE',
      description: 'Swipe left or right to change lanes and collect ingredients.',
      color: GameColors.primary,
    ),
    TutorialPage(
      icon: Icons.fastfood_rounded,
      title: 'COLLECT INGREDIENTS',
      description: 'Pick up tomatoes, cheese, lettuce, patties, and buns as you drive.',
      color: GameColors.success,
    ),
    TutorialPage(
      icon: Icons.person_pin_circle_rounded,
      title: 'DELIVER ORDERS',
      description: 'Stop near customers to deliver orders. Match the ingredients they need!',
      color: GameColors.accent,
    ),
    TutorialPage(
      icon: Icons.warning_rounded,
      title: 'AVOID OBSTACLES',
      description: 'Watch out for cones, potholes, and barriers - they\'ll slow you down!',
      color: GameColors.error,
    ),
    TutorialPage(
      icon: Icons.stars_rounded,
      title: 'EARN STARS',
      description: 'Complete deliveries and score points to earn up to 3 stars per level!',
      color: GameColors.starFilled,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AudioService().playClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousPage() {
    AudioService().playClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  AudioService().playClick();
                  widget.onComplete();
                },
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            _buildPageIndicators(),
            const SizedBox(height: 24),
            // Navigation buttons
            _buildNavigationButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.2),
              border: Border.all(color: page.color, width: 3),
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? GameColors.primary
                : GameColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.textPrimary,
                    side: const BorderSide(color: GameColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('BACK'),
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (_currentPage > 0) const SizedBox(width: 16),
          // Next/Start button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == _pages.length - 1 ? 'START' : 'NEXT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage == _pages.length - 1
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

