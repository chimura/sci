import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/paper_model.dart';
import '../services/crossref_service.dart';

final crossRefServiceProvider = Provider<CrossRefService>(
  (ref) => CrossRefService(),
);

enum ImportStatus { idle, loading, success, error }

class DoiImportState {
  final ImportStatus status;
  final PaperModel? paper;
  final String? error;

  const DoiImportState({
    this.status = ImportStatus.idle,
    this.paper,
    this.error,
  });

  DoiImportState copyWith({
    ImportStatus? status,
    PaperModel? paper,
    String? error,
  }) {
    return DoiImportState(
      status: status ?? this.status,
      paper: paper ?? this.paper,
      error: error ?? this.error,
    );
  }
}

final doiImportProvider =
    NotifierProvider<DoiImportNotifier, DoiImportState>(
  DoiImportNotifier.new,
);

class DoiImportNotifier extends Notifier<DoiImportState> {
  @override
  DoiImportState build() => const DoiImportState();

  Future<void> lookupDoi(String doi) async {
    state = const DoiImportState(status: ImportStatus.loading);

    try {
      final crossRef = ref.read(crossRefServiceProvider);
      final paper = await crossRef.fetchByDoi(doi);

      if (paper != null) {
        state = DoiImportState(status: ImportStatus.success, paper: paper);
      } else {
        state = const DoiImportState(
          status: ImportStatus.error,
          error: 'Paper not found for this DOI',
        );
      }
    } catch (e) {
      state = DoiImportState(
        status: ImportStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const DoiImportState();
  }
}
