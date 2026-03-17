import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';

class MlaStyle extends CitationStyle {
  @override
  String get name => 'MLA 9th Edition';

  @override
  String get shortName => 'MLA';

  @override
  String format(PaperModel paper) {
    final parts = <String>[];

    // Authors: Last, First, and First Last.
    if (paper.authors.isNotEmpty) {
      if (paper.authors.length == 1) {
        final a = paper.authors.first;
        parts.add('${a.familyName}, ${a.givenName ?? ''}.');
      } else if (paper.authors.length == 2) {
        final a1 = paper.authors[0];
        final a2 = paper.authors[1];
        parts.add(
            '${a1.familyName}, ${a1.givenName ?? ''}, and ${a2.givenName ?? ''} ${a2.familyName}.');
      } else {
        final a1 = paper.authors.first;
        parts.add('${a1.familyName}, ${a1.givenName ?? ''}, et al.');
      }
    }

    // Title in quotes
    parts.add('"${paper.title}."');

    // Journal in italics (plain text)
    if (paper.journal != null) {
      final journalPart = StringBuffer(paper.journal!);
      if (paper.volume != null) {
        journalPart.write(', vol. ${paper.volume}');
      }
      if (paper.issue != null) {
        journalPart.write(', no. ${paper.issue}');
      }
      if (paper.year != null) {
        journalPart.write(', ${paper.year}');
      }
      if (paper.pages != null) {
        journalPart.write(', pp. ${paper.pages}');
      }
      journalPart.write('.');
      parts.add(journalPart.toString());
    }

    // DOI
    if (paper.doi != null) {
      parts.add('https://doi.org/${paper.doi}.');
    }

    return parts.join(' ');
  }
}
