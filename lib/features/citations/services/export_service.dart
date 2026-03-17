import '../../../core/models/paper_model.dart';

class ExportService {
  /// Export a single paper as BibTeX
  String toBibtex(PaperModel paper) {
    final key = _generateBibtexKey(paper);
    final buf = StringBuffer('@article{$key,\n');

    buf.writeln('  title = {${paper.title}},');

    if (paper.authors.isNotEmpty) {
      final authors =
          paper.authors.map((a) => '${a.familyName}, ${a.givenName ?? ''}').join(' and ');
      buf.writeln('  author = {$authors},');
    }

    if (paper.journal != null) buf.writeln('  journal = {${paper.journal}},');
    if (paper.year != null) buf.writeln('  year = {${paper.year}},');
    if (paper.volume != null) buf.writeln('  volume = {${paper.volume}},');
    if (paper.issue != null) buf.writeln('  number = {${paper.issue}},');
    if (paper.pages != null) buf.writeln('  pages = {${paper.pages}},');
    if (paper.doi != null) buf.writeln('  doi = {${paper.doi}},');
    if (paper.abstract_ != null) buf.writeln('  abstract = {${paper.abstract_}},');

    buf.write('}');
    return buf.toString();
  }

  /// Export a single paper as RIS
  String toRis(PaperModel paper) {
    final buf = StringBuffer();
    buf.writeln('TY  - JOUR');
    buf.writeln('TI  - ${paper.title}');

    for (final author in paper.authors) {
      buf.writeln('AU  - ${author.familyName}, ${author.givenName ?? ''}');
    }

    if (paper.journal != null) buf.writeln('JO  - ${paper.journal}');
    if (paper.year != null) buf.writeln('PY  - ${paper.year}');
    if (paper.volume != null) buf.writeln('VL  - ${paper.volume}');
    if (paper.issue != null) buf.writeln('IS  - ${paper.issue}');
    if (paper.pages != null) {
      final pageParts = paper.pages!.split('-');
      buf.writeln('SP  - ${pageParts.first.trim()}');
      if (pageParts.length > 1) buf.writeln('EP  - ${pageParts.last.trim()}');
    }
    if (paper.doi != null) buf.writeln('DO  - ${paper.doi}');
    if (paper.abstract_ != null) buf.writeln('AB  - ${paper.abstract_}');

    buf.writeln('ER  - ');
    return buf.toString();
  }

  /// Export multiple papers as BibTeX
  String toBibtexMultiple(List<PaperModel> papers) {
    return papers.map(toBibtex).join('\n\n');
  }

  /// Export multiple papers as RIS
  String toRisMultiple(List<PaperModel> papers) {
    return papers.map(toRis).join('\n');
  }

  String _generateBibtexKey(PaperModel paper) {
    final firstAuthor =
        paper.authors.isNotEmpty ? paper.authors.first.familyName : 'unknown';
    final year = paper.year ?? 'nd';
    final titleWord = paper.title.split(' ').first.toLowerCase();
    return '${firstAuthor.toLowerCase()}$year$titleWord';
  }
}
