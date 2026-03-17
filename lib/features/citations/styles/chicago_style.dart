import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';

class ChicagoStyle extends CitationStyle {
  @override
  String get name => 'Chicago 17th Edition';

  @override
  String get shortName => 'Chicago';

  @override
  String format(PaperModel paper) {
    final parts = <String>[];

    // Authors: Last, First, and First Last.
    if (paper.authors.isNotEmpty) {
      if (paper.authors.length == 1) {
        final a = paper.authors.first;
        parts.add('${a.familyName}, ${a.givenName ?? ''}.');
      } else if (paper.authors.length <= 3) {
        final strs = <String>[];
        for (var i = 0; i < paper.authors.length; i++) {
          final a = paper.authors[i];
          if (i == 0) {
            strs.add('${a.familyName}, ${a.givenName ?? ''}');
          } else {
            strs.add('${a.givenName ?? ''} ${a.familyName}');
          }
        }
        if (strs.length == 2) {
          parts.add('${strs[0]}, and ${strs[1]}.');
        } else {
          parts.add('${strs[0]}, ${strs[1]}, and ${strs[2]}.');
        }
      } else {
        final a1 = paper.authors.first;
        parts.add('${a1.familyName}, ${a1.givenName ?? ''}, et al.');
      }
    }

    // Title in quotes
    parts.add('"${paper.title}."');

    // Journal
    if (paper.journal != null) {
      final journalPart = StringBuffer(paper.journal!);
      if (paper.volume != null) {
        journalPart.write(' ${paper.volume}');
        if (paper.issue != null) {
          journalPart.write(', no. ${paper.issue}');
        }
      }
      if (paper.year != null) {
        journalPart.write(' (${paper.year})');
      }
      if (paper.pages != null) {
        journalPart.write(': ${paper.pages}');
      }
      journalPart.write('.');
      parts.add(journalPart.toString());
    }

    if (paper.doi != null) {
      parts.add('https://doi.org/${paper.doi}.');
    }

    return parts.join(' ');
  }
}
