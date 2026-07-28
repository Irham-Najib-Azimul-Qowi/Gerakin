import 'package:objectbox/objectbox.dart';

@Entity()
class ExerciseProgram {
  @Id()
  int id;

  final int patientId;
  final int physiotherapistId;
  final String title;
  final String description;
  final String exerciseIdsJson; // Serialisasi JSON dari daftar ID gerakan
  final String frequency; // 'daily' | 'weekly'

  @Property(type: PropertyType.date)
  final DateTime startDate;

  @Property(type: PropertyType.date)
  final DateTime endDate;

  ExerciseProgram({
    this.id = 0,
    required this.patientId,
    required this.physiotherapistId,
    required this.title,
    required this.description,
    required this.exerciseIdsJson,
    required this.frequency,
    required this.startDate,
    required this.endDate,
  });

  ExerciseProgram copyWith({
    int? id,
    int? patientId,
    int? physiotherapistId,
    String? title,
    String? description,
    String? exerciseIdsJson,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExerciseProgram(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      physiotherapistId: physiotherapistId ?? this.physiotherapistId,
      title: title ?? this.title,
      description: description ?? this.description,
      exerciseIdsJson: exerciseIdsJson ?? this.exerciseIdsJson,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
