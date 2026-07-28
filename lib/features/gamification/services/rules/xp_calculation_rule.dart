import 'gamification_rule.dart';

/// Data input untuk perhitungan perolehan XP.
class XPCalculationInput {
  final double accuracy; // Rentang 0.0 s.d 1.0
  final double consistency; // Rentang 0.0 s.d 1.0
  final double completion; // Rentang 0.0 s.d 1.0

  XPCalculationInput({
    required this.accuracy,
    required this.consistency,
    required this.completion,
  });
}

/// Aturan perhitungan XP berdasarkan performa latihan.
class XPCalculationRule implements GamificationRule<XPCalculationInput, int> {
  @override
  int evaluate(XPCalculationInput input) {
    // 50 XP untuk penyelesaian latihan (completion) penuh
    // Maksimal bonus akurasi 30 XP
    // Maksimal bonus konsistensi 20 XP
    final baseXP = (input.completion * 50).round();
    final accuracyBonus = (input.accuracy * 30).round();
    final consistencyBonus = (input.consistency * 20).round();

    return baseXP + accuracyBonus + consistencyBonus;
  }
}
