import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:gerakin/features/collaboration/models/patient_assignment.dart';
import 'package:gerakin/features/collaboration/models/exercise_program.dart';
import 'package:gerakin/features/collaboration/models/feedback_note.dart';
import 'package:gerakin/features/collaboration/models/program_template.dart';
import 'package:gerakin/features/collaboration/models/data_sharing_permission.dart';
import 'package:gerakin/features/collaboration/models/caregiver_relation.dart';
import 'package:gerakin/features/collaboration/services/rbac_manager.dart';
import 'package:gerakin/features/collaboration/services/patient_assignment_service.dart';
import 'package:gerakin/features/collaboration/services/exercise_prescription_service.dart';
import 'package:gerakin/features/collaboration/services/feedback_note_service.dart';
import 'package:gerakin/features/collaboration/services/secure_sharing_service.dart';
import 'package:gerakin/features/collaboration/services/notification_service.dart';
import 'package:gerakin/features/collaboration/services/collaboration_dashboards_service.dart';

/// Mock in-memory implementation dari [CollaborationRepository].
class MockCollaborationRepository implements CollaborationRepository {
  final Map<int, String> roles = {};
  final List<PatientAssignment> assignments = [];
  final List<ExerciseProgram> programs = [];
  final List<ProgramTemplate> templates = [];
  final List<FeedbackNote> notes = [];
  final Map<String, DataSharingPermission> permissions = {};
  final List<CaregiverRelation> relations = [];

  int _idCounter = 1;

  @override
  Future<String> getUserRole(int userId) async {
    return roles[userId] ?? 'patient';
  }

  @override
  Future<void> setUserRole(int userId, String role) async {
    roles[userId] = role;
  }

  @override
  Future<void> assignPatient(PatientAssignment assignment) async {
    assignment.id = _idCounter++;
    assignments.add(assignment);
  }

  @override
  Future<List<PatientAssignment>> getPhysioAssignments(int physioId) async {
    return assignments.where((x) => x.physiotherapistId == physioId).toList();
  }

  @override
  Future<List<PatientAssignment>> getPatientAssignments(int patientId) async {
    return assignments.where((x) => x.patientId == patientId).toList();
  }

  @override
  Future<void> prescribeProgram(ExerciseProgram program) async {
    program.id = _idCounter++;
    programs.add(program);
  }

  @override
  Future<List<ExerciseProgram>> getPatientPrograms(int patientId) async {
    return programs.where((x) => x.patientId == patientId).toList();
  }

  @override
  Future<List<ExerciseProgram>> getPhysioPrograms(int physioId) async {
    return programs.where((x) => x.physiotherapistId == physioId).toList();
  }

  @override
  Future<void> saveProgramTemplate(ProgramTemplate template) async {
    template.id = _idCounter++;
    templates.add(template);
  }

  @override
  Future<List<ProgramTemplate>> getProgramTemplates() async {
    return List.from(templates);
  }

  @override
  Future<void> saveFeedbackNote(FeedbackNote note) async {
    note.id = _idCounter++;
    notes.add(note);
  }

  @override
  Future<List<FeedbackNote>> getPatientFeedbackNotes(int patientId) async {
    return notes.where((x) => x.patientId == patientId).toList();
  }

  @override
  Future<void> saveSharingPermission(DataSharingPermission permission) async {
    if (permission.id == 0) {
      permission.id = _idCounter++;
    }
    permissions['${permission.ownerId}/${permission.accessorId}'] = permission;
  }

  @override
  Future<DataSharingPermission?> getSharingPermission(int ownerId, int accessorId) async {
    return permissions['$ownerId/$accessorId'];
  }

  @override
  Future<void> saveCaregiverRelation(CaregiverRelation relation) async {
    relation.id = _idCounter++;
    relations.add(relation);
  }

  @override
  Future<List<CaregiverRelation>> getPatientCaregivers(int patientId) async {
    return relations.where((x) => x.patientId == patientId).toList();
  }
}

