import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.currentUser?.uid ?? 'guest_user';

    final communityState = ref.watch(communityControllerProvider);
    final communityController = ref.read(communityControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.5,
        title: const Row(
          children: [
            Icon(Icons.diversity_3_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'GERAKIN Community',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  communityController.setSearchQuery('');
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('Buat Post'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await communityController.fetchPosts();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Search Field (Collapsible) ───────────────────────────────
            if (_isSearchVisible)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari postingan, kata kunci, atau anggota...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                communityController.setSearchQuery('');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                    ),
                    onChanged: (val) => communityController.setSearchQuery(val),
                  ),
                ),
              ),

            // ── Main Feed Post List ─────────────────────────────────────
            if (communityState.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (communityState.posts.isEmpty)
              SliverFillRemaining(
                child: Center(
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
                        'Tidak ada postingan ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jadilah orang pertama yang membagikan momen latihan!',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreatePostPage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Postingan Pertama'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = communityState.posts[index];
                      final isMyPost = post.authorId == currentUserId;

                      return PostCard(
                        post: post,
                        isMyPost: isMyPost,
                        onDeletePost: () async {
                          final success = await communityController.deletePost(post.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Postingan berhasil dihapus dari Firebase!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        onLikeToggle: () {
                          communityController.toggleLike(post.id);
                        },
                        onAddComment: (text, {parentId, replyToAuthorName}) {
                          communityController.addComment(
                            post.id,
                            text,
                            parentId: parentId,
                            replyToAuthorName: replyToAuthorName,
                          );
                        },
                        onHashtagTap: (tag) {
                          setState(() {
                            _isSearchVisible = true;
                            _searchController.text = '#$tag';
                          });
                          communityController.setSearchQuery('#$tag');
                        },
                      );
                    },
                    childCount: communityState.posts.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
