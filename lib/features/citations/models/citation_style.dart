import '../../../core/models/paper_model.dart';

abstract class CitationStyle {
  String get name;
  String get shortName;
  String format(PaperModel paper);
}
