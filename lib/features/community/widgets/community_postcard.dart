import 'package:flutter/material.dart';
// TODO: color and upvotes downvotes insetead of just votes

class CommunityPostCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? text;
  final String authorName;
  final DateTime createdAt;
  final List<String> votes;
  final String currentUid;
  final List<String> tags;
  final VoidCallback onVote;

  const CommunityPostCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.text,
    required this.authorName,
    required this.createdAt,
    required this.votes,
    this.tags = const [],
    required this.currentUid,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Content (image or text)
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl!,
                    height: 160, width: double.infinity, fit: BoxFit.cover),
              )
            else if (text != null)
              Text(
                text!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),

            const SizedBox(height: 12),

            // Tags
            if (tags.isNotEmpty)
              Wrap(
                spacing: 6,
                children: tags
                    .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        backgroundColor: theme.colorScheme.primaryContainer))
                    .toList(),
              ),

            const SizedBox(height: 8),

            // Bottom bar: user info + votes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Author + Date
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
                // Voting buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      onPressed: onVote,
                    ),
                    Text(votes.length.toString(),
                        style: theme.textTheme.labelMedium),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 20),
                      onPressed: onVote,
                    ),
                  ],
                )
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
