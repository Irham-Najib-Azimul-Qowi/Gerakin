import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/objectbox_store.dart';
import '../../../../objectbox.g.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../../models/user_role.dart';
import '../../models/patient_assignment.dart';
import '../../models/exercise_program.dart';
import '../../models/feedback_note.dart';
import '../../models/program_template.dart';
import '../../models/data_sharing_permission.dart';
import '../../models/caregiver_relation.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../../sync/data/repositories/sync_repository_impl.dart';

/// Implementasi [CollaborationRepository] menggunakan ObjectBox lokal & integrasi Sync Engine.
class CollaborationRepositoryImpl implements CollaborationRepository {
  final Box<UserRole> _roleBox;
  final Box<PatientAssignment> _assignBox;
  final Box<ExerciseProgram> _programBox;
  final Box<FeedbackNote> _noteBox;
  final Box<ProgramTemplate> _templateBox;
  final Box<DataSharingPermission> _permissionBox;
  final Box<CaregiverRelation> _relationBox;
  final SyncRepository _syncRepository;

  CollaborationRepositoryImpl(Store store, this._syncRepository)
      : _roleBox = store.box<UserRole>(),
        _assignBox = store.box<PatientAssignment>(),
        _programBox = store.box<ExerciseProgram>(),
        _noteBox = store.box<FeedbackNote>(),
        _templateBox = store.box<ProgramTemplate>(),
        _permissionBox = store.box<DataSharingPermission>(),
        _relationBox = store.box<CaregiverRelation>();

  @override
  Future<String> getUserRole(int userId) async {
    final query = (_roleBox.query(UserRole_.userId.equals(userId))).build();
    final results = query.find();
    query.close();
    if (results.isEmpty) return 'patient'; // Default role
    return results.first.role;
  }

  @override
  Future<void> setUserRole(int userId, String role) async {
    final query = (_roleBox.query(UserRole_.userId.equals(userId))).build();
    final results = query.find();
    query.close();

    if (results.isNotEmpty) {
      final updated = UserRole(id: results.first.id, userId: userId, role: role);
      _roleBox.put(updated);
    } else {
      _roleBox.put(UserRole(userId: userId, role: role));
    }

    await _syncRepository.queueChange(
      collection: 'users',
      documentId: 'role_$userId',
      operation: 'update',
      data: {
        'userId': userId,
        'role': role,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> assignPatient(PatientAssignment assignment) async {
    _assignBox.put(assignment);
    await _syncRepository.queueChange(
      collection: 'users',
      documentId: 'assign_${assignment.id}',
      operation: 'create',
      data: {
        'id': assignment.id,
        'physiotherapistId': assignment.physiotherapistId,
        'patientId': assignment.patientId,
        'assignedAt': assignment.assignedAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<List<PatientAssignment>> getPhysioAssignments(int physioId) async {
    final query = (_assignBox.query(PatientAssignment_.physiotherapistId.equals(physioId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<List<PatientAssignment>> getPatientAssignments(int patientId) async {
    final query = (_assignBox.query(PatientAssignment_.patientId.equals(patientId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<void> prescribeProgram(ExerciseProgram program) async {
    _programBox.put(program);
    await _syncRepository.queueChange(
      collection: 'sessions',
      documentId: 'program_${program.id}',
      operation: 'create',
      data: {
        'id': program.id,
        'patientId': program.patientId,
        'physiotherapistId': program.physiotherapistId,
        'title': program.title,
        'description': program.description,
        'exerciseIdsJson': program.exerciseIdsJson,
        'frequency': program.frequency,
        'startDate': program.startDate.toIso8601String(),
        'endDate': program.endDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<List<ExerciseProgram>> getPatientPrograms(int patientId) async {
    final query = (_programBox.query(ExerciseProgram_.patientId.equals(patientId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<List<ExerciseProgram>> getPhysioPrograms(int physioId) async {
    final query = (_programBox.query(ExerciseProgram_.physiotherapistId.equals(physioId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<void> saveProgramTemplate(ProgramTemplate template) async {
    _templateBox.put(template);
  }

  @override
  Future<List<ProgramTemplate>> getProgramTemplates() async {
    return _templateBox.getAll();
  }

  @override
  Future<void> saveFeedbackNote(FeedbackNote note) async {
    _noteBox.put(note);
    await _syncRepository.queueChange(
      collection: 'analytics',
      documentId: 'note_${note.id}',
      operation: 'create',
      data: {
        'id': note.id,
        'patientId': note.patientId,
        'authorId': note.authorId,
        'authorRole': note.authorRole,
        'note': note.note,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<List<FeedbackNote>> getPatientFeedbackNotes(int patientId) async {
    final query = (_noteBox.query(FeedbackNote_.patientId.equals(patientId))).build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<void> saveSharingPermission(DataSharingPermission permission) async {
    _permissionBox.put(permission);
    await _syncRepository.queueChange(
      collection: 'settings',
      documentId: 'permission_${permission.id}',
      operation: 'create',
      data: {
        'id': permission.id,
        'ownerId': permission.ownerId,
        'accessorId': permission.accessorId,
        'permittedDataType': permission.permittedDataType,
        'isAllowed': permission.isAllowed,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<DataSharingPermission?> getSharingPermission(int ownerId, int accessorId) async {
    final query = (_permissionBox.query(
      DataSharingPermission_.ownerId.equals(ownerId).and(DataSharingPermission_.accessorId.equals(accessorId)),
    )).build();
    final results = query.find();
    query.close();
    return results.isEmpty ? null : results.first;
  }

  @override
  Future<void> saveCaregiverRelation(CaregiverRelation relation) async {
    _relationBox.put(relation);
  }

  @override
  Future<List<CaregiverRelation>> getPatientCaregivers(int patientId) async {
    final query = (_relationBox.query(CaregiverRelation_.patientId.equals(patientId))).build();
    final results = query.find();
    query.close();
    return results;
  }
}

/// Provider untuk instansiasi [CollaborationRepository].
final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return CollaborationRepositoryImpl(store, syncRepo);
});
