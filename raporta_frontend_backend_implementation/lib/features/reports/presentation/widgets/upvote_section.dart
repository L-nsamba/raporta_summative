import 'package:flutter/material.dart';

class UpvoteSection extends StatelessWidget {
  final int upvoteCount;
  final bool hasUpvoted;
  final bool isUpvoting;
  final VoidCallback onPressed;

  const UpvoteSection({
    super.key,
    required this.upvoteCount,
    required this.hasUpvoted,
    required this.isUpvoting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Support',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$upvoteCount upvotes',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: isUpvoting ? null : onPressed,
              icon: Icon(hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined),
              label: Text(hasUpvoted ? 'Upvoted' : 'Upvote'),
            ),
          ],
        ),
      ),
    );
  }
}
