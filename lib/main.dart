import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/favorites_local_storage.dart';
import 'data/repositories/favorites_repository.dart';
import 'providers/providers.dart';
import 'features/favorites/favorites_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  final preferences = await SharedPreferences.getInstance();
  final storage = FavoritesLocalStorage(preferences);
  final initialFavorites = await FavoritesRepository(storage).loadFavorites();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        favoritesProvider.overrideWith(
          () => FavoritesNotifier(initialFavorites),
        ),
      ],
      child: const PokedexApp(),
    ),
  );
}