void main() {
  group('Physiotherapist & Caregiver Collaboration Subsystem Tests', () {
    late MockCollaborationRepository repository;
    late RoleManager roleManager;
    late PermissionManager permissionManager;
    late PatientAssignmentService assignmentService;
    late ExercisePrescriptionService prescriptionService;
    late FeedbackNoteService feedbackNoteService;
    late SecureSharingService secureSharingService;
    late NotificationService notificationService;
    late CaregiverDashboardService caregiverDashboardService;

    setUp(() {
      repository = MockCollaborationRepository();
      roleManager = RoleManager(repository);
      permissionManager = PermissionManager();
      assignmentService = PatientAssignmentService(repository);
      prescriptionService = ExercisePrescriptionService(repository);
      feedbackNoteService = FeedbackNoteService(repository);
      secureSharingService = SecureSharingService(repository);
      notificationService = NotificationService();
      caregiverDashboardService = CaregiverDashboardService(repository, secureSharingService);
    });

    // ── 1. ROLE ASSIGNMENT & RBAC CHECKS ───────────────────────────────
    test('RoleManager assigns roles and PermissionManager asserts RBAC correctly', () async {
      // Peran awal default adalah patient
      var role = await roleManager.getUserRole(1);
      expect(role, equals('patient'));

      // Ubah peran pengguna ke physiotherapist
      await roleManager.setUserRole(1, 'physiotherapist');
      role = await roleManager.getUserRole(1);
      expect(role, equals('physiotherapist'));

      // Cek hak akses aksi
      expect(permissionManager.hasPermission('physiotherapist', 'prescribe_exercises'), isTrue);
      expect(permissionManager.hasPermission('patient', 'prescribe_exercises'), isFalse);
      expect(permissionManager.hasPermission('caregiver', 'prescribe_exercises'), isFalse);

      expect(permissionManager.hasPermission('caregiver', 'write_feedback_note'), isTrue);
      expect(permissionManager.hasPermission('patient', 'write_feedback_note'), isFalse);
    });

    // ── 2. PATIENT ASSIGNMENTS ──────────────────────────────────────────
    test('PatientAssignmentService links patient and physiotherapist', () async {
      await assignmentService.assignPatientToPhysio(physiotherapistId: 10, patientId: 20);
      
      final assignments = await assignmentService.getPhysioPatients(10);
      expect(assignments.length, equals(1));
      expect(assignments.first.patientId, equals(20));
      expect(assignments.first.physiotherapistId, equals(10));
    });

    // ── 3. SECURE DATA SHARING PRIVILEGES ──────────────────────────────
    test('SecureSharingService validates sharing permission boundaries', () async {
      // Akses awal ditolak jika izin belum diberikan
      var allowed = await secureSharingService.isAccessAllowed(ownerId: 20, accessorId: 30, dataType: 'analytics');
      expect(allowed, isFalse);

      // Berikan hak akses
      await secureSharingService.grantAccess(ownerId: 20, accessorId: 30, permittedDataType: 'analytics');
      allowed = await secureSharingService.isAccessAllowed(ownerId: 20, accessorId: 30, dataType: 'analytics');
      expect(allowed, isTrue);

      // Akses tipe lain tetap ditolak jika tidak dicakup
      allowed = await secureSharingService.isAccessAllowed(ownerId: 20, accessorId: 30, dataType: 'profile');
      expect(allowed, isFalse);

      // Cabut hak akses
      await secureSharingService.revokeAccess(ownerId: 20, accessorId: 30);
      allowed = await secureSharingService.isAccessAllowed(ownerId: 20, accessorId: 30, dataType: 'analytics');
      expect(allowed, isFalse);
    });

    // ── 4. FEEDBACK NOTES ───────────────────────────────────────────────
    test('FeedbackNoteService adds and retrieves notes correctly', () async {
      await feedbackNoteService.addFeedback(
        patientId: 20,
        authorId: 10,
        authorRole: 'physiotherapist',
        note: 'Sangat bagus progress geraknya.',
      );
      final notes = await feedbackNoteService.getFeedbackNotes(20);
      expect(notes.length, equals(1));
      expect(notes.first.note, equals('Sangat bagus progress geraknya.'));
    });

    // ── 4. NOTIFICATION RULES EVALUATION ────────────────────────────────
    test('NotificationService evaluate performance rules and sends alerts', () async {
      // Evaluasi performa buruk (akurasi < 60%) -> kirim peringatan
      await notificationService.evaluatePerformanceAlerts(
        patientId: 20,
        physioId: 10,
        accuracy: 0.5, // 50%
        recoveryTrend: 4.0,
      );

      expect(notificationService.notificationsList.length, equals(1));
      expect(notificationService.notificationsList.first, contains('Peringatan Akurasi Pasien'));

      // Evaluasi performa baik (akurasi > 60%) -> tidak mengirimkan peringatan
      await notificationService.evaluatePerformanceAlerts(
        patientId: 20,
        physioId: 10,
        accuracy: 0.9, // 90%
        recoveryTrend: 5.0,
      );
      expect(notificationService.notificationsList.length, equals(1)); // tetap 1
    });

    // ── 5. CAREGIVER INTEGRATED SCHEDULES ───────────────────────────────
    test('CaregiverDashboardService retrieves patient schedules conditional to permissions', () async {
      // Resepkan resep program latihan ke pasien ID #20
      await prescriptionService.prescribeProgram(
        patientId: 20,
        physioId: 10,
        title: 'Latihan Sendi Seated',
        description: 'Terapi gerak lengan',
        exerciseIds: ['shoulder_1'],
        frequency: 'daily',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      // Caregiver ID #30 coba akses jadwal sebelum mendapat izin
      var schedule = await caregiverDashboardService.getPatientSchedule(20, 30);
      expect(schedule.isEmpty, isTrue);

      // Berikan izin berbagi data seluruh tipe ('all')
      await secureSharingService.grantAccess(ownerId: 20, accessorId: 30, permittedDataType: 'all');
      
      // Ambil jadwal ulang setelah izin diberikan
      schedule = await caregiverDashboardService.getPatientSchedule(20, 30);
      expect(schedule.length, equals(1));
      expect(schedule.first.title, equals('Latihan Sendi Seated'));
    });
  });
}
