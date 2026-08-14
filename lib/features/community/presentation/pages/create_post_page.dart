import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/community_controller.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedWorkoutTag = 'Stretching Bahu 15 Mnt';

  final List<String> _workoutOptions = [
    'Stretching Bahu 15 Mnt',
    'Latihan Keseimbangan Mandiri',
    'Kardio Ringan Tangan',
    'Mobilitas Leher & Kepala',
    'Latihan Beban Ringan Kursi Roda',
    'Tanpa Tag Latihan',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuliskan postingan terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final tagsText = _tagsController.text.trim();
    final tags = tagsText.isEmpty
        ? ['GerakinSehat', 'KomunitasGerakin']
        : tagsText.split(' ').map((t) => t.replaceAll('#', '')).where((t) => t.isNotEmpty).toList();

    final workoutTag = _selectedWorkoutTag == 'Tanpa Tag Latihan' ? null : _selectedWorkoutTag;

    final success = await ref.read(communityControllerProvider.notifier).createPost(
          caption: caption,
          mediaUrls: const [],
          workoutTag: workoutTag,
          tags: tags,
        );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan tulisan berhasil dipublikasikan! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan Tulisan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Posting'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Caption Input (X / Twitter Style) ──────────────────────────
            const Text(
              'Apa yang sedang Anda pikirkan / rasakan?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionController,
              maxLines: 6,
              style: const TextStyle(fontSize: 15, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Tuliskan pengalaman latihan, pertanyaan kesehatan, atau progres Anda hari ini...',
                hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // ── Tag Workout Exercise ──────────────────────────────────────
            const Text(
              'Tautkan Sesi Latihan GERAKIN (opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedWorkoutTag,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: Icon(Icons.fitness_center_rounded, color: theme.colorScheme.primary),
              ),
              items: _workoutOptions.map((tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorkoutTag = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // ── Hashtags Input ─────────────────────────────────────────────
            const Text(
              'Hashtag (opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Contoh: #GerakinSehat #Fisioterapi #Recovery',
                hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.tag_rounded),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
