import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/community_post.dart';
import 'comments_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback onLikeToggle;
  final Function(String text, {String? parentId, String? replyToAuthorName}) onAddComment;
  final Function(String hashtag)? onHashtagTap;
  final bool isMyPost;
  final VoidCallback? onDeletePost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onAddComment,
    this.onHashtagTap,
    this.isMyPost = false,
    this.onDeletePost,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _formatTimestamp(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}h';
    } else {
      return DateFormat('d MMM').format(dateTime);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Postingan?'),
        content: const Text('Apakah Anda yakin ingin menghapus postingan ini? Postingan akan dihapus secara permanen dari Firebase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.onDeletePost?.call();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Twitter / X Style) ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.startsWith('http')
                      ? NetworkImage(post.authorAvatarUrl!)
                      : (post.authorAvatarUrl != null && post.authorAvatarUrl!.startsWith('data:image')
                          ? MemoryImage(base64Decode(post.authorAvatarUrl!.split(',').last)) as ImageProvider
                          : null),
                  child: (post.authorAvatarUrl == null || (!post.authorAvatarUrl!.startsWith('http') && !post.authorAvatarUrl!.startsWith('data:image')))
                      ? Text(
                          post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'G',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.authorBadge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: post.authorBadge == 'Fisioterapis'
                                ? Colors.teal.withValues(alpha: 0.15)
                                : theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post.authorBadge!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: post.authorBadge == 'Fisioterapis'
                                  ? Colors.teal.shade800
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isMyPost && widget.onDeletePost != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, size: 20, color: theme.colorScheme.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Hapus Postingan', style: TextStyle(color: Colors.red, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Post Text Content (Twitter/X Style) ──────────────────────────
            SelectableText(
              post.caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
                letterSpacing: -0.2,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // ── Workout Tag Pill ─────────────────────────────────────────
            if (post.workoutTag != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.workoutTag!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Hashtags (Clickable to Search) ────────────────────────────
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((t) {
                  return InkWell(
                    onTap: () => widget.onHashtagTap?.call(t),
                    borderRadius: BorderRadius.circular(4),
                    child: Text(
                      '#$t',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 8),

            // ── Action Bar (Comment & Like ONLY) ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Comment Action
                InkWell(
                  onTap: () {
                    CommentsBottomSheet.show(
                      context: context,
                      post: post,
                      onAddComment: widget.onAddComment,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 19,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.commentsCount > 0 ? '${post.commentsCount}' : 'Komen',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Like Action
                InkWell(
                  onTap: widget.onLikeToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          widget.post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: widget.post.isLikedByMe ? Colors.pinkAccent : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likesCount > 0 ? '${post.likesCount}' : 'Suka',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.post.isLikedByMe ? Colors.pinkAccent : theme.colorScheme.onSurfaceVariant,
                            fontWeight: widget.post.isLikedByMe ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
