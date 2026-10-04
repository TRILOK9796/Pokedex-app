import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/pokemon_detail.dart';
import '../models/pokemon_list_response.dart';

/// Dio-backed data source for PokéAPI.
class PokemonApiClient {
  PokemonApiClient(this._dio);

  final Dio _dio;

  Future<PokemonListResponse> getPokemonPage({required int offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon',
        queryParameters: {'limit': ApiConstants.pageSize, 'offset': offset},
      );
      return PokemonListResponse.fromJson(_requireData(response.data));
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const AppException('The Pokémon service returned invalid data.');
    }
  }

  Future<PokemonDetail> getPokemon(String nameOrId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon/${Uri.encodeComponent(nameOrId)}',
      );
      return PokemonDetail.fromJson(_requireData(response.data));
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const AppException('The Pokémon service returned invalid data.');
    }
  }

  Map<String, dynamic> _requireData(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException('The Pokémon service returned no data.');
    }
    return data;
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const AppException('The request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const AppException(
          'No internet connection. Check your network and try again.',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status >= 500) {
          return const AppException(
            'The Pokémon service is having trouble. Please try again later.',
          );
        }
        return const AppException('Pokémon data could not be found.');
      case DioExceptionType.cancel:
        return const AppException('The request was cancelled.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const AppException(
          'Something went wrong while loading Pokémon data.',
        );
    }
  }
}
