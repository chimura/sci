import '../../../core/models/paper_model.dart';
import 'crossref_service.dart';

class MetadataExtractor {
  final CrossRefService _crossRef;

  MetadataExtractor({CrossRefService? crossRef})
      : _crossRef = crossRef ?? CrossRefService();

  /// Try to extract metadata from a DOI string.
  Future<PaperModel?> fromDoi(String doi) async {
    return _crossRef.fetchByDoi(doi);
  }

  /// Try to extract a DOI from a filename and look it up.
  Future<PaperModel?> fromFilename(String filename) async {
    final doi = _extractDoiFromFilename(filename);
    if (doi != null) {
      return _crossRef.fetchByDoi(doi);
    }
    return null;
  }

  String? _extractDoiFromFilename(String filename) {
    // Common DOI pattern: 10.xxxx/xxxxx
    final doiPattern = RegExp(r'10\.\d{4,}/[^\s]+');
    final match = doiPattern.firstMatch(filename);
    return match?.group(0);
  }
}
