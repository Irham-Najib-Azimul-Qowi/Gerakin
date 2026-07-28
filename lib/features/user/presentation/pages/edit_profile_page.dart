import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/profile_controller.dart';

/// Halaman untuk mengedit data fisik dan informasi personal pengguna.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late String _gender;
  late double _height;
  late double _weight;
  late String _wheelchairType;
  late String _dominantHand;
  late String _medicalNotes;

  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final active = state.activeProfile;

    if (active == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profil')),
        body: const Center(child: Text('Tidak ada profil aktif.')),
      );
    }

    if (!_initialized) {
      _displayName = active.displayName;
      _gender = active.gender;
      _height = active.height;
      _weight = active.weight;
      _wheelchairType = active.wheelchairType;
      _dominantHand = active.dominantHand;
      _medicalNotes = active.medicalNotes;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Fisik', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── DISPLAY NAME ───────────────────────────────────────
              TextFormField(
                initialValue: _displayName,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                onSaved: (val) => _displayName = val!.trim(),
              ),
              const SizedBox(height: 16),

              // ── GENDER ─────────────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
                onChanged: (val) => setState(() => _gender = val!),
              ),
              const SizedBox(height: 16),

              // ── HEIGHT & WEIGHT ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _height.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Badan (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) return 'Input tidak valid';
                        final h = double.parse(val);
                        if (h < 50 || h > 250) return 'Range: 50-250';
                        return null;
                      },
                      onSaved: (val) => _height = double.parse(val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _weight.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Berat Badan (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) return 'Input tidak valid';
                        final w = double.parse(val);
                        if (w < 10 || w > 300) return 'Range: 10-300';
                        return null;
                      },
                      onSaved: (val) => _weight = double.parse(val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── WHEELCHAIR TYPE ────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _wheelchairType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kursi Roda',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Tidak Menggunakan (Seated/Stand)')),
                  DropdownMenuItem(value: 'manual', child: Text('Manual Wheelchair')),
                  DropdownMenuItem(value: 'power', child: Text('Power/Electric Wheelchair')),
                ],
                onChanged: (val) => setState(() => _wheelchairType = val!),
              ),
              const SizedBox(height: 16),

              // ── DOMINANT HAND ──────────────────────────────────────
              DropdownButtonFormField<String>(
                initialValue: _dominantHand,
                decoration: const InputDecoration(
                  labelText: 'Tangan Dominan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'right', child: Text('Kanan (Right)')),
                  DropdownMenuItem(value: 'left', child: Text('Kiri (Left)')),
                ],
                onChanged: (val) => setState(() => _dominantHand = val!),
              ),
              const SizedBox(height: 16),

              // ── MEDICAL NOTES ──────────────────────────────────────
              TextFormField(
                initialValue: _medicalNotes,
                decoration: const InputDecoration(
                  labelText: 'Catatan Medis / Keterbatasan Fisik',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                onSaved: (val) => _medicalNotes = val ?? '',
              ),
              const SizedBox(height: 24),

              // ── SUBMIT BUTTON ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final updated = active.copyWith(
                        displayName: _displayName,
                        gender: _gender,
                        height: _height,
                        weight: _weight,
                        wheelchairType: _wheelchairType,
                        dominantHand: _dominantHand,
                        medicalNotes: _medicalNotes,
                      );
                      await ref.read(profileControllerProvider.notifier).updateActiveProfile(updated);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
