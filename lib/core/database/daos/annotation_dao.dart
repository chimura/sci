import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class AnnotationRecord {
  final int? id;
  final int paperId;
  final int page;
  final double x;
  final double y;
  final double? width;
  final double? height;
  final String content;
  final String type; // 'highlight', 'note', 'underline'
  final String color;
  final String? selectedText;
  final DateTime createdAt;

  const AnnotationRecord({
    this.id,
    required this.paperId,
    required this.page,
    required this.x,
    required this.y,
    this.width,
    this.height,
    required this.content,
    required this.type,
    this.color = '#FFFF00',
    this.selectedText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'paper_id': paperId,
      'page': page,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'content': content,
      'type': type,
      'color': color,
      'selected_text': selectedText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static AnnotationRecord fromMap(Map<String, dynamic> map) {
    return AnnotationRecord(
      id: map['id'] as int?,
      paperId: map['paper_id'] as int,
      page: map['page'] as int,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      content: map['content'] as String,
      type: map['type'] as String,
      color: map['color'] as String? ?? '#FFFF00',
      selectedText: map['selected_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class AnnotationDao {
  final AppDatabase _appDatabase;

  AnnotationDao({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<int> insert(AnnotationRecord annotation) async {
    final db = await _db;
    return db.insert('annotations', annotation.toMap());
  }

  Future<List<AnnotationRecord>> getForPaper(int paperId) async {
    final db = await _db;
    final rows = await db.query(
      'annotations',
      where: 'paper_id = ?',
      whereArgs: [paperId],
      orderBy: 'page ASC, y ASC',
    );
    return rows.map(AnnotationRecord.fromMap).toList();
  }

  Future<List<AnnotationRecord>> getForPage(int paperId, int page) async {
    final db = await _db;
    final rows = await db.query(
      'annotations',
      where: 'paper_id = ? AND page = ?',
      whereArgs: [paperId, page],
      orderBy: 'y ASC',
    );
    return rows.map(AnnotationRecord.fromMap).toList();
  }

  Future<int> update(AnnotationRecord annotation) async {
    final db = await _db;
    return db.update(
      'annotations',
      annotation.toMap(),
      where: 'id = ?',
      whereArgs: [annotation.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('annotations', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllForPaper(int paperId) async {
    final db = await _db;
    return db.delete('annotations', where: 'paper_id = ?', whereArgs: [paperId]);
  }
}
