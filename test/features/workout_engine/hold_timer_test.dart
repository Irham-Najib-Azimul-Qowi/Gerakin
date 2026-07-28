import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/workout_engine/services/hold_timer.dart';

void main() {
  group('HoldTimer Tests', () {
    late HoldTimer timer;

    setUp(() {
      timer = HoldTimer();
    });

    test('Inisialisasi timer hold 2 detik', () {
      timer.start(2);
      expect(timer.isActive, isTrue);
      expect(timer.remainingSeconds, equals(2));
      expect(timer.isCompleted, isFalse);
    });

    test('Update delta milidetik mengurangi sisa waktu', () {
      timer.start(2); // 2000 ms

      // Update 1000ms
      final isDone1 = timer.update(1000);
      expect(isDone1, isFalse);
      expect(timer.remainingSeconds, equals(1));
      expect(timer.isCompleted, isFalse);

      // Update 1000ms lagi (total 2000ms)
      final isDone2 = timer.update(1000);
      expect(isDone2, isTrue);
      expect(timer.remainingSeconds, equals(0));
      expect(timer.isCompleted, isTrue);
    });

    test('Reset timer mengaktifkan state non-aktif', () {
      timer.start(3);
      timer.reset();

      expect(timer.isActive, isFalse);
      expect(timer.remainingSeconds, equals(0));
    });
  });
}
