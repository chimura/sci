import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';
import '../services/export_service.dart';
import '../styles/apa_style.dart';
import '../styles/chicago_style.dart';
import '../styles/harvard_style.dart';
import '../styles/ieee_style.dart';
import '../styles/mla_style.dart';

class CitationScreen extends StatefulWidget {
  final PaperModel paper;

  const CitationScreen({super.key, required this.paper});

  @override
  State<CitationScreen> createState() => _CitationScreenState();
}

class _CitationScreenState extends State<CitationScreen> {
  final _styles = <CitationStyle>[
    ApaStyle(),
    MlaStyle(),
    ChicagoStyle(),
    IeeeStyle(),
    HarvardStyle(),
  ];

  final _exportService = ExportService();
  int _selectedStyleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedStyle = _styles[_selectedStyleIndex];
    final citation = selectedStyle.format(widget.paper);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cite & Export'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Style selector
          Text('Citation Style', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_styles.length, (index) {
              final style = _styles[index];
              return ChoiceChip(
                label: Text(style.shortName),
                selected: _selectedStyleIndex == index,
                onSelected: (_) => setState(() => _selectedStyleIndex = index),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Citation preview
          Text('Formatted Citation', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SelectableText(
              citation,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _copyToClipboard(context, citation),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Citation'),
          ),

          const SizedBox(height: 32),

          // Export options
          Text('Export', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _ExportTile(
            icon: Icons.code,
            title: 'BibTeX',
            subtitle: '.bib format',
            onCopy: () => _copyToClipboard(
              context,
              _exportService.toBibtex(widget.paper),
            ),
          ),
          const SizedBox(height: 8),
          _ExportTile(
            icon: Icons.description,
            title: 'RIS',
            subtitle: '.ris format (EndNote, Zotero)',
            onCopy: () => _copyToClipboard(
              context,
              _exportService.toRis(widget.paper),
            ),
          ),

          const SizedBox(height: 32),

          // Preview BibTeX
          Text('BibTeX Preview', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SelectableText(
              _exportService.toBibtex(widget.paper),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCopy;

  const _ExportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy $title',
          onPressed: onCopy,
        ),
      ),
    );
  }
}
