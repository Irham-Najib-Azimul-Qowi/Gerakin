import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';
import 'package:gerakin/features/motion/services/movement_smoother.dart';

void main() {
  group('MovementSmoother (EMA) Tests', () {
    late MovementSmoother smoother;

    setUp(() {
      smoother = MovementSmoother(defaultAlpha: 0.35);
    });

    test('Frame pertama langsung mengambil nilai mentah', () {
      final val = smoother.smoothValue('elbow', 90.0);
      expect(val, equals(90.0));
    });

    test('Noise/spike mendadak diredam oleh EMA', () {
      // Frame 1: 90.0
      smoother.smoothValue('elbow', 90.0);

      // Frame 2: Spike noise mendadak ke 150.0
      final smoothed = smoother.smoothValue('elbow', 150.0);

      // Formula: 0.35 * 150 + 0.65 * 90 = 52.5 + 58.5 = 111.0
      expect(smoothed, closeTo(111.0, 0.001));
      expect(smoothed, lessThan(150.0)); // Terbukti meredam spike
    });

    test('Smoothing pada objek JointAngle', () {
      const initialJoint = JointAngle(
        type: JointType.leftKnee,
        angle: 180.0,
        confidence: 0.9,
      );

      smoother.smoothJointAngle(initialJoint);

      const nextJoint = JointAngle(
        type: JointType.leftKnee,
        angle: 90.0,
        confidence: 0.9,
      );

      final result = smoother.smoothJointAngle(nextJoint);

      // Formula: 0.35 * 90 + 0.65 * 180 = 31.5 + 117 = 148.5
      expect(result.angle, closeTo(148.5, 0.001));
    });

    test('Reset menghapus history', () {
      smoother.smoothValue('elbow', 90.0);
      smoother.reset('elbow');

      // Setelah reset, frame berikutnya kembali menjadi nilai awal
      final val = smoother.smoothValue('elbow', 180.0);
      expect(val, equals(180.0));
    });
  });
}
