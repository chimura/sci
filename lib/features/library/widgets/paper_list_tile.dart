import 'package:flutter/material.dart';

import '../../../core/models/paper_model.dart';

class PaperListTile extends StatelessWidget {
  final PaperModel paper;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const PaperListTile({
    super.key,
    required this.paper,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        paper.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            paper.authorsFormatted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          _buildMetaRow(theme),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          paper.isFavorite ? Icons.star : Icons.star_border,
          color: paper.isFavorite ? Colors.amber : null,
        ),
        onPressed: onFavoriteToggle,
      ),
      leading: paper.localPdfPath != null
          ? Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary)
          : Icon(Icons.article_outlined,
              color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _buildMetaRow(ThemeData theme) {
    final parts = <String>[];
    if (paper.year != null) parts.add(paper.year!);
    if (paper.journal != null) parts.add(paper.journal!);

    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    );
  }
}
