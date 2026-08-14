import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/community_controller.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_post.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final CommunityPost post;
  final Function(String text, {String? parentId, String? replyToAuthorName}) onAddComment;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    required this.onAddComment,
  });

  static void show({
    required BuildContext context,
    required CommunityPost post,
    required Function(String text, {String? parentId, String? replyToAuthorName}) onAddComment,
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
  final FocusNode _commentFocusNode = FocusNode();

  List<CommunityComment> _comments = [];
  bool _isLoading = true;
  CommunityComment? _replyToComment;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });
    final comments = await ref.read(communityControllerProvider.notifier).getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  void _setReplyTo(CommunityComment comment) {
    setState(() {
      _replyToComment = comment;
    });
    _commentFocusNode.requestFocus();
  }

  void _clearReplyTo() {
    setState(() {
      _replyToComment = null;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyToComment != null
        ? (_replyToComment!.parentId ?? _replyToComment!.id)
        : null;
    final replyToAuthorName = _replyToComment?.authorName;

    _commentController.clear();
    _clearReplyTo();

    widget.onAddComment(text, parentId: parentId, replyToAuthorName: replyToAuthorName);

    // Refresh comments list
    await _loadComments();
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j';
    } else {
      return DateFormat('dd/MM HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Filter comments into parent comments and child replies
    final parentComments = _comments.where((c) => c.parentId == null).toList();

    return Container(
      height: mediaQuery.size.height * 0.80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Balasan & Komentar (${_comments.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Comments List (Nested Threading Style ala X / Twitter)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada komentar.\nJadilah yang pertama membalas postingan ini!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: parentComments.length,
                        itemBuilder: (context, index) {
                          final parent = parentComments[index];
                          final childReplies = _comments.where((c) => c.parentId == parent.id).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parent Comment Item
                              _buildCommentTile(parent, isReply: false, theme: theme),

                              // Child Replies List
                              if (childReplies.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 28, top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: childReplies.map((reply) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.only(left: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: _buildCommentTile(reply, isReply: true, theme: theme),
                                      );
                                    }).toList(),
                                  ),
                                ),

                              const SizedBox(height: 14),
                              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                              const SizedBox(height: 14),
                            ],
                          );
                        },
                      ),
          ),

          // ── Reply Bar Indicator (When user is replying to someone) ────────
          if (_replyToComment != null)
            Container(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Membalas @${_replyToComment!.authorName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearReplyTo,
                    child: Icon(Icons.close_rounded, size: 16, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + mediaQuery.viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyToComment != null
                          ? 'Tulis balasan untuk @${_replyToComment!.authorName}...'
                          : 'Tuliskan balasan Anda...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommunityComment comment, {required bool isReply, required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isReply ? 14 : 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'G',
            style: TextStyle(
              fontSize: isReply ? 11 : 12,
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
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (comment.replyToAuthorName != null && isReply) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_right_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    Text(
                      '@${comment.replyToAuthorName}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Text(
                    '·',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(comment.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _setReplyTo(comment),
                child: Text(
                  'Balas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
