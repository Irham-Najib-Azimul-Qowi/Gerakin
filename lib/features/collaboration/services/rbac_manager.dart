import '../domain/repositories/collaboration_repository.dart';

/// Pengendali Peran Pengguna (Role Manager).
class RoleManager {
  final CollaborationRepository _repository;

  RoleManager(this._repository);

  /// Mendapatkan peran aktif pengguna.
  Future<String> getUserRole(int userId) async {
    return _repository.getUserRole(userId);
  }

  /// Menetapkan peran baru bagi pengguna.
  Future<void> setUserRole(int userId, String role) async {
    await _repository.setUserRole(userId, role);
  }
}

/// Pengendali Hak Akses Fitur (Permission Manager).
class PermissionManager {
  /// Memeriksa kecocokan hak akses berdasarkan peran aktif.
  bool hasPermission(String role, String action) {
    if (role == 'admin') return true;

    switch (action) {
      case 'prescribe_exercises':
        return role == 'physiotherapist';
      case 'read_patient_analytics':
        return role == 'physiotherapist' || role == 'caregiver';
      case 'write_feedback_note':
        return role == 'physiotherapist' || role == 'caregiver';
      case 'view_prescriptions':
        return role == 'patient' || role == 'physiotherapist' || role == 'caregiver';
      default:
        return false;
    }
  }
}
