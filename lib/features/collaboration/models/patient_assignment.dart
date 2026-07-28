import 'package:objectbox/objectbox.dart';

@Entity()
class PatientAssignment {
  @Id()
  int id;

  final int physiotherapistId;
  final int patientId;

  @Property(type: PropertyType.date)
  final DateTime assignedAt;

  PatientAssignment({
    this.id = 0,
    required this.physiotherapistId,
    required this.patientId,
    required this.assignedAt,
  });
}
