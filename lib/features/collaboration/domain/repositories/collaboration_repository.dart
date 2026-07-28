import '../../models/patient_assignment.dart';
import '../../models/exercise_program.dart';
import '../../models/feedback_note.dart';
import '../../models/program_template.dart';
import '../../models/data_sharing_permission.dart';
import '../../models/caregiver_relation.dart';

/// Kontrak repositori untuk fungsionalitas Physiotherapist & Caregiver Collaboration.
abstract class CollaborationRepository {
  // Roles Management
  Future<String> getUserRole(int userId);
  Future<void> setUserRole(int userId, String role);

  // Patient Assignments
  Future<void> assignPatient(PatientAssignment assignment);
  Future<List<PatientAssignment>> getPhysioAssignments(int physioId);
  Future<List<PatientAssignment>> getPatientAssignments(int patientId);

  // Exercise Programs
  Future<void> prescribeProgram(ExerciseProgram program);
  Future<List<ExerciseProgram>> getPatientPrograms(int patientId);
  Future<List<ExerciseProgram>> getPhysioPrograms(int physioId);

  // Program Templates
  Future<void> saveProgramTemplate(ProgramTemplate template);
  Future<List<ProgramTemplate>> getProgramTemplates();

  // Feedback Notes
  Future<void> saveFeedbackNote(FeedbackNote note);
  Future<List<FeedbackNote>> getPatientFeedbackNotes(int patientId);

  // Data Sharing Permissions
  Future<void> saveSharingPermission(DataSharingPermission permission);
  Future<DataSharingPermission?> getSharingPermission(int ownerId, int accessorId);

  // Caregiver Relations
  Future<void> saveCaregiverRelation(CaregiverRelation relation);
  Future<List<CaregiverRelation>> getPatientCaregivers(int patientId);
}
