import '../datasources/favorites_local_storage.dart';
import '../models/pokemon_summary.dart';

/// Repository boundary for locally persisted favorites.
class FavoritesRepository {
  const FavoritesRepository(this._storage);

  final FavoritesLocalStorage _storage;

  Future<Map<int, FavoritePokemon>> loadFavorites() => _storage.loadFavorites();

  Future<void> saveFavorites(Map<int, FavoritePokemon> favorites) =>
      _storage.saveFavorites(favorites);
}
