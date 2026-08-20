import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/community_comment.dart';
import 'report_dialog.dart';

class CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final Function(String reason)? onReportComment;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReportComment,
  });

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              comment.authorDisplayName.isNotEmpty
                  ? comment.authorDisplayName[0].toUpperCase()
                  : 'G',
              style: TextStyle(
                fontSize: 12,
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
                      comment.authorDisplayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
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
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Laporkan komentar',
                      onPressed: () {
                        if (onReportComment != null) {
                          ReportDialog.show(
                            context: context,
                            targetType: 'comment',
                            targetId: comment.id,
                            onReportSubmitted: onReportComment!,
                          );
                        }
                      },
                    ),
                  ],
                ),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
