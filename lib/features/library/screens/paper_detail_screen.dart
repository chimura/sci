import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/paper_model.dart';
import '../../citations/screens/citation_screen.dart';
import '../../reader/screens/reader_screen.dart';
import '../providers/library_provider.dart';

class PaperDetailScreen extends ConsumerWidget {
  final PaperModel paper;

  const PaperDetailScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Details'),
        actions: [
          IconButton(
            icon: Icon(
              paper.isFavorite ? Icons.star : Icons.star_border,
              color: paper.isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              if (paper.id != null) {
                ref
                    .read(libraryProvider.notifier)
                    .toggleFavorite(paper.id!, !paper.isFavorite);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (context) => [
              if (paper.localPdfPath != null)
                const PopupMenuItem(
                  value: 'open_pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Open PDF'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (paper.doi != null)
                const PopupMenuItem(
                  value: 'copy_doi',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Copy DOI'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'cite',
                child: ListTile(
                  leading: Icon(Icons.format_quote),
                  title: Text('Cite & Export'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          Text(
            paper.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Authors
          if (paper.authors.isNotEmpty) ...[
            Text(
              paper.authors.map((a) => a.displayName).join(', '),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Metadata chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (paper.year != null) _chip(theme, Icons.calendar_today, paper.year!),
              if (paper.journal != null) _chip(theme, Icons.book, paper.journal!),
              if (paper.volume != null)
                _chip(theme, Icons.layers, 'Vol. ${paper.volume}'),
              if (paper.issue != null)
                _chip(theme, Icons.tag, 'Issue ${paper.issue}'),
              if (paper.pages != null) _chip(theme, Icons.description, paper.pages!),
              if (paper.localPdfPath != null)
                _chip(theme, Icons.picture_as_pdf, 'PDF available'),
            ],
          ),
          const SizedBox(height: 8),

          // DOI
          if (paper.doi != null) ...[
            InkWell(
              onTap: () => _openDoi(paper.doi!),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'DOI: ${paper.doi}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],

          // Tags
          if (paper.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: paper.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],

          // Abstract
          if (paper.abstract_ != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text('Abstract', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              paper.abstract_!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],

          // Publisher
          if (paper.publisher != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Publisher: ${paper.publisher}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: paper.localPdfPath != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(paper: paper),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Read'),
            )
          : null,
    );
  }

  Widget _chip(ThemeData theme, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'open_pdf':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReaderScreen(paper: paper)),
        );
      case 'cite':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CitationScreen(paper: paper)),
        );
      case 'copy_doi':
        if (paper.doi != null) {
          Clipboard.setData(ClipboardData(text: paper.doi!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DOI copied to clipboard')),
          );
        }
      case 'delete':
        _confirmDelete(context, ref);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete paper?'),
        content: const Text('This will remove the paper from your library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (paper.id != null) {
                ref.read(libraryProvider.notifier).deletePaper(paper.id!);
              }
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to library
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDoi(String doi) async {
    final uri = Uri.parse('https://doi.org/$doi');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
