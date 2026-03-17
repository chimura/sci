enum SortOption {
  dateAdded('Date added', 'date_added'),
  title('Title', 'title'),
  year('Year', 'year'),
  author('Author', 'family_name');

  final String label;
  final String dbColumn;
  const SortOption(this.label, this.dbColumn);
}

class LibraryFilter {
  final int? collectionId;
  final Set<String> tags;
  final String? yearFrom;
  final String? yearTo;
  final bool favoritesOnly;
  final SortOption sortBy;
  final bool sortDescending;

  const LibraryFilter({
    this.collectionId,
    this.tags = const {},
    this.yearFrom,
    this.yearTo,
    this.favoritesOnly = false,
    this.sortBy = SortOption.dateAdded,
    this.sortDescending = true,
  });

  LibraryFilter copyWith({
    int? collectionId,
    Set<String>? tags,
    String? yearFrom,
    String? yearTo,
    bool? favoritesOnly,
    SortOption? sortBy,
    bool? sortDescending,
  }) {
    return LibraryFilter(
      collectionId: collectionId ?? this.collectionId,
      tags: tags ?? this.tags,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  bool get isActive =>
      collectionId != null ||
      tags.isNotEmpty ||
      yearFrom != null ||
      yearTo != null ||
      favoritesOnly;

  LibraryFilter clearFilters() => LibraryFilter(
        sortBy: sortBy,
        sortDescending: sortDescending,
      );
}
