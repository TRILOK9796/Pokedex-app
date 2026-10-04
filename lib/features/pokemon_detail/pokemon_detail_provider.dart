import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon_detail.dart';
import '../../providers/providers.dart';

final pokemonDetailProvider = FutureProvider.family<PokemonDetail, String>((
  ref,
  nameOrId,
) {
  return ref.watch(pokemonRepositoryProvider).getPokemon(nameOrId);
});
