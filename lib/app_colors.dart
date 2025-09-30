import 'package:flutter/material.dart';

// Helper class with colors for the answers in the quiz
class AppColors {
  static Color correctBackground = Colors.green.shade800;
  static Color incorrectBackground = Colors.red.shade800;

  // Helper method to get the color of the tile depending on the state
  static Color? getTileColor({
    required bool isVerifying,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (isVerifying) {
      return isCorrect
          // show correct background for all correct answers
          ? correctBackground
          // only show incorrect background if the answer was selected
          : (isSelected ? incorrectBackground : null);
    }
    return null;
  }
}
