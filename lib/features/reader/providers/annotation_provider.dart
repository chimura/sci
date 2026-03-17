import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/annotation_dao.dart';
import '../models/annotation_model.dart';

final annotationDaoProvider = Provider<AnnotationDao>((ref) => AnnotationDao());

/// Provider family keyed by paperId — returns annotations for a specific paper.
final annotationsProvider = FutureProvider.family<List<AnnotationModel>, int>(
  (ref, paperId) async {
    final dao = ref.read(annotationDaoProvider);
    final records = await dao.getForPaper(paperId);
    return records.map(AnnotationModel.fromRecord).toList();
  },
);

/// Notifier for mutating annotations — takes paperId on construction.
final annotationActionsProvider =
    Provider<AnnotationActions>((ref) => AnnotationActions(ref));

class AnnotationActions {
  final Ref _ref;

  AnnotationActions(this._ref);

  Future<void> addHighlight({
    required int paperId,
    required int page,
    required double x,
    required double y,
    required double width,
    required double height,
    required String selectedText,
    required Color color,
  }) async {
    final dao = _ref.read(annotationDaoProvider);
    final record = AnnotationRecord(
      paperId: paperId,
      page: page,
      x: x,
      y: y,
      width: width,
      height: height,
      content: '',
      type: 'highlight',
      color: '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
      selectedText: selectedText,
      createdAt: DateTime.now(),
    );
    await dao.insert(record);
    _ref.invalidate(annotationsProvider(paperId));
  }

  Future<void> addNote({
    required int paperId,
    required int page,
    required double x,
    required double y,
    required String content,
  }) async {
    final dao = _ref.read(annotationDaoProvider);
    final record = AnnotationRecord(
      paperId: paperId,
      page: page,
      x: x,
      y: y,
      content: content,
      type: 'note',
      createdAt: DateTime.now(),
    );
    await dao.insert(record);
    _ref.invalidate(annotationsProvider(paperId));
  }

  Future<void> updateAnnotation(AnnotationModel annotation) async {
    final dao = _ref.read(annotationDaoProvider);
    await dao.update(annotation.toRecord());
    _ref.invalidate(annotationsProvider(annotation.paperId));
  }

  Future<void> deleteAnnotation(int paperId, int annotationId) async {
    final dao = _ref.read(annotationDaoProvider);
    await dao.delete(annotationId);
    _ref.invalidate(annotationsProvider(paperId));
  }
}
