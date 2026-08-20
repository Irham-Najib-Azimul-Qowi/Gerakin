import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/community_post.dart';
import '../controllers/community_feed_controller.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends ConsumerWidget {
  final CommunityPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedController = ref.read(communityFeedControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            PostCard(
              post: post,
              onLikeToggle: () {
                feedController.toggleLike(post.id);
              },
              onAddComment: (content) {
                feedController.addComment(postId: post.id, content: content);
              },
              onReportPost: (reason) {
                feedController.reportContent(
                  targetType: 'post',
                  targetId: post.id,
                  reason: reason,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
