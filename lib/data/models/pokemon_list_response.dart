import 'pokemon_summary.dart';

/// A single results page from the PokéAPI list endpoint.
class PokemonListResponse {
  const PokemonListResponse({
    required this.count,
    required this.next,
    required this.results,
  });

  final int count;
  final String? next;
  final List<PokemonSummary> results;

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    if (rawResults is! List) {
      throw const FormatException('Pokémon list response has no results.');
    }
    return PokemonListResponse(
      count: json['count'] is int ? json['count'] as int : 0,
      next: json['next'] is String ? json['next'] as String : null,
      results: rawResults
          .whereType<Map<String, dynamic>>()
          .map(PokemonSummary.fromJson)
          .toList(growable: false),
    );
  }
}
