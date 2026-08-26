import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/community_feed_controller.dart';
import '../widgets/post_card.dart';

/// Halaman Feed Komunitas GERAKIN (Sesuai DESIGN.md).
///
/// Kebijakan Mode Tamu (Task 2):
/// Pengguna mode Tamu (Guest) hanya dapat membaca postingan & obrolan komentar.
/// Interaksi aktif (Buat Post, Like, Tambah Komentar, Lapor) memerlukan akun terdaftar.
class CommunityFeedPage extends ConsumerWidget {
  const CommunityFeedPage({super.key});

  void _showLoginPrompt(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'MASUK',
          textColor: AppColors.secondary,
          onPressed: () {
            context.push(RoutePaths.login);
          },
        ),
      ),
    );
  }

  void _handleCreatePost(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    if (user == null) {
      _showLoginPrompt(context, 'Anda harus masuk terlebih dahulu untuk membuat postingan.');
    } else {
      context.push(RoutePaths.communityCreate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(communityFeedControllerProvider);
    final feedController = ref.read(communityFeedControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final isGuest = authState.currentUser == null;

    // Listen for errors (Guest redirection or Moderation warning)
    ref.listen<CommunityFeedState>(communityFeedControllerProvider, (prev, next) {
      if (next.errorMessage == 'GUEST_NOT_ALLOWED') {
        _showLoginPrompt(context, 'Anda harus login terlebih dahulu untuk berinteraksi di komunitas.');
      } else if (next.moderationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.moderationError!),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.diversity_3_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Komunitas GerakIn',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreatePost(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('Buat Post'),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderRadiusXxl,
                boxShadow: AppShadows.softCard,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (value) => feedController.setSearchQuery(value),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari postingan, kata kunci, #hashtag...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  suffixIcon: feedState.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            feedController.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // ── Feed List ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await feedController.fetchFeed();
              },
              child: feedState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : feedState.posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.forum_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                feedState.searchQuery.isNotEmpty
                                    ? 'Postingan Tidak Ditemukan'
                                    : 'Belum Ada Postingan',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feedState.searchQuery.isNotEmpty
                                    ? 'Coba kata kunci atau #hashtag lain'
                                    : 'Jadilah yang pertama membagikan kisah atau progres Anda!',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _handleCreatePost(context, ref),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Buat Post Pertama'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: feedState.posts.length,
                          itemBuilder: (context, index) {
                            final post = feedState.posts[index];
                            return PostCard(
                              post: post,
                              onLikeToggle: () {
                                if (isGuest) {
                                  _showLoginPrompt(context, 'Masuk untuk menyukai postingan ini.');
                                  return;
                                }
                                feedController.toggleLike(post.id);
                              },
                              onAddComment: (content) {
                                if (isGuest) {
                                  _showLoginPrompt(context, 'Masuk untuk menambahkan komentar.');
                                  return;
                                }
                                feedController.addComment(
                                  postId: post.id,
                                  content: content,
                                );
                              },
                              onReportPost: (reason) {
                                if (isGuest) {
                                  _showLoginPrompt(context, 'Masuk untuk melaporkan konten.');
                                  return;
                                }
                                feedController.reportContent(
                                  targetType: 'post',
                                  targetId: post.id,
                                  reason: reason,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Laporan postingan telah tersimpan.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                              onHashtagTap: (hashtag) {
                                feedController.setSearchQuery(hashtag);
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
