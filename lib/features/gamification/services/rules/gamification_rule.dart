/// Antarmuka dasar untuk aturan bisnis gamifikasi yang independen.
abstract class GamificationRule<I, O> {
  O evaluate(I input);
}
