import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/game_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tutorial_screen.dart';
import 'services/audio_service.dart';
import 'services/save_service.dart';
import 'services/vibration_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize services
  await SaveService().initialize();
  await AudioService().initialize();
  
  // Load saved settings
  final saveService = SaveService();
  final audioService = AudioService();
  audioService.setSoundEnabled(saveService.getSoundEnabled());
  audioService.setMusicEnabled(saveService.getMusicEnabled());
  
  // Initialize vibration service with saved settings
  VibrationService().initialize();
  
  runApp(const FoodTruckFrenzyApp());
}

class FoodTruckFrenzyApp extends StatelessWidget {
  const FoodTruckFrenzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Truck Frenzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameColors.primary,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

/// Main navigation controller for the app
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppScreen _currentScreen = AppScreen.mainMenu;
  int? _selectedLevel;
  bool _isEndlessMode = false;

  void _navigateTo(AppScreen screen, {int? level, bool endless = false}) {
    setState(() {
      _currentScreen = screen;
      _selectedLevel = level;
      _isEndlessMode = endless;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        // Use slide + fade for polished transitions
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        final slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        
        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.mainMenu:
        return MainMenuScreen(
          key: const ValueKey('main_menu'),
          onPlay: () => _navigateTo(AppScreen.levelSelect),
          onSettings: () => _navigateTo(AppScreen.settings),
          onTutorial: () => _navigateTo(AppScreen.tutorial),
        );
      
      case AppScreen.tutorial:
        return TutorialScreen(
          key: const ValueKey('tutorial'),
          onComplete: () => _navigateTo(AppScreen.mainMenu),
        );
      
      case AppScreen.levelSelect:
        return LevelSelectScreen(
          key: const ValueKey('level_select'),
          onLevelSelected: (level) => _navigateTo(
            AppScreen.game,
            level: level,
          ),
          onEndlessModeSelected: () => _navigateTo(
            AppScreen.game,
            endless: true,
          ),
          onBack: () => _navigateTo(AppScreen.mainMenu),
        );
      
      case AppScreen.settings:
        return SettingsScreen(
          key: const ValueKey('settings'),
          onBack: () => _navigateTo(AppScreen.mainMenu),
        );
      
      case AppScreen.game:
        return GameScreen(
          key: ValueKey('game_${_selectedLevel}_$_isEndlessMode'),
          levelNumber: _selectedLevel,
          isEndlessMode: _isEndlessMode,
          onQuit: () => _navigateTo(AppScreen.levelSelect),
          onNextLevel: (nextLevel) => _navigateTo(
            AppScreen.game,
            level: nextLevel,
          ),
        );
    }
  }
}

/// Available screens in the app
enum AppScreen {
  mainMenu,
  tutorial,
  levelSelect,
  settings,
  game,
}
