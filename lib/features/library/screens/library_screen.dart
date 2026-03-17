import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/paper_model.dart';
import '../../../core/router/app_router.dart';
import '../../import/screens/import_screen.dart';
import '../models/library_filter.dart';
import '../providers/library_filter_provider.dart';
import '../providers/library_provider.dart';
import '../providers/library_search_provider.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/paper_grid_tile.dart';
import '../widgets/paper_list_tile.dart';
import 'paper_detail_screen.dart';

/// Provider to track selected paper for master-detail on wide screens.
final selectedPaperProvider =
    NotifierProvider<SelectedPaperNotifier, PaperModel?>(
  SelectedPaperNotifier.new,
);

class SelectedPaperNotifier extends Notifier<PaperModel?> {
  @override
  PaperModel? build() => null;

  void select(PaperModel? paper) => state = paper;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryState = ref.watch(libraryProvider);
    final filter = ref.watch(libraryFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final selectedPaper = ref.watch(selectedPaperProvider);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): _toggleSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _toggleSearch,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            _openImport(context),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            _openImport(context),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_isSearching) _toggleSearch();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search papers...',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (value) =>
                        ref.read(searchQueryProvider.notifier).update(value),
                  )
                : const Text('Library'),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                tooltip: _isSearching ? 'Close search' : 'Search (Ctrl+F)',
                onPressed: _toggleSearch,
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: Badge(
                    isLabelVisible: filter.isActive,
                    child: const Icon(Icons.filter_list),
                  ),
                  tooltip: 'Filters',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          endDrawer: const FilterDrawer(),
          body: _isSearching && searchQuery.isNotEmpty
              ? _buildSearchResults(theme, searchResults, isWide)
              : isWide
                  ? _buildWideLayout(theme, libraryState, filter, selectedPaper)
                  : _buildNarrowLayout(theme, libraryState, filter),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openImport(context),
            tooltip: 'Import paper (Ctrl+N)',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _openImport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImportScreen()),
    );
  }

  // ── Wide layout: master-detail ──

  Widget _buildWideLayout(
    ThemeData theme,
    AsyncValue<dynamic> libraryState,
    LibraryFilter filter,
    PaperModel? selectedPaper,
  ) {
    return Row(
      children: [
        // Master: paper list
        SizedBox(
          width: 380,
          child: _buildNarrowLayout(theme, libraryState, filter,
              selectedPaperId: selectedPaper?.id),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // Detail: paper detail
        Expanded(
          child: selectedPaper != null
              ? PaperDetailScreen(paper: selectedPaper)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Select a paper to view details',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ── Narrow layout: simple list ──

  Widget _buildNarrowLayout(
    ThemeData theme,
    AsyncValue<dynamic> libraryState,
    LibraryFilter filter, {
    int? selectedPaperId,
  }) {
    return libraryState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Error loading library',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(error.toString(), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(libraryProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (allPapers) {
        var papers = _applyFilters(allPapers, filter);

        if (papers.isEmpty) {
          return _buildEmptyState(theme, filter);
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
          child: ListView.separated(
            itemCount: papers.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final paper = papers[index];
              final isSelected = selectedPaperId != null &&
                  paper.id == selectedPaperId;

              return Container(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: PaperListTile(
                  paper: paper,
                  onTap: () => _onPaperTap(context, paper),
                  onFavoriteToggle: () {
                    if (paper.id != null) {
                      ref
                          .read(libraryProvider.notifier)
                          .toggleFavorite(paper.id!, !paper.isFavorite);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Search results ──

  Widget _buildSearchResults(
    ThemeData theme,
    AsyncValue<List<dynamic>> searchResults,
    bool isWide,
  ) {
    return searchResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Search error: $e')),
      data: (papers) {
        if (papers.isEmpty) {
          return Center(
            child: Text('No results found', style: theme.textTheme.bodyLarge),
          );
        }

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 200,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return PaperGridTile(
                paper: paper,
                onTap: () => _onPaperTap(context, paper),
              );
            },
          );
        }

        return ListView.separated(
          itemCount: papers.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final paper = papers[index];
            return PaperListTile(
              paper: paper,
              onTap: () => _onPaperTap(context, paper),
            );
          },
        );
      },
    );
  }

  // ── Helpers ──

  void _onPaperTap(BuildContext context, PaperModel paper) {
    final isWide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    if (isWide) {
      ref.read(selectedPaperProvider.notifier).select(paper);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaperDetailScreen(paper: paper)),
      );
    }
  }

  Widget _buildEmptyState(ThemeData theme, LibraryFilter filter) {
    if (filter.isActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No papers match filters',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(libraryFilterProvider.notifier).clearAll(),
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color:
                theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No papers yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import papers by DOI, PDF, or BibTeX',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> papers, LibraryFilter filter) {
    var result = papers.toList();

    if (filter.favoritesOnly) {
      result = result.where((p) => p.isFavorite).toList();
    }

    if (filter.tags.isNotEmpty) {
      result = result
          .where((p) => p.tags.any((t) => filter.tags.contains(t)))
          .toList();
    }

    if (filter.yearFrom != null) {
      result = result
          .where((p) =>
              p.year != null && p.year!.compareTo(filter.yearFrom!) >= 0)
          .toList();
    }

    if (filter.yearTo != null) {
      result = result
          .where((p) =>
              p.year != null && p.year!.compareTo(filter.yearTo!) <= 0)
          .toList();
    }

    result.sort((a, b) {
      int cmp;
      switch (filter.sortBy) {
        case SortOption.title:
          cmp = a.title.compareTo(b.title);
        case SortOption.year:
          cmp = (a.year ?? '').compareTo(b.year ?? '');
        case SortOption.author:
          cmp = a.authorsFormatted.compareTo(b.authorsFormatted);
        case SortOption.dateAdded:
          cmp = a.dateAdded.compareTo(b.dateAdded);
      }
      return filter.sortDescending ? -cmp : cmp;
    });

    return result;
  }
}
