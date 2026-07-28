import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/motion/services/joint_angle_calculator.dart';

void main() {
  group('JointAngleCalculator Tests', () {
    test('Perhitungan sudut tepat 0° (vektor sejajar searah)', () {
      const vertex = math.Point<double>(0.0, 0.0);
      const pointA = math.Point<double>(0.0, 1.0);
      const pointC = math.Point<double>(0.0, 1.0);

      final angle = JointAngleCalculator.calculateAngle2D(
        pointA,
        vertex,
        pointC,
      );

      expect(angle, closeTo(0.0, 0.001));
    });

    test('Perhitungan sudut tepat 45° (diagonal 1:1)', () {
      const vertex = math.Point<double>(0.0, 0.0);
      const pointA = math.Point<double>(0.0, 1.0); // Sumbu Y (90°)
      const pointC = math.Point<double>(1.0, 1.0); // Diagonal 45°

      final angle = JointAngleCalculator.calculateAngle2D(
        pointA,
        vertex,
        pointC,
      );

      expect(angle, closeTo(45.0, 0.001));
    });

    test('Perhitungan sudut tepat 90° (siku-siku tegak lurus)', () {
      const vertex = math.Point<double>(0.0, 0.0);
      const pointA = math.Point<double>(0.0, 1.0); // Sumbu Y
      const pointC = math.Point<double>(1.0, 0.0); // Sumbu X

      final angle = JointAngleCalculator.calculateAngle2D(
        pointA,
        vertex,
        pointC,
      );

      expect(angle, closeTo(90.0, 0.001));
    });

    test('Perhitungan sudut tepat 180° (garis lurus berlawanan)', () {
      const vertex = math.Point<double>(0.0, 0.0);
      const pointA = math.Point<double>(-1.0, 0.0); // Kiri
      const pointC = math.Point<double>(1.0, 0.0); // Kanan

      final angle = JointAngleCalculator.calculateAngle2D(
        pointA,
        vertex,
        pointC,
      );

      expect(angle, closeTo(180.0, 0.001));
    });
  });
}
