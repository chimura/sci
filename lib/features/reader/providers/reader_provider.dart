import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReaderTool { none, highlight, note }

class ReaderState {
  final int currentPage;
  final int totalPages;
  final ReaderTool activeTool;
  final Color highlightColor;
  final bool showAnnotations;

  const ReaderState({
    this.currentPage = 0,
    this.totalPages = 0,
    this.activeTool = ReaderTool.none,
    this.highlightColor = const Color(0xFFFFFF00),
    this.showAnnotations = true,
  });

  ReaderState copyWith({
    int? currentPage,
    int? totalPages,
    ReaderTool? activeTool,
    Color? highlightColor,
    bool? showAnnotations,
  }) {
    return ReaderState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      activeTool: activeTool ?? this.activeTool,
      highlightColor: highlightColor ?? this.highlightColor,
      showAnnotations: showAnnotations ?? this.showAnnotations,
    );
  }
}

final readerStateProvider =
    NotifierProvider<ReaderNotifier, ReaderState>(ReaderNotifier.new);

class ReaderNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setTotalPages(int total) {
    state = state.copyWith(totalPages: total);
  }

  void setTool(ReaderTool tool) {
    // Toggle off if same tool selected
    if (state.activeTool == tool) {
      state = state.copyWith(activeTool: ReaderTool.none);
    } else {
      state = state.copyWith(activeTool: tool);
    }
  }

  void setHighlightColor(Color color) {
    state = state.copyWith(highlightColor: color);
  }

  void toggleAnnotations() {
    state = state.copyWith(showAnnotations: !state.showAnnotations);
  }

  void reset() {
    state = const ReaderState();
  }
}
