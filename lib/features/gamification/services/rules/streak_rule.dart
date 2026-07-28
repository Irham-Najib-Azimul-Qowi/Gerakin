import 'gamification_rule.dart';

/// Data input untuk evaluasi streak harian.
class StreakInput {
  final DateTime lastActiveDate;
  final DateTime currentActiveDate;
  final int currentStreak;

  StreakInput({
    required this.lastActiveDate,
    required this.currentActiveDate,
    required this.currentStreak,
  });
}

/// Aturan perhitungan hari aktif berturut-turut (Streak).
class StreakRule implements GamificationRule<StreakInput, int> {
  @override
  int evaluate(StreakInput input) {
    final lastMidnight = DateTime(
      input.lastActiveDate.year,
      input.lastActiveDate.month,
      input.lastActiveDate.day,
    );
    final currentMidnight = DateTime(
      input.currentActiveDate.year,
      input.currentActiveDate.month,
      input.currentActiveDate.day,
    );
    final diffDays = currentMidnight.difference(lastMidnight).inDays;

    if (diffDays == 1) {
      return input.currentStreak + 1; // Hari berikutnya berturut-turut
    } else if (diffDays == 0) {
      return input.currentStreak; // Hari aktif yang sama, streak tetap
    } else {
      return 1; // Terputus, setel ulang kembali ke 1 hari
    }
  }
}
