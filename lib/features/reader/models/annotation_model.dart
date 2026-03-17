import 'dart:ui';

import '../../../core/database/daos/annotation_dao.dart';

enum AnnotationType { highlight, note, underline }

class AnnotationModel {
  final int? id;
  final int paperId;
  final int page;
  final double x;
  final double y;
  final double? width;
  final double? height;
  final String content;
  final AnnotationType type;
  final Color color;
  final String? selectedText;
  final DateTime createdAt;

  // Highlight rects — multiple rects for multi-line selections
  final List<HighlightRect> highlightRects;

  const AnnotationModel({
    this.id,
    required this.paperId,
    required this.page,
    required this.x,
    required this.y,
    this.width,
    this.height,
    required this.content,
    required this.type,
    this.color = const Color(0xFFFFFF00),
    this.selectedText,
    required this.createdAt,
    this.highlightRects = const [],
  });

  AnnotationModel copyWith({
    int? id,
    String? content,
    Color? color,
    List<HighlightRect>? highlightRects,
  }) {
    return AnnotationModel(
      id: id ?? this.id,
      paperId: paperId,
      page: page,
      x: x,
      y: y,
      width: width,
      height: height,
      content: content ?? this.content,
      type: type,
      color: color ?? this.color,
      selectedText: selectedText,
      createdAt: createdAt,
      highlightRects: highlightRects ?? this.highlightRects,
    );
  }

  AnnotationRecord toRecord() {
    return AnnotationRecord(
      id: id,
      paperId: paperId,
      page: page,
      x: x,
      y: y,
      width: width,
      height: height,
      content: content,
      type: type.name,
      color: '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
      selectedText: selectedText,
      createdAt: createdAt,
    );
  }

  static AnnotationModel fromRecord(AnnotationRecord record) {
    return AnnotationModel(
      id: record.id,
      paperId: record.paperId,
      page: record.page,
      x: record.x,
      y: record.y,
      width: record.width,
      height: record.height,
      content: record.content,
      type: AnnotationType.values.firstWhere(
        (t) => t.name == record.type,
        orElse: () => AnnotationType.note,
      ),
      color: _parseColor(record.color),
      selectedText: record.selectedText,
      createdAt: record.createdAt,
    );
  }

  static Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return Color(int.parse(cleaned, radix: 16));
  }
}

class HighlightRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const HighlightRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
