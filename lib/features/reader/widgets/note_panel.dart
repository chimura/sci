import 'package:flutter/material.dart';

import '../models/annotation_model.dart';

/// Bottom sheet for viewing/editing a note annotation.
class NotePanel extends StatefulWidget {
  final AnnotationModel? annotation;
  final void Function(String content) onSave;
  final VoidCallback? onDelete;

  const NotePanel({
    super.key,
    this.annotation,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NotePanel> createState() => _NotePanelState();
}

class _NotePanelState extends State<NotePanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.annotation?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExisting = widget.annotation?.id != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                isExisting ? 'Edit Note' : 'Add Note',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              if (isExisting && widget.onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: () {
                    widget.onDelete!();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Show selected text if this is a highlight with a note
          if (widget.annotation?.selectedText != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.annotation!.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.annotation!.color.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '"${widget.annotation!.selectedText!}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Write your note...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                widget.onSave(text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
