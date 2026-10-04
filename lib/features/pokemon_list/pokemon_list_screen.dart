import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/pokemon_summary.dart';
import '../favorites/favorites_notifier.dart';
import 'pokemon_list_notifier.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/search_bar.dart';

/// Main list tab with local loaded-list search and infinite pagination.
class PokemonListScreen extends ConsumerStatefulWidget {
  const PokemonListScreen({super.key});

  @override
  ConsumerState<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends ConsumerState<PokemonListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter <= 200) {
      unawaited(ref.read(pokemonListProvider.notifier).loadNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pokemonListProvider);
    final searchResults = ref.watch(pokemonSearchResultsProvider);
    ref.listen(favoritePersistenceErrorProvider, (previous, next) {
      if (next == null || next == previous || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      ref.read(favoritePersistenceErrorProvider.notifier).clear();
    });

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pokédex',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover and collect your favorites',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                const PokemonSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(pokemonListProvider),
              ),
              data: (state) {
                if (searchResults.isEmpty) {
                  return EmptyView(
                    title: 'No Pokémon found',
                    message: ref.watch(pokemonSearchQueryProvider).isEmpty
                        ? 'There are no Pokémon to display right now.'
                        : 'Try another name or clear your search.',
                  );
                }
                return _PokemonGrid(
                  controller: _scrollController,
                  pokemon: searchResults,
                  isLoadingMore: state.isLoadingMore,
                  paginationError: state.paginationError,
                  onRetry: () => unawaited(
                    ref.read(pokemonListProvider.notifier).retryNextPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonGrid extends StatelessWidget {
  const _PokemonGrid({
    required this.controller,
    required this.pokemon,
    required this.isLoadingMore,
    required this.paginationError,
    required this.onRetry,
  });

  final ScrollController controller;
  final List<PokemonSummary> pokemon;
  final bool isLoadingMore;
  final String? paginationError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final showFooter = isLoadingMore || paginationError != null;
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.91,
      ),
      itemCount: pokemon.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= pokemon.length) {
          return _PaginationFooter(
            isLoading: isLoadingMore,
            error: paginationError,
            onRetry: onRetry,
          );
        }
        return PokemonCard(pokemon: pokemon[index]);
      },
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Could not load more · Retry'),
      ),
    );
  }
}
