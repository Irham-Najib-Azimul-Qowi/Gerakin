import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../controllers/profile_controller.dart';
import '../../models/user_profile.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';

/// Halaman Profil Pengguna untuk aplikasi GERAKIN.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.settings),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : _buildProfileContent(context, ref, state),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, ProfileState state) {
    final active = state.activeProfile;
    if (active == null) {
      return const Center(child: Text('Tidak ada profil aktif. Silakan buat profil.'));
    }


    return RefreshIndicator(
      onRefresh: () => ref.read(profileControllerProvider.notifier).loadProfiles(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE HEADER (CARD) ──────────────────────────────
            _buildProfileHeaderCard(context, active),
            const SizedBox(height: 16),

            // ── DAILY STREAK CARD ─────────────────────────────────
            _buildStreakCard(context, ref),
            const SizedBox(height: 24),

            // ── PROFILE PICKER / SWITCHER ──────────────────────────
            _buildProfileSwitcherSection(context, ref, state),
            const SizedBox(height: 24),

            // ── MOBILITY PROFILE & ATTRIBUTES ──────────────────────
            _buildSectionHeader('Profil Fisik & Mobilitas'),
            const SizedBox(height: 12),
            _buildMobilityDetailsCard(context, active),
            const SizedBox(height: 24),

            // ── WIZARD & ACTIONS ───────────────────────────────────
            _buildActionSection(context, active),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, UserProfile active) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: active.photoUrl != null && active.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.network(active.photoUrl!, fit: BoxFit.cover),
                    )
                  : Text(
                      active.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          active.displayName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (active.isGuest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TAMU',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (active.email != null && active.email!.isNotEmpty)
                    Text(
                      active.email!,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${active.gender} • ${active.height.toStringAsFixed(0)} cm • ${active.weight.toStringAsFixed(0)} kg',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSwitcherSection(BuildContext context, WidgetRef ref, ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Ganti Profil Aktif'),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.allProfiles.length + 1,
            itemBuilder: (context, index) {
              if (index == state.allProfiles.length) {
                // Tombol tambah profil
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateProfileDialog(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Profil Baru'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }

              final profile = state.allProfiles[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(profile.displayName),
                  selected: profile.isActive,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(profileControllerProvider.notifier).switchProfile(profile.id);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobilityDetailsCard(BuildContext context, UserProfile active) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(context, 'Tipe Kursi Roda', active.wheelchairType.toUpperCase()),
            const Divider(),
            _buildDetailRow(context, 'Tingkat Mobilitas', active.mobilityLevel.toUpperCase()),
            const Divider(),
            _buildDetailRow(context, 'Tangan Dominan', active.dominantHand == 'right' ? 'KANAN' : 'KIRI'),
            const Divider(),
            _buildDetailRow(context, 'Target Rehabilitasi', active.rehabilitationGoal.toUpperCase()),
            if (active.medicalNotes.isNotEmpty) ...[
              const Divider(),
              _buildDetailRow(context, 'Catatan Medis', active.medicalNotes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, UserProfile active) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(RouteNames.settings), // routing to settings
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Kelola Profil & Pengaturan'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/profile/edit'), // go to Edit Profile subroute
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Informasi Fisik'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/assessment-wizard'), // go to wizard route
            icon: const Icon(Icons.fitness_center_rounded),
            label: const Text('Mulai Uji Fisik (Wizard)'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String gender = 'Laki-laki';
    double height = 170;
    double weight = 65;
    String hand = 'right';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Profil Baru'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (val) => val == null || val.isEmpty ? 'Nama harus diisi' : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: gender,
                        decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                        items: const [
                          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                          DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                        ],
                        onChanged: (val) => setState(() => gender = val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: height.toString(),
                        decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)'),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => height = double.parse(val!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: weight.toString(),
                        decoration: const InputDecoration(labelText: 'Berat Badan (kg)'),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => weight = double.parse(val!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: hand,
                        decoration: const InputDecoration(labelText: 'Tangan Dominan'),
                        items: const [
                          DropdownMenuItem(value: 'right', child: Text('Kanan')),
                          DropdownMenuItem(value: 'left', child: Text('Kiri')),
                        ],
                        onChanged: (val) => setState(() => hand = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      ref.read(profileControllerProvider.notifier).createProfile(
                            displayName: name,
                            gender: gender,
                            birthDate: DateTime(2000, 1, 1),
                            height: height,
                            weight: weight,
                            wheelchairType: 'none',
                            mobilityLevel: 'intermediate',
                            dominantHand: hand,
                            rehabilitationGoal: 'Pelihara Kebugaran',
                            medicalNotes: '',
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, WidgetRef ref) {
    final gamificationState = ref.watch(gamificationControllerProvider);
    final currentStreak = gamificationState.streak?.currentStreak ?? 1;
    final longestStreak = gamificationState.streak?.longestStreak ?? 1;

    return Card(
      elevation: 0,
      color: Colors.orange.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.orange, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak Latihan Harian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currentStreak Hari Berturut-turut',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Rekor Terpanjang: $longestStreak Hari',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
