import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/utils/id_from_url.dart';
import 'package:pokedex_app/data/models/pokemon_detail.dart';
import 'package:pokedex_app/data/models/pokemon_summary.dart';

void main() {
  group('idFromUrl', () {
    test('reads a resource ID from its URL', () {
      expect(idFromUrl('https://pokeapi.co/api/v2/pokemon/25/'), 25);
    });

    test('rejects URLs without a numeric ID', () {
      expect(
        () => idFromUrl('https://pokeapi.co/api/v2/pokemon/pikachu/'),
        throwsFormatException,
      );
    });
  });

  group('PokemonSummary', () {
    test('derives artwork, display name, and padded ID', () {
      final pokemon = PokemonSummary.fromJson({
        'name': 'mr-mime',
        'url': 'https://pokeapi.co/api/v2/pokemon/122/',
      });

      expect(pokemon.id, 122);
      expect(pokemon.displayName, 'Mr Mime');
      expect(pokemon.formattedId, '#122');
      expect(pokemon.artworkUrl, endsWith('/122.png'));
    });
  });

  group('PokemonDetail', () {
    test('parses types, hidden abilities, measurements, and stats', () {
      final pokemon = PokemonDetail.fromJson({
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'sprites': {
          'other': {
            'official-artwork': {
              'front_default': 'https://example.test/25.png',
            },
          },
        },
        'types': [
          {
            'type': {'name': 'electric'},
          },
        ],
        'abilities': [
          {
            'is_hidden': true,
            'ability': {'name': 'lightning-rod'},
          },
        ],
        'stats': [
          {
            'base_stat': 35,
            'stat': {'name': 'hp'},
          },
        ],
      });

      expect(pokemon.types, ['electric']);
      expect(pokemon.abilities.single.displayName, 'Lightning Rod');
      expect(pokemon.abilities.single.isHidden, isTrue);
      expect(pokemon.height, 4);
      expect(pokemon.weight, 60);
      expect(pokemon.stats.single.value, 35);
    });
  });
}
