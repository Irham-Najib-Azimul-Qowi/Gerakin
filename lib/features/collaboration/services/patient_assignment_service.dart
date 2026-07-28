import '../domain/repositories/collaboration_repository.dart';
import '../models/patient_assignment.dart';

/// Layanan untuk mengelola tugas pemetaan antara fisioterapis dan pasien.
class PatientAssignmentService {
  final CollaborationRepository _repository;

  PatientAssignmentService(this._repository);

  /// Menugaskan pasien tertentu ke fisioterapis.
  Future<void> assignPatientToPhysio({
    required int physiotherapistId,
    required int patientId,
  }) async {
    final assignment = PatientAssignment(
      physiotherapistId: physiotherapistId,
      patientId: patientId,
      assignedAt: DateTime.now(),
    );
    await _repository.assignPatient(assignment);
  }

  /// Mendapatkan daftar semua pemetaan pasien aktif dari seorang fisioterapis.
  Future<List<PatientAssignment>> getPhysioPatients(int physioId) async {
    return _repository.getPhysioAssignments(physioId);
  }
}
