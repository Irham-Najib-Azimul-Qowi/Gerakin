import 'package:objectbox/objectbox.dart';

@Entity()
class CaregiverRelation {
  @Id()
  int id;

  final int caregiverId;
  final int patientId;
  final String relationType; // 'family' | 'professional'

  CaregiverRelation({
    this.id = 0,
    required this.caregiverId,
    required this.patientId,
    required this.relationType,
  });
}
