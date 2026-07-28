import 'dart:convert';
import '../domain/repositories/collaboration_repository.dart';
import '../models/exercise_program.dart';

/// Layanan penulisan resep program gerakan latihan oleh fisioterapis.
class ExercisePrescriptionService {
  final CollaborationRepository _repository;

  ExercisePrescriptionService(this._repository);

  /// Meresepkan program latihan baru untuk pasien.
  Future<void> prescribeProgram({
    required int patientId,
    required int physioId,
    required String title,
    required String description,
    required List<String> exerciseIds,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final program = ExerciseProgram(
      patientId: patientId,
      physiotherapistId: physioId,
      title: title,
      description: description,
      exerciseIdsJson: jsonEncode(exerciseIds),
      frequency: frequency,
      startDate: startDate,
      endDate: endDate,
    );
    await _repository.prescribeProgram(program);
  }

  /// Mendapatkan semua resep program aktif untuk pasien tertentu.
  Future<List<ExerciseProgram>> getPatientPrograms(int patientId) async {
    return _repository.getPatientPrograms(patientId);
  }
}
