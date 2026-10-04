import '../../core/utils/string_extensions.dart';

/// Detailed Pokémon fields displayed on the information screen.
class PokemonDetail {
  const PokemonDetail({
    required this.id,
    required this.name,
    required this.artworkUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
  });

  final int id;
  final String name;
  final String artworkUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;

  String get displayName => name.titleWords;

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String) {
      throw const FormatException('Pokémon details are missing an ID or name.');
    }
    final types = (json['types'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((entry) => entry['type'])
        .whereType<Map<String, dynamic>>()
        .map((entry) => entry['name'])
        .whereType<String>()
        .toList(growable: false);
    final abilities = (json['abilities'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PokemonAbility.fromJson)
        .toList(growable: false);
    final stats = (json['stats'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PokemonStat.fromJson)
        .toList(growable: false);
    final sprites = json['sprites'] is Map<String, dynamic>
        ? json['sprites'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final other = sprites['other'] is Map<String, dynamic>
        ? sprites['other'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final artwork = other['official-artwork'] is Map<String, dynamic>
        ? other['official-artwork'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return PokemonDetail(
      id: id,
      name: name,
      artworkUrl: artwork['front_default'] is String
          ? artwork['front_default'] as String
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      types: types,
      height: json['height'] is int ? json['height'] as int : 0,
      weight: json['weight'] is int ? json['weight'] as int : 0,
      abilities: abilities,
      stats: stats,
    );
  }
}

/// An ability name and whether it is hidden.
class PokemonAbility {
  const PokemonAbility({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;

  String get displayName => name.titleWords;

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'];
    final name = ability is Map<String, dynamic> ? ability['name'] : null;
    return PokemonAbility(
      name: name is String ? name : 'unknown',
      isHidden: json['is_hidden'] == true,
    );
  }
}

/// A named base stat with its numeric value.
class PokemonStat {
  const PokemonStat({required this.name, required this.value});

  final String name;
  final int value;

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    final stat = json['stat'];
    final name = stat is Map<String, dynamic> ? stat['name'] : null;
    return PokemonStat(
      name: name is String ? name : 'unknown',
      value: json['base_stat'] is int ? json['base_stat'] as int : 0,
    );
  }
}
