import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../food_truck_game.dart';

/// Heads-up display showing score, inventory, and progress
/// Will be fully implemented in Phase 3
class HUD extends PositionComponent with HasGameReference<FoodTruckGame> {
  int score = 0;
  int deliveries = 0;
  double comboMultiplier = 1.0;
  double progress = 0.0;
  List<IngredientType> inventory = [];
  
  @override
  Future<void> onLoad() async {
    // HUD elements will be implemented in Phase 3
    // Will include:
    // - Score display
    // - Combo multiplier
    // - Inventory display
    // - Level progress bar
  }
  
  void updateScore(int newScore) {
    score = newScore;
  }
  
  void updateDeliveries(int newDeliveries) {
    deliveries = newDeliveries;
  }
  
  void updateCombo(double newMultiplier) {
    comboMultiplier = newMultiplier;
  }
  
  void updateProgress(double newProgress) {
    progress = newProgress;
  }
  
  void updateInventory(List<IngredientType> newInventory) {
    inventory = newInventory;
  }
  
  void showMessage(String message, {Color color = GameColors.textPrimary}) {
    // Temporary message display will be implemented in Phase 6
  }
}

