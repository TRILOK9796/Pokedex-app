import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../pokemon_list_notifier.dart';

/// Search input scoped to Pokémon already loaded into the list.
class PokemonSearchBar extends ConsumerStatefulWidget {
  const PokemonSearchBar({super.key});

  @override
  ConsumerState<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends ConsumerState<PokemonSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(pokemonSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final query = ref.watch(pokemonSearchQueryProvider);
    return TextField(
      controller: _controller,
      onChanged: ref.read(pokemonSearchQueryProvider.notifier).update,
      decoration: InputDecoration(
        hintText: 'Search Pokémon',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _controller.clear();
                  ref.read(pokemonSearchQueryProvider.notifier).update('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}
