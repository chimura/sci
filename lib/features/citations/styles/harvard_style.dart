import '../../../core/models/paper_model.dart';
import '../models/citation_style.dart';

class HarvardStyle extends CitationStyle {
  @override
  String get name => 'Harvard';

  @override
  String get shortName => 'Harvard';

  @override
  String format(PaperModel paper) {
    final parts = <String>[];

    // Authors: Last, F.M. and Last, F.M.
    if (paper.authors.isNotEmpty) {
      final authorStrs = paper.authors.map((a) {
        final initials = a.givenName
                ?.split(RegExp(r'[\s-]+'))
                .map((n) => '${n[0]}.')
                .join('') ??
            '';
        return '${a.familyName}, $initials'.trimRight();
      }).toList();

      if (authorStrs.length == 1) {
        parts.add(authorStrs.first);
      } else if (authorStrs.length <= 3) {
        final allButLast = authorStrs.sublist(0, authorStrs.length - 1);
        parts.add('${allButLast.join(', ')} and ${authorStrs.last}');
      } else {
        parts.add('${authorStrs.first} et al.');
      }
    }

    // Year
    parts.add('(${paper.year ?? 'n.d.'})');

    // Title
    parts.add("'${paper.title}',");

    // Journal
    if (paper.journal != null) {
      final journalPart = StringBuffer(paper.journal!);
      if (paper.volume != null) {
        journalPart.write(', ${paper.volume}');
        if (paper.issue != null) {
          journalPart.write('(${paper.issue})');
        }
      }
      if (paper.pages != null) {
        journalPart.write(', pp. ${paper.pages}');
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
