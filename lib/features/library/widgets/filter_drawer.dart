import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/collection_dao.dart';
import '../models/library_filter.dart';
import '../providers/library_filter_provider.dart';

final collectionDaoProvider =
    Provider<CollectionDao>((ref) => CollectionDao());

final collectionsProvider = FutureProvider<List<CollectionRecord>>((ref) async {
  final dao = ref.read(collectionDaoProvider);
  return dao.getAll();
});

final allTagsProvider = FutureProvider<List<String>>((ref) async {
  final dao = ref.read(collectionDaoProvider);
  return dao.getAllTagNames();
});

class FilterDrawer extends ConsumerWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(libraryFilterProvider);
    final collectionsAsync = ref.watch(collectionsProvider);
    final tagsAsync = ref.watch(allTagsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Filters', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  if (filter.isActive)
                    TextButton(
                      onPressed: () =>
                          ref.read(libraryFilterProvider.notifier).clearAll(),
                      child: const Text('Clear all'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Favorites toggle
                  SwitchListTile(
                    title: const Text('Favorites only'),
                    secondary: const Icon(Icons.star),
                    value: filter.favoritesOnly,
                    onChanged: (_) => ref
                        .read(libraryFilterProvider.notifier)
                        .toggleFavorites(),
                  ),
                  const SizedBox(height: 16),

                  // Sort
                  Text('Sort by', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SortOption.values.map((option) {
                      final isSelected = filter.sortBy == option;
                      return ChoiceChip(
                        label: Text(option.label),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(libraryFilterProvider.notifier)
                            .setSortBy(option),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Direction:'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(filter.sortDescending
                            ? Icons.arrow_downward
                            : Icons.arrow_upward),
                        onPressed: () => ref
                            .read(libraryFilterProvider.notifier)
                            .toggleSortDirection(),
                      ),
                      Text(filter.sortDescending
                          ? 'Newest first'
                          : 'Oldest first'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Collections
                  Text('Collections', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  collectionsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (collections) {
                      if (collections.isEmpty) {
                        return Text(
                          'No collections yet',
                          style: theme.textTheme.bodySmall,
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: filter.collectionId == null,
                            onSelected: (_) => ref
                                .read(libraryFilterProvider.notifier)
                                .setCollection(null),
                          ),
                          ...collections.map((c) => ChoiceChip(
                                label: Text(c.name),
                                selected: filter.collectionId == c.id,
                                onSelected: (_) => ref
                                    .read(libraryFilterProvider.notifier)
                                    .setCollection(c.id),
                              )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Text('Tags', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  tagsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (tags) {
                      if (tags.isEmpty) {
                        return Text(
                          'No tags yet',
                          style: theme.textTheme.bodySmall,
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        children: tags
                            .map((tag) => FilterChip(
                                  label: Text(tag),
                                  selected: filter.tags.contains(tag),
                                  onSelected: (_) => ref
                                      .read(libraryFilterProvider.notifier)
                                      .toggleTag(tag),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
