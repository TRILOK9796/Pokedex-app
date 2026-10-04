/// Endpoints and pagination settings for PokéAPI.
abstract final class ApiConstants {
  static const baseUrl = 'https://pokeapi.co/api/v2';
  static const pageSize = 20;
  static const connectTimeout = Duration(seconds: 12);
  static const receiveTimeout = Duration(seconds: 12);
}
