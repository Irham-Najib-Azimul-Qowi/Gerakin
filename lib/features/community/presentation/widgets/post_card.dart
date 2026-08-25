import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/community_post.dart';
import 'comments_bottom_sheet.dart';
import 'report_dialog.dart';

/// Card Postingan Komunitas GERAKIN (Sesuai DESIGN.md).
///
/// 24px border radius, white surface, softCard shadow, subtle border #E2E8F0.
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        boxShadow: AppShadows.softCard,
        border: Border.all(
          color: post.isReported
              ? AppColors.error.withValues(alpha: 0.6)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Penulis & Menu Laporkan ─────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    post.authorDisplayName.isNotEmpty
                        ? post.authorDisplayName[0].toUpperCase()
                        : 'G',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '·',
                            style: AppTextStyles.captionMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTimestamp(post.createdAt),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (post.isReported)
                        Text(
                          '⚠️ Postingan ini telah dilaporkan',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          Icon(Icons.flag_outlined, color: AppColors.warning, size: 18),
                          SizedBox(width: 8),
                          Text('Laporkan Postingan', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Konten Teks ──────────────────────────────────────────
            SelectableText(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),

            // ── Hashtags Opsional ─────────────────────────────────────
            if (post.hashtags != null && post.hashtags!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.hashtags!.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).map((tag) {
                  final formattedTag = tag.startsWith('#') ? tag : '#$tag';
                  return InkWell(
                    onTap: () => onHashtagTap?.call(formattedTag),
                    borderRadius: AppRadius.borderRadiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: AppRadius.borderRadiusSm, // 8px chip
                      ),
                      child: Text(
                        formattedTag,
                        style: AppTextStyles.captionSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // ── Gambar Opsional ──────────────────────────────────────
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: post.imagePath!.startsWith('http')
                    ? Image.network(post.imagePath!, fit: BoxFit.cover, width: double.infinity, height: 200)
                    : Image.file(File(post.imagePath!), fit: BoxFit.cover, width: double.infinity, height: 200),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),

            // ── Action Bar (Komen & Suka) ──────────────────────────────
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
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.commentCount > 0 ? '${post.commentCount}' : 'Komen',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
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
                          size: 19,
                          color: post.likeCount > 0 ? AppColors.error : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likeCount > 0 ? '${post.likeCount}' : 'Suka',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: post.likeCount > 0 ? AppColors.error : AppColors.textSecondary,
                            fontWeight: post.likeCount > 0 ? FontWeight.bold : FontWeight.w600,
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
