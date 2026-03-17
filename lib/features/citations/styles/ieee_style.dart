import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';

class IeeeStyle extends CitationStyle {
  @override
  String get name => 'IEEE';

  @override
  String get shortName => 'IEEE';

  @override
  String format(PaperModel paper) {
    final parts = <String>[];

    // Authors: F. M. Last, F. M. Last, and F. M. Last
    if (paper.authors.isNotEmpty) {
      final authorStrs = paper.authors.map((a) {
        final initials = a.givenName
                ?.split(RegExp(r'[\s-]+'))
                .map((n) => '${n[0]}.')
                .join(' ') ??
            '';
        return initials.isNotEmpty
            ? '$initials ${a.familyName}'
            : a.familyName;
      }).toList();

      if (authorStrs.length <= 3) {
        if (authorStrs.length == 1) {
          parts.add('${authorStrs.first},');
        } else {
          final allButLast = authorStrs.sublist(0, authorStrs.length - 1);
          parts.add('${allButLast.join(', ')}, and ${authorStrs.last},');
        }
      } else {
        parts.add('${authorStrs.first} et al.,');
      }
    }

    // Title in quotes
    parts.add('"${paper.title},"');

    // Journal
    if (paper.journal != null) {
      final journalPart = StringBuffer(paper.journal!);
      if (paper.volume != null) {
        journalPart.write(', vol. ${paper.volume}');
      }
      if (paper.issue != null) {
        journalPart.write(', no. ${paper.issue}');
      }
      if (paper.pages != null) {
        journalPart.write(', pp. ${paper.pages}');
      }
      if (paper.year != null) {
        journalPart.write(', ${paper.year}');
      }
      journalPart.write('.');
      parts.add(journalPart.toString());
    }

    if (paper.doi != null) {
      parts.add('doi: ${paper.doi}.');
    }

    return parts.join(' ');
  }
}
