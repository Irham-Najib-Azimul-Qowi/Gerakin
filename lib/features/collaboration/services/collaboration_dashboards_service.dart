import '../domain/repositories/collaboration_repository.dart';
import '../models/exercise_program.dart';
import 'secure_sharing_service.dart';

/// Layanan agregasi data dashboard untuk peran Fisioterapis.
class PhysiotherapistDashboardService {
  final CollaborationRepository _repository;

  PhysiotherapistDashboardService(this._repository);

  /// Mendapatkan daftar semua ID pasien yang ditugaskan ke fisioterapis.
  Future<List<int>> getAssignedPatientIds(int physioId) async {
    final list = await _repository.getPhysioAssignments(physioId);
    return list.map((a) => a.patientId).toList();
  }
}

/// Layanan agregasi data dashboard untuk peran Caregiver (Pendamping).
class CaregiverDashboardService {
  final CollaborationRepository _repository;
  final SecureSharingService _sharingService;

  CaregiverDashboardService(this._repository, this._sharingService);

  /// Mendapatkan daftar jadwal program latihan pasien jika izin sharing aktif.
  Future<List<ExerciseProgram>> getPatientSchedule(int patientId, int caregiverId) async {
    final allowed = await _sharingService.isAccessAllowed(
      ownerId: patientId,
      accessorId: caregiverId,
      dataType: 'all',
    );
    if (!allowed) return const [];
    return _repository.getPatientPrograms(patientId);
  }
}
