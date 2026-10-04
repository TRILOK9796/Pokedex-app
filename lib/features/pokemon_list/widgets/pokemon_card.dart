import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/pokemon_summary.dart';
import '../../favorites/favorites_notifier.dart';
import '../../pokemon_detail/pokemon_detail_screen.dart';

/// Reusable Pokémon card with a selector-backed favorite button.
class PokemonCard extends ConsumerWidget {
  const PokemonCard({required this.pokemon, super.key});

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (favorites) => favorites.containsKey(pokemon.id),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PokemonDetailScreen(pokemonId: pokemon.id),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.artworkUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, progress) => const LoadingView(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.catching_pokemon,
                        size: 52,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          pokemon.formattedId,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () async {
                  try {
                    await ref.read(favoritesProvider.notifier).toggle(pokemon);
                  } catch (error) {
                    reportFavoriteError(ref, error);
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
