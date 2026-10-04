import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/data/models/pokemon_summary.dart';
import 'package:pokedex_app/features/favorites/favorites_notifier.dart';
import 'package:pokedex_app/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
  });

  tearDown(() => container.dispose());

  test(
    'updates favorites immediately and persists the latest rapid toggle',
    () async {
      const pokemon = PokemonSummary(
        id: 25,
        name: 'pikachu',
        artworkUrl: 'https://example.test/25.png',
      );
      final notifier = container.read(favoritesProvider.notifier);

      final add = notifier.toggle(pokemon);
      expect(container.read(favoritesProvider), contains(pokemon.id));

      final remove = notifier.toggle(pokemon);
      expect(container.read(favoritesProvider), isNot(contains(pokemon.id)));
      await Future.wait([add, remove]);

      final persisted = await container
          .read(favoritesRepositoryProvider)
          .loadFavorites();
      expect(persisted, isEmpty);
    },
  );

  test('persists favorite summary for instant tab rendering', () async {
    const pokemon = PokemonSummary(
      id: 1,
      name: 'bulbasaur',
      artworkUrl: 'https://example.test/1.png',
    );

    await container.read(favoritesProvider.notifier).toggle(pokemon);

    final persisted = await container
        .read(favoritesRepositoryProvider)
        .loadFavorites();
    expect(persisted[pokemon.id]?.id, pokemon.id);
    expect(persisted[pokemon.id]?.name, pokemon.name);
    expect(persisted[pokemon.id]?.artworkUrl, pokemon.artworkUrl);
  });
}
