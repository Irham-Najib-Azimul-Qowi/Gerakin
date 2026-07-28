import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/workout_engine/data/exercise_library.dart';
import 'package:gerakin/features/workout_engine/services/repetition_counter.dart';

void main() {
  group('RepetitionCounter Tests', () {
    late RepetitionCounter repCounter;

    setUp(() {
      repCounter = RepetitionCounter();
    });

    test('Inisialisasi awal rep dan set adalah 0', () {
      expect(repCounter.completedReps, equals(0));
      expect(repCounter.completedSets, equals(0));
    });

    test('incrementRep menambah rep secara bertahap', () {
      repCounter.incrementRep();
      expect(repCounter.completedReps, equals(1));

      repCounter.incrementRep();
      expect(repCounter.completedReps, equals(2));
    });

    test('isSetCompleted mendeteksi saat target rep tercapai', () {
      const exercise = ExerciseLibrary.armRaise; // repetitionTarget: 10
      for (int i = 0; i < 10; i++) {
        expect(repCounter.isSetCompleted(exercise), isFalse);
        repCounter.incrementRep();
      }
      expect(repCounter.isSetCompleted(exercise), isTrue);
    });

    test('incrementSet menambah set dan mengosongkan rep', () {
      repCounter.setRepsAndSets(10, 0);
      repCounter.incrementSet();

      expect(repCounter.completedSets, equals(1));
      expect(repCounter.completedReps, equals(0));
    });

    test('isWorkoutCompleted mendeteksi saat seluruh set selesai', () {
      const exercise = ExerciseLibrary.armRaise; // setTarget: 3
      repCounter.setRepsAndSets(0, 3);

      expect(repCounter.isWorkoutCompleted(exercise), isTrue);
    });
  });
}
