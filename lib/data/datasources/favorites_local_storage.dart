import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../models/pokemon_summary.dart';

/// JSON-backed persistence for the small favorites collection.
class FavoritesLocalStorage {
  FavoritesLocalStorage(this._preferences);

  static const _storageKey = 'favorite_pokemon';
  final SharedPreferences _preferences;

  Future<Map<int, FavoritePokemon>> loadFavorites() async {
    final encoded = _preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return const {};

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Favorites data must be a list.');
      }
      final favorites = decoded
          .whereType<Map<String, dynamic>>()
          .map(PokemonSummary.fromFavoriteJson)
          .toList(growable: false);
      return Map.unmodifiable({for (final item in favorites) item.id: item});
    } on FormatException {
      throw const AppException(
        'Saved favorites could not be read. Clear the app data and try again.',
      );
    }
  }

  Future<void> saveFavorites(Map<int, FavoritePokemon> favorites) async {
    final encoded = jsonEncode(
      favorites.values.map((pokemon) => pokemon.toFavoriteJson()).toList(),
    );
    final saved = await _preferences.setString(_storageKey, encoded);
    if (!saved) {
      throw const AppException('Favorites could not be saved on this device.');
    }
  }
}
