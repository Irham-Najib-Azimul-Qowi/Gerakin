import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/community_post.dart';
import 'comments_bottom_sheet.dart';
import 'report_dialog.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLikeToggle;
  final Function(String content) onAddComment;
  final Function(String reason) onReportPost;
  final Function(String hashtag)? onHashtagTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onAddComment,
    required this.onReportPost,
    this.onHashtagTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          color: post.isReported
              ? Colors.red.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Penulis & Menu Laporkan ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    post.authorDisplayName.isNotEmpty
                        ? post.authorDisplayName[0].toUpperCase()
                        : 'G',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorDisplayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                      if (post.isReported)
                        const Text(
                          '⚠️ Postingan ini telah dilaporkan',
                          style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  onSelected: (value) {
                    if (value == 'report') {
                      ReportDialog.show(
                        context: context,
                        targetType: 'post',
                        targetId: post.id,
                        onReportSubmitted: onReportPost,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text('Laporkan Postingan', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Konten Teks ──────────────────────────────────────────────
            SelectableText(
              post.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // ── Hashtags Opsional ─────────────────────────────────────────
            if (post.hashtags != null && post.hashtags!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.hashtags!.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).map((tag) {
                  final formattedTag = tag.startsWith('#') ? tag : '#$tag';
                  return InkWell(
                    onTap: () => onHashtagTap?.call(formattedTag),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedTag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // ── Gambar Opsional ─────────────────────────────────────────
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.imagePath!.startsWith('http')
                    ? Image.network(post.imagePath!, fit: BoxFit.cover, width: double.infinity, height: 200)
                    : Image.file(File(post.imagePath!), fit: BoxFit.cover, width: double.infinity, height: 200),
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 8),

            // ── Action Bar (Komen & Suka) ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Comment Action
                InkWell(
                  onTap: () {
                    CommentsBottomSheet.show(
                      context: context,
                      post: post,
                      onAddComment: onAddComment,
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
                          post.commentCount > 0 ? '${post.commentCount}' : 'Komen',
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
                  onTap: onLikeToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          post.likeCount > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: post.likeCount > 0 ? Colors.pinkAccent : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likeCount > 0 ? '${post.likeCount}' : 'Suka',
                          style: TextStyle(
                            fontSize: 13,
                            color: post.likeCount > 0 ? Colors.pinkAccent : theme.colorScheme.onSurfaceVariant,
                            fontWeight: post.likeCount > 0 ? FontWeight.bold : FontWeight.w500,
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
