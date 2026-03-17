import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';

class ApaStyle extends CitationStyle {
  @override
  String get name => 'APA 7th Edition';

  @override
  String get shortName => 'APA';

  @override
  String format(PaperModel paper) {
    final parts = <String>[];

    // Authors: Last, F. M., & Last, F. M.
    if (paper.authors.isNotEmpty) {
      final authorStrs = paper.authors.map((a) {
        final initials = a.givenName
                ?.split(RegExp(r'[\s-]+'))
                .map((n) => '${n[0]}.')
                .join(' ') ??
            '';
        return initials.isNotEmpty
            ? '${a.familyName}, $initials'
            : a.familyName;
      }).toList();

      if (authorStrs.length == 1) {
        parts.add(authorStrs.first);
      } else if (authorStrs.length == 2) {
        parts.add('${authorStrs[0]}, & ${authorStrs[1]}');
      } else if (authorStrs.length <= 20) {
        final allButLast = authorStrs.sublist(0, authorStrs.length - 1);
        parts.add('${allButLast.join(', ')}, & ${authorStrs.last}');
      } else {
        final first19 = authorStrs.sublist(0, 19);
        parts.add('${first19.join(', ')}, ... ${authorStrs.last}');
      }
    }

    // Year
    if (paper.year != null) {
      parts.add('(${paper.year})');
    } else {
      parts.add('(n.d.)');
    }

    // Title (not italicized in plain text)
    parts.add('${paper.title}.');

    // Journal (italicized conceptually)
    if (paper.journal != null) {
      final journalPart = StringBuffer(paper.journal!);
      if (paper.volume != null) {
        journalPart.write(', ${paper.volume}');
        if (paper.issue != null) {
          journalPart.write('(${paper.issue})');
        }
      }
      if (paper.pages != null) {
        journalPart.write(', ${paper.pages}');
      }
      journalPart.write('.');
      parts.add(journalPart.toString());
    }

    // DOI
    if (paper.doi != null) {
      parts.add('https://doi.org/${paper.doi}');
    }

    return parts.join(' ');
  }
}
