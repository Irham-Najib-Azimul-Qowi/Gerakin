import '../domain/repositories/collaboration_repository.dart';
import '../models/data_sharing_permission.dart';

/// Layanan pembagian data aman (Secure Sharing) bagi pengakses pihak ketiga (Caregiver/Physiotherapist).
class SecureSharingService {
  final CollaborationRepository _repository;

  SecureSharingService(this._repository);

  /// Memberikan izin pembagian akses data kepada pengakses tertentu.
  Future<void> grantAccess({
    required int ownerId,
    required int accessorId,
    required String permittedDataType,
  }) async {
    final existing = await _repository.getSharingPermission(ownerId, accessorId);
    if (existing != null) {
      await _repository.saveSharingPermission(existing.copyWith(
        permittedDataType: permittedDataType,
        isAllowed: true,
      ));
    } else {
      final perm = DataSharingPermission(
        ownerId: ownerId,
        accessorId: accessorId,
        permittedDataType: permittedDataType,
        isAllowed: true,
      );
      await _repository.saveSharingPermission(perm);
    }
  }

  /// Menarik kembali (revoke) hak akses pembagian data.
  Future<void> revokeAccess({
    required int ownerId,
    required int accessorId,
  }) async {
    final existing = await _repository.getSharingPermission(ownerId, accessorId);
    if (existing != null) {
      final updated = existing.copyWith(isAllowed: false);
      await _repository.saveSharingPermission(updated);
    }
  }

  /// Memverifikasi apakah akses data diizinkan sesuai dengan aturan pengakses.
  Future<bool> isAccessAllowed({
    required int ownerId,
    required int accessorId,
    required String dataType,
  }) async {
    final perm = await _repository.getSharingPermission(ownerId, accessorId);
    if (perm == null) return false;
    if (!perm.isAllowed) return false;
    return perm.permittedDataType == 'all' || perm.permittedDataType == dataType;
  }
}
