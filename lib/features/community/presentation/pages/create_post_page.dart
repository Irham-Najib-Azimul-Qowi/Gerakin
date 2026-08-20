import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../controllers/community_feed_controller.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuliskan postingan terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref
        .read(communityFeedControllerProvider.notifier)
        .createPost(content: content);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      final feedState = ref.read(communityFeedControllerProvider);
      if (feedState.errorMessage == 'GUEST_NOT_ALLOWED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login terlebih dahulu untuk membuat postingan.'),
            backgroundColor: Colors.red,
          ),
        );
        context.push(RoutePaths.login);
      } else if (feedState.moderationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedState.moderationError!),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil dibuat! 🚀'),
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
        title: const Text('Buat Postingan Baru'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa yang ingin Anda bagikan hari ini?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 6,
              style: const TextStyle(fontSize: 15, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Tuliskan pengalaman latihan, pertanyaan, atau pencapaian Anda...',
                hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tambah Hashtags Populer:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                '#SemangatLatihan',
                '#KursiRoda',
                '#Fisioterapi',
                '#Aksesibilitas',
                '#PencapaianHariIni',
              ].map((tag) {
                return ActionChip(
                  label: Text(tag, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onPressed: () {
                    final currentText = _contentController.text;
                    if (!currentText.contains(tag)) {
                      _contentController.text = currentText.isEmpty
                          ? tag
                          : '$currentText $tag';
                      _contentController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _contentController.text.length),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
