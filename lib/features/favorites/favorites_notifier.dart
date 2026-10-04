import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon_summary.dart';
import '../../providers/providers.dart';

/// The single source of truth for favorites across all screens.
class FavoritesNotifier extends Notifier<Map<int, FavoritePokemon>> {
  FavoritesNotifier([this._initialFavorites = const {}]);

  final Map<int, FavoritePokemon> _initialFavorites;
  Future<void> _pendingWrite = Future<void>.value();

  @override
  Map<int, FavoritePokemon> build() => Map.unmodifiable(_initialFavorites);

  Future<void> toggle(FavoritePokemon pokemon) async {
    final updated = Map<int, FavoritePokemon>.of(state);
    if (updated.containsKey(pokemon.id)) {
      updated.remove(pokemon.id);
    } else {
      updated[pokemon.id] = pokemon;
    }
    final previous = state;
    final optimisticState = Map<int, FavoritePokemon>.unmodifiable(updated);
    state = optimisticState;
    final repository = ref.read(favoritesRepositoryProvider);
    final write = _pendingWrite.then(
      (_) => repository.saveFavorites(optimisticState),
    );
    _pendingWrite = write.catchError((Object _) {});
    try {
      await write;
    } catch (_) {
      if (identical(state, optimisticState)) state = previous;
      rethrow;
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<int, FavoritePokemon>>(
      FavoritesNotifier.new,
    );

/// Displays persistence failures without storing screen-specific favorite state.
void reportFavoriteError(WidgetRef ref, Object error) {
  ref.read(favoritePersistenceErrorProvider.notifier).show(error.toString());
}

final favoritePersistenceErrorProvider =
    NotifierProvider<FavoritePersistenceErrorNotifier, String?>(
      FavoritePersistenceErrorNotifier.new,
    );

class FavoritePersistenceErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;

  void clear() => state = null;
}
