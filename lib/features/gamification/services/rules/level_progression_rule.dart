import 'gamification_rule.dart';

/// Aturan penentuan batas ambang naik level (Level progression).
class LevelProgressionRule implements GamificationRule<int, int> {
  @override
  int evaluate(int level) {
    // Kebutuhan XP untuk ke level berikutnya: level * 100
    return level * 100;
  }
}
