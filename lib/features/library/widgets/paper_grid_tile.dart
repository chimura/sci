import 'package:flutter/material.dart';

import '../../../core/models/paper_model.dart';

class PaperGridTile extends StatelessWidget {
  final PaperModel paper;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isSelected;

  const PaperGridTile({
    super.key,
    required this.paper,
    this.onTap,
    this.onFavoriteToggle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with PDF icon and favorite
              Row(
                children: [
                  Icon(
                    paper.localPdfPath != null
                        ? Icons.picture_as_pdf
                        : Icons.article_outlined,
                    size: 20,
                    color: paper.localPdfPath != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  if (onFavoriteToggle != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onFavoriteToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          paper.isFavorite ? Icons.star : Icons.star_border,
                          size: 20,
                          color: paper.isFavorite ? Colors.amber : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                paper.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),

              // Authors
              Text(
                paper.authorsFormatted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),

              // Bottom metadata
              Row(
                children: [
                  if (paper.year != null)
                    Text(
                      paper.year!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (paper.journal != null) ...[
                    const SizedBox(width: 6),
                    Text('·',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        paper.journal!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
