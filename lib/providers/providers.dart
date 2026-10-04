import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../data/datasources/favorites_local_storage.dart';
import '../data/datasources/pokemon_api_client.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/pokemon_repository.dart';

/// SharedPreferences instance loaded before the app starts.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.',
  ),
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final pokemonApiClientProvider = Provider<PokemonApiClient>(
  (ref) => PokemonApiClient(ref.watch(dioProvider)),
);

final pokemonRepositoryProvider = Provider<PokemonRepository>(
  (ref) => PokemonRepository(ref.watch(pokemonApiClientProvider)),
);

final favoritesLocalStorageProvider = Provider<FavoritesLocalStorage>(
  (ref) => FavoritesLocalStorage(ref.watch(sharedPreferencesProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(favoritesLocalStorageProvider)),
);
