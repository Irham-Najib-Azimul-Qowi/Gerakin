import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../models/community_comment.dart';
import '../../models/community_post.dart';
import '../controllers/community_feed_controller.dart';
import 'comment_tile.dart';

/// Bottom sheet untuk melihat dan menambahkan komentar diskusi (Sesuai DESIGN.md).
///
/// Kebijakan Mode Tamu (Task 2):
/// Pengguna Tamu (Guest) dapat melihat seluruh obrolan komentar, tetapi kolom penulisan
/// komentar dikunci dengan tombol ajakan masuk (Login).
class CommentsBottomSheet extends ConsumerStatefulWidget {
  final CommunityPost post;
  final Function(String content) onAddComment;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    required this.onAddComment,
  });

  static void show({
    required BuildContext context,
    required CommunityPost post,
    required Function(String content) onAddComment,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        post: post,
        onAddComment: onAddComment,
      ),
    );
  }

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<CommunityComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });
    final comments = await ref
        .read(communityFeedControllerProvider.notifier)
        .getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    widget.onAddComment(text);
    await _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authState = ref.watch(authControllerProvider);
    final isGuest = authState.currentUser == null;

    return Container(
      height: mediaQuery.size.height * 0.80,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Komentar (${_comments.length})',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada komentar.\nJadilah yang pertama membalas!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return CommentTile(
                            comment: comment,
                            onReportComment: (reason) {
                              if (isGuest) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Silakan login terlebih dahulu untuk melaporkan komentar.'),
                                    action: SnackBarAction(
                                      label: 'LOGIN',
                                      textColor: AppColors.secondary,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        context.push(RoutePaths.login);
                                      },
                                    ),
                                  ),
                                );
                                return;
                              }
                              ref
                                  .read(communityFeedControllerProvider.notifier)
                                  .reportContent(
                                    targetType: 'comment',
                                    targetId: comment.id,
                                    reason: reason,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Laporan komentar berhasil dikirim.'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),

          // ── Bottom Comment Bar ─────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + mediaQuery.viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: isGuest
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Masuk untuk ikut berdiskusi',
                          style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(RoutePaths.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Masuk'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Tuliskan komentar Anda...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXxl,
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXxl,
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.borderRadiusXxl,
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: _submitComment,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
