import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';
import 'package:gerakin/features/motion/services/movement_analyzer.dart';

void main() {
  group('MovementAnalyzer Tests', () {
    late MovementAnalyzer analyzer;

    setUp(() {
      analyzer = MovementAnalyzer(
        deltaThresholdDegrees: 2.0,
        windowSize: 3,
      );
    });

    test('Frame pertama atau tunggal mengembalikan MovementState.static', () {
      final state = analyzer.analyzeDirection(
        targetJoint: JointType.leftElbow,
        currentAngle: 90.0,
      );

      expect(state, equals(MovementState.static));
    });

    test('Deteksi tren bergerak naik (movingUp)', () {
      analyzer.analyzeDirection(
        targetJoint: JointType.leftElbow,
        currentAngle: 90.0,
      );

      analyzer.analyzeDirection(
        targetJoint: JointType.leftElbow,
        currentAngle: 95.0,
      );

      final state = analyzer.analyzeDirection(
        targetJoint: JointType.leftElbow,
        currentAngle: 100.0,
      );

      expect(state, equals(MovementState.movingUp));
    });

    test('Deteksi tren bergerak turun (movingDown)', () {
      analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 180.0,
      );

      analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 160.0,
      );

      final state = analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 140.0,
      );

      expect(state, equals(MovementState.movingDown));
    });

    test('Deteksi tren diam / statis (static saat delta di bawah threshold)', () {
      analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 90.0,
      );

      analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 90.5,
      );

      final state = analyzer.analyzeDirection(
        targetJoint: JointType.leftKnee,
        currentAngle: 91.0, // Delta 1.0° < threshold 2.0°
      );

      expect(state, equals(MovementState.static));
    });
  });
}
