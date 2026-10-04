import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/pokemon_type_colors.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/pokemon_detail.dart';
import '../../data/models/pokemon_summary.dart';
import '../favorites/favorites_notifier.dart';
import 'pokemon_detail_provider.dart';
import 'widgets/stat_bar.dart';
import 'widgets/type_chip.dart';

/// Scrollable overview of a Pokémon and its battle statistics.
class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(pokemonDetailProvider('$pokemonId'));
    return detail.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(pokemonDetailProvider('$pokemonId')),
        ),
      ),
      data: (pokemon) => _DetailContent(pokemon: pokemon),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.pokemon});

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = pokemon.types.isEmpty
        ? AppColors.primary
        : PokemonTypeColors.forType(pokemon.types.first);
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (favorites) => favorites.containsKey(pokemon.id),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () async {
                  final favorite = PokemonSummary(
                    id: pokemon.id,
                    name: pokemon.name,
                    artworkUrl: pokemon.artworkUrl,
                  );
                  try {
                    await ref.read(favoritesProvider.notifier).toggle(favorite);
                  } catch (error) {
                    reportFavoriteError(ref, error);
                  }
                },
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(pokemon.displayName),
              background: Container(
                color: primaryColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 54,
                      right: -40,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 270,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: pokemon.artworkUrl,
                        height: 205,
                        fit: BoxFit.contain,
                        placeholder: (context, progress) => const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white,
                          size: 110,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: _DetailSections(
                pokemon: pokemon,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSections extends StatelessWidget {
  const _DetailSections({required this.pokemon, required this.primaryColor});

  final PokemonDetail pokemon;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '#${pokemon.id.toString().padLeft(3, '0')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            ...pokemon.types.map(
              (type) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TypeChip(type: type),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SectionCard(
          title: 'About',
          color: primaryColor,
          child: Row(
            children: [
              _Measurement(
                label: 'Height',
                value: '${(pokemon.height / 10).toStringAsFixed(1)} m',
              ),
              const _MeasurementDivider(),
              _Measurement(
                label: 'Weight',
                value: '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Abilities',
          color: primaryColor,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemon.abilities
                .map(
                  (ability) => Chip(
                    label: Text(
                      '${ability.displayName}${ability.isHidden ? ' · Hidden' : ''}',
                    ),
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Base stats',
          color: primaryColor,
          child: Column(
            children: _orderedStats(pokemon.stats)
                .map((stat) => StatBar(stat: stat, color: primaryColor))
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  List<PokemonStat> _orderedStats(List<PokemonStat> stats) {
    const order = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];
    return [...stats]
      ..sort((a, b) => order.indexOf(a.name).compareTo(order.indexOf(b.name)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.color,
    required this.child,
  });

  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Measurement extends StatelessWidget {
  const _Measurement({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MeasurementDivider extends StatelessWidget {
  const _MeasurementDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 42,
      child: VerticalDivider(color: AppColors.divider),
    );
  }
}
