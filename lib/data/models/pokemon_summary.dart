import '../../core/utils/id_from_url.dart';
import '../../core/utils/string_extensions.dart';

/// Lightweight Pokémon data used by grids and persisted favorites.
class PokemonSummary {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.artworkUrl,
  });

  final int id;
  final String name;
  final String artworkUrl;

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    final name = json['name'];
    if (url is! String || name is! String || name.isEmpty) {
      throw const FormatException('Pokémon result is missing its name or URL.');
    }
    final id = idFromUrl(url);
    return PokemonSummary(id: id, name: name, artworkUrl: artworkFor(id));
  }

  factory PokemonSummary.fromFavoriteJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final artwork = json['artworkUrl'];
    if (id is! int || id <= 0 || name is! String || artwork is! String) {
      throw const FormatException('Stored favorite has an invalid format.');
    }
    return PokemonSummary(id: id, name: name, artworkUrl: artwork);
  }

  static String artworkFor(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get displayName => name.titleWords;

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  Map<String, Object> toFavoriteJson() => {
    'id': id,
    'name': name,
    'artworkUrl': artworkUrl,
  };
}

/// The minimal favorite record retained for offline tab rendering.
typedef FavoritePokemon = PokemonSummary;
