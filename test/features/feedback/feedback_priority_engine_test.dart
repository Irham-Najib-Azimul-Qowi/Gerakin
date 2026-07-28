import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/feedback/models/feedback_message.dart';
import 'package:gerakin/features/feedback/models/feedback_priority.dart';
import 'package:gerakin/features/feedback/models/feedback_type.dart';
import 'package:gerakin/features/feedback/services/feedback_priority_engine.dart';

void main() {
  group('FeedbackPriorityEngine Tests', () {
    late FeedbackPriorityEngine priorityEngine;

    setUp(() {
      priorityEngine = const FeedbackPriorityEngine();
    });

    test('Mengurutkan pesan dari prioritas tertinggi ke terendah', () {
      final now = DateTime.now();

      final msgLow = FeedbackMessage(
        id: 'low_msg',
        type: FeedbackType.instruction,
        priority: FeedbackPriority.low,
        text: 'Instruction',
        timestamp: now,
      );

      final msgCritical = FeedbackMessage(
        id: 'critical_msg',
        type: FeedbackType.warning,
        priority: FeedbackPriority.critical,
        text: 'Critical Warning',
        timestamp: now,
      );

      final msgHigh = FeedbackMessage(
        id: 'high_msg',
        type: FeedbackType.liveCoaching,
        priority: FeedbackPriority.high,
        text: 'High Coaching',
        timestamp: now,
      );

      final sorted = priorityEngine.sortMessages([msgLow, msgCritical, msgHigh]);

      expect(sorted.first.id, equals('critical_msg'));
      expect(sorted[1].id, equals('high_msg'));
      expect(sorted.last.id, equals('low_msg'));
    });

    test('selectPrimaryMessage memilih pesan prioritas utama', () {
      final now = DateTime.now();

      final messages = [
        FeedbackMessage(
          id: 'medium_msg',
          type: FeedbackType.liveCoaching,
          priority: FeedbackPriority.medium,
          text: 'Medium',
          timestamp: now,
        ),
        FeedbackMessage(
          id: 'critical_msg',
          type: FeedbackType.warning,
          priority: FeedbackPriority.critical,
          text: 'Critical Warning',
          timestamp: now,
        ),
      ];

      final primary = priorityEngine.selectPrimaryMessage(messages);

      expect(primary, isNotNull);
      expect(primary!.id, equals('critical_msg'));
    });
  });
}
