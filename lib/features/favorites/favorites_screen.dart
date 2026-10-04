import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_view.dart';
import '../../data/models/pokemon_summary.dart';
import '../pokemon_list/widgets/pokemon_card.dart';
import 'favorites_notifier.dart';

/// Offline-first grid of the user's saved Pokémon.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    ref.listen(favoritePersistenceErrorProvider, (previous, next) {
      if (next == null || next == previous) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      ref.read(favoritePersistenceErrorProvider.notifier).clear();
    });

    final pokemon = favorites.values.toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${pokemon.length} Pokémon saved',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite_rounded, color: AppColors.primary),
              ],
            ),
          ),
          Expanded(
            child: pokemon.isEmpty
                ? const EmptyView(
                    title: 'No favorites yet',
                    message: 'Tap the heart on a Pokémon to save it here.',
                    icon: Icons.favorite_border_rounded,
                  )
                : _FavoritesGrid(pokemon: pokemon),
          ),
        ],
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.pokemon});

  final List<PokemonSummary> pokemon;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.91,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) => PokemonCard(pokemon: pokemon[index]),
    );
  }
}
