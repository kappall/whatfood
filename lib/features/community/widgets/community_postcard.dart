import 'package:flutter/material.dart';

class CommunityPostCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? text;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final List<String> upVotes;
  final List<String> downVotes;
  final String currentUid;
  final List<String> tags;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onSave;

  const CommunityPostCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.text,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.upVotes,
    required this.downVotes,
    this.tags = const [],
    required this.currentUid,
    required this.onUpvote,
    required this.onDownvote,
    this.onDelete,
    this.onReport,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthor = authorId == currentUid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        onSave?.call();
                        break;
                      case 1:
                        onReport?.call();
                        break;
                      case 2:
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    if (onSave != null)
                      const PopupMenuItem(value: 0, child: Text('Save')),
                    if (onReport != null)
                      const PopupMenuItem(value: 1, child: Text('Report')),
                    if (isAuthor && onDelete != null) ...[
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 2,
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                    const PopupMenuItem(value: 0, child: Text('Test')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else if (text != null)
              Text(
                text!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 6,
                children: tags
                    .map((tag) => Chip(
                          label:
                              Text(tag, style: const TextStyle(fontSize: 12)),
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withOpacity(.7),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(authorName, style: theme.textTheme.labelSmall),
                    const SizedBox(width: 8),
                    Text('· ${_formatDate(createdAt)}',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      color: upVotes.contains(currentUid)
                          ? Colors.green
                          : theme.iconTheme.color,
                      onPressed: onUpvote,
                    ),
                    Text((upVotes.length - downVotes.length).toString(),
                        style: theme.textTheme.labelMedium),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 20),
                      color: downVotes.contains(currentUid)
                          ? Colors.red
                          : theme.iconTheme.color,
                      onPressed: onDownvote,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
