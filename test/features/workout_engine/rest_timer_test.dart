import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/workout_engine/services/rest_timer.dart';

void main() {
  group('RestTimer Tests', () {
    late RestTimer restTimer;

    setUp(() {
      restTimer = RestTimer();
    });

    test('Memulai timer istirahat 15 detik', () {
      restTimer.start(15);
      expect(restTimer.isActive, isTrue);
      expect(restTimer.remainingSeconds, equals(15));
      expect(restTimer.isCompleted, isFalse);
    });

    test('Countdown istirahat berkurang seiring berjalannya waktu', () {
      restTimer.start(15);

      restTimer.update(5000); // 5 detik berlalu
      expect(restTimer.remainingSeconds, equals(10));

      final isDone = restTimer.update(10000); // 10 detik lagi (total 15s)
      expect(isDone, isTrue);
      expect(restTimer.isCompleted, isTrue);
      expect(restTimer.remainingSeconds, equals(0));
    });
  });
}
