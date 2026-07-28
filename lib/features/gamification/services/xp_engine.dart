import '../domain/repositories/gamification_repository.dart';
import '../models/xp_transaction.dart';
import 'rules/xp_calculation_rule.dart';

/// Engine untuk menghitung dan memberikan XP (Experience Points) kepada pengguna.
class XPEngine {
  final GamificationRepository _repository;
  final XPCalculationRule _xpRule = XPCalculationRule();

  XPEngine(this._repository);

  /// Menghitung dan menyimpan perolehan XP baru dari performa latihan.
  Future<int> awardXPForWorkout({
    required int userId,
    required double accuracy,
    required double consistency,
    required double completion,
  }) async {
    final xpAmount = _xpRule.evaluate(XPCalculationInput(
      accuracy: accuracy,
      consistency: consistency,
      completion: completion,
    ));

    final tx = XPTransaction(
      userId: userId,
      amount: xpAmount,
      source: 'workout_completion',
      createdAt: DateTime.now(),
    );
    await _repository.addXPTransaction(tx);
    return xpAmount;
  }

  /// Memberikan XP langsung (misal: penyelesaian misi/tantangan).
  Future<void> awardDirectXP({
    required int userId,
    required int amount,
    required String source,
  }) async {
    final tx = XPTransaction(
      userId: userId,
      amount: amount,
      source: source,
      createdAt: DateTime.now(),
    );
    await _repository.addXPTransaction(tx);
  }
}
