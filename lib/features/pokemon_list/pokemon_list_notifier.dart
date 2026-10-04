import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon_summary.dart';
import '../../providers/providers.dart';

/// The loaded list and pagination status shown by the Pokédex grid.
class PokemonListState {
  const PokemonListState({
    required this.results,
    required this.count,
    required this.next,
    this.isLoadingMore = false,
    this.paginationError,
  });

  final List<PokemonSummary> results;
  final int count;
  final String? next;
  final bool isLoadingMore;
  final String? paginationError;

  PokemonListState copyWith({
    List<PokemonSummary>? results,
    int? count,
    String? next,
    bool clearNext = false,
    bool? isLoadingMore,
    String? paginationError,
    bool clearPaginationError = false,
  }) {
    return PokemonListState(
      results: results ?? this.results,
      count: count ?? this.count,
      next: clearNext ? null : next ?? this.next,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: clearPaginationError
          ? null
          : paginationError ?? this.paginationError,
    );
  }
}

/// Loads the first page and safely appends later pages.
class PokemonListNotifier extends AsyncNotifier<PokemonListState> {
  @override
  Future<PokemonListState> build() async {
    final response = await ref
        .read(pokemonRepositoryProvider)
        .getPokemonPage(offset: 0);
    return PokemonListState(
      results: response.results,
      count: response.count,
      next: response.next,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;
    if (current == null ||
        current.next == null ||
        current.isLoadingMore ||
        current.paginationError != null) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearPaginationError: true),
    );
    try {
      final page = await ref
          .read(pokemonRepositoryProvider)
          .getPokemonPage(offset: current.results.length);
      final latest = state.asData?.value ?? current;
      final knownIds = latest.results.map((pokemon) => pokemon.id).toSet();
      final uniqueResults = page.results
          .where((pokemon) => !knownIds.contains(pokemon.id))
          .toList(growable: false);
      state = AsyncData(
        latest.copyWith(
          results: [...latest.results, ...uniqueResults],
          count: page.count,
          next: page.next,
          clearNext: page.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      final latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          isLoadingMore: false,
          paginationError: error.toString(),
        ),
      );
    }
  }

  Future<void> retryNextPage() async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearPaginationError: true));
    await loadNextPage();
  }
}

final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, PokemonListState>(
      PokemonListNotifier.new,
    );

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final pokemonSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final pokemonSearchResultsProvider = Provider<List<PokemonSummary>>((ref) {
  final results =
      ref.watch(pokemonListProvider).asData?.value.results ?? const [];
  final query = ref.watch(pokemonSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return results;
  return results
      .where((pokemon) => pokemon.name.toLowerCase().contains(query))
      .toList(growable: false);
});
