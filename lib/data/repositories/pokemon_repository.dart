import '../datasources/pokemon_api_client.dart';
import '../models/pokemon_detail.dart';
import '../models/pokemon_list_response.dart';

/// Repository boundary for Pokémon list and detail requests.
class PokemonRepository {
  const PokemonRepository(this._apiClient);

  final PokemonApiClient _apiClient;

  Future<PokemonListResponse> getPokemonPage({required int offset}) =>
      _apiClient.getPokemonPage(offset: offset);

  Future<PokemonDetail> getPokemon(String nameOrId) =>
      _apiClient.getPokemon(nameOrId);
}
