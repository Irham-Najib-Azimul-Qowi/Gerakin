import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/community_feed_controller.dart';
import '../widgets/post_card.dart';

class CommunityFeedPage extends ConsumerWidget {
  const CommunityFeedPage({super.key});

  void _handleCreatePost(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anda harus login terlebih dahulu untuk membuat postingan.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: Colors.yellowAccent,
            onPressed: () {
              context.push(RoutePaths.login);
            },
          ),
        ),
      );
    } else {
      context.push(RoutePaths.communityCreate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final feedState = ref.watch(communityFeedControllerProvider);
    final feedController = ref.read(communityFeedControllerProvider.notifier);

    // Listen for errors (Guest redirection or Moderation warning)
    ref.listen<CommunityFeedState>(communityFeedControllerProvider, (prev, next) {
      if (next.errorMessage == 'GUEST_NOT_ALLOWED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anda harus login terlebih dahulu untuk mengakses fitur komunitas.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'LOGIN',
              textColor: Colors.white,
              onPressed: () => context.push(RoutePaths.login),
            ),
          ),
        );
      } else if (next.moderationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.moderationError!),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.diversity_3_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Komunitas GERAKIN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreatePost(context, ref),
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('Buat Post'),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: (value) => feedController.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari postingan, kata kunci, #hashtag...',
                hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: feedState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          feedController.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Feed List ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await feedController.fetchFeed();
              },
              child: feedState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : feedState.posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                feedState.searchQuery.isNotEmpty
                                    ? 'Postingan Tidak Ditemukan'
                                    : 'Belum Ada Postingan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feedState.searchQuery.isNotEmpty
                                    ? 'Coba kata kunci atau #hashtag lain'
                                    : 'Jadilah yang pertama membagikan kisah atau progres Anda!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _handleCreatePost(context, ref),
                                icon: const Icon(Icons.add),
                                label: const Text('Buat Post Pertama'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: feedState.posts.length,
                          itemBuilder: (context, index) {
                            final post = feedState.posts[index];
                            return PostCard(
                              post: post,
                              onLikeToggle: () {
                                feedController.toggleLike(post.id);
                              },
                              onAddComment: (content) {
                                feedController.addComment(
                                  postId: post.id,
                                  content: content,
                                );
                              },
                              onReportPost: (reason) {
                                feedController.reportContent(
                                  targetType: 'post',
                                  targetId: post.id,
                                  reason: reason,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Laporan postingan telah tersimpan.'),
                                    backgroundColor: Colors.orange,
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

