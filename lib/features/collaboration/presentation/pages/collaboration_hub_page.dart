import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/collaboration_controller.dart';
import '../../../user/presentation/controllers/profile_controller.dart';
import '../../models/exercise_program.dart';
import '../../models/feedback_note.dart';
import '../../services/collaboration_providers.dart';

/// Halaman Hub Kolaborasi Terpadu (Unified Collaboration Page).
class CollaborationHubPage extends ConsumerWidget {
  const CollaborationHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collaborationControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final active = profileState.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kolaborasi Pemulihan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.isLoading || active == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── ROLE SELECTOR ──────────────────────────────
                  _buildRoleSelectorCard(context, ref, active.id, state.activeRole),
                  const SizedBox(height: 24),

                  // ── DYNAMIC ROLE HUB DASHBOARD ──────────────────
                  if (state.activeRole == 'patient') ...[
                    _buildPatientView(context, state),
                  ] else if (state.activeRole == 'physiotherapist') ...[
                    _buildPhysioView(context, ref, state, active.id),
                  ] else if (state.activeRole == 'caregiver') ...[
                    _buildCaregiverView(context, state),
                  ] else ...[
                    _buildAdminView(context, ref, state, active.id),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRoleSelectorCard(BuildContext context, WidgetRef ref, int userId, String currentRole) {
    final roles = ['patient', 'physiotherapist', 'caregiver', 'admin'];

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ganti Peran Demonstrasi (Simulasi)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: roles.map((r) {
                  final isSelected = currentRole == r;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(r.toUpperCase(), style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(collaborationControllerProvider.notifier)
                              .switchRole(userId, r);
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DYNAMIC VIEW: PATIENT ──────────────────────────────────────────
  Widget _buildPatientView(BuildContext context, CollaborationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Program Latihan Saya'),
        const SizedBox(height: 10),
        if (state.activePrograms.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Belum ada program latihan yang diresepkan oleh fisioterapis Anda.', style: TextStyle(fontSize: 12)),
            ),
          )
        else
          ...state.activePrograms.map((p) => _buildProgramPrescriptionCard(context, p)),
        const SizedBox(height: 24),
        _buildSectionHeader('Catatan Umpan Balik Dokter/Terapis'),
        const SizedBox(height: 10),
        if (state.feedbackNotes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Belum ada catatan umpan balik yang terkirim.', style: TextStyle(fontSize: 12)),
            ),
          )
        else
          ...state.feedbackNotes.map((n) => _buildFeedbackNoteCard(context, n)),
      ],
    );
  }

  Widget _buildProgramPrescriptionCard(BuildContext context, ExerciseProgram p) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: ListTile(
        title: Text(p.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(p.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Frekuensi: ${p.frequency.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: const Icon(Icons.assignment_rounded, color: Colors.blue),
      ),
    );
  }

  Widget _buildFeedbackNoteCard(BuildContext context, FeedbackNote n) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  n.authorRole.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(n.note, style: const TextStyle(fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // ── DYNAMIC VIEW: PHYSIOTHERAPIST ──────────────────────────────────
  Widget _buildPhysioView(BuildContext context, WidgetRef ref, CollaborationState state, int physioId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Daftar Pasien Saya'),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () => _showAssignPatientDialog(context, ref, physioId),
              tooltip: 'Daftarkan Pasien',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.assignedPatientIds.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Belum ada pasien yang ditugaskan kepada Anda.', style: TextStyle(fontSize: 12)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.assignedPatientIds.length,
            itemBuilder: (context, index) {
              final patientId = state.assignedPatientIds[index];
              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Pasien ID #$patientId', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Status: Aktif Rehabilitasi Seated', style: TextStyle(fontSize: 10)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.note_add_rounded, size: 20),
                        onPressed: () => _showAddFeedbackDialog(context, ref, patientId, physioId),
                        tooltip: 'Beri Catatan Umpan Balik',
                      ),
                      IconButton(
                        icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
                        onPressed: () => _showPrescribeProgramDialog(context, ref, patientId, physioId),
                        tooltip: 'Resepkan Program Latihan',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // ── DYNAMIC VIEW: CAREGIVER ────────────────────────────────────────
  Widget _buildCaregiverView(BuildContext context, CollaborationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Jadwal Reminders Pasien'),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Simulasi Schedule: Pasien ID #2 memiliki jadwal latihan Seated Arms pukul 14:00.', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  // ── DYNAMIC VIEW: ADMIN ────────────────────────────────────────────
  Widget _buildAdminView(BuildContext context, WidgetRef ref, CollaborationState state, int adminId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Administrator Console'),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Simulasi Role Assignment (Pengguna ID #2)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: const Text('Ubah peran pengguna demo ID #2 menjadi Fisioterapis', style: TextStyle(fontSize: 10)),
                trailing: TextButton(
                  onPressed: () {
                    ref.read(collaborationControllerProvider.notifier).switchRole(2, 'physiotherapist');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Peran Pengguna ID #2 diganti menjadi Fisioterapis')),
                    );
                  },
                  child: const Text('Ubah Peran'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showAssignPatientDialog(BuildContext context, WidgetRef ref, int physioId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Daftarkan Pasien Baru'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'ID Pasien (Angka)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                final patientId = int.tryParse(controller.text);
                if (patientId != null) {
                  ref
                      .read(collaborationControllerProvider.notifier)
                      .prescribeNewProgram(
                        patientId: patientId,
                        physioId: physioId,
                        title: 'Program Awal Rehabilitasi',
                        description: 'Latihan fleksibilitas lengan seated.',
                        exerciseIds: ['ex1', 'ex2'],
                        frequency: 'daily',
                      );
                  // Tambahkan pemetaan pasien
                  ref.read(patientAssignmentServiceProvider).assignPatientToPhysio(
                        physiotherapistId: physioId,
                        patientId: patientId,
                      );
                  ref.read(collaborationControllerProvider.notifier).loadCollaborationData(physioId);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFeedbackDialog(BuildContext context, WidgetRef ref, int patientId, int physioId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan Umpan Balik'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Tulis evaluasi Anda...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await ref.read(collaborationControllerProvider.notifier).addFeedbackNote(
                        patientId: patientId,
                        authorId: physioId,
                        authorRole: 'physiotherapist',
                        note: controller.text,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showPrescribeProgramDialog(BuildContext context, WidgetRef ref, int patientId, int physioId) {
    final titleCtrl = TextEditingController(text: 'Latihan ROM Seated');
    final descCtrl = TextEditingController(text: 'Latihan penguatan sendi atas 15 menit');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resepkan Program Latihan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Program')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi Latihan')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                await ref.read(collaborationControllerProvider.notifier).prescribeNewProgram(
                      patientId: patientId,
                      physioId: physioId,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      exerciseIds: ['shoulder_flexion'],
                      frequency: 'daily',
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Resepkan'),
            ),
          ],
        );
      },
    );
  }
}
