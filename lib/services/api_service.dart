import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/api_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene la lista de personajes paginada
  Future<CharacterResponse> getCharacters({int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/character?page=$page');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return CharacterResponse.fromJson(decoded);
        } else {
          throw ApiException('El formato de datos recibido no es válido.');
        }
      } else if (response.statusCode == 404) {
        throw ApiException('No se encontraron personajes para esta página.');
      } else {
        throw ApiException(
          'Error en el servidor de Rick and Morty (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'Sin conexión a Internet. Por favor verifica tu red y vuelve a intentar.',
      );
    } on TimeoutException {
      throw ApiException(
        'El servidor tardó demasiado en responder. Inténtalo nuevamente.',
      );
    } on FormatException {
      throw ApiException(
        'Error al procesar la respuesta del servidor.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ocurrió un error inesperado al conectar con la API.');
    }
  }

  /// Obtiene el detalle de un personaje por ID
  Future<Character> getCharacterById(int id) async {
    final uri = Uri.parse('$_baseUrl/character/$id');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return Character.fromJson(decoded);
        } else {
          throw ApiException('Formato de personaje no válido.');
        }
      } else if (response.statusCode == 404) {
        throw ApiException('Personaje no encontrado.');
      } else {
        throw ApiException(
          'Error al consultar el personaje (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'Sin conexión a Internet. Por favor verifica tu red.',
      );
    } on TimeoutException {
      throw ApiException(
        'Tiempo de espera agotado al consultar el personaje.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('No se pudo obtener la información del personaje.');
    }
  }

  /// Obtiene múltiples personajes según una lista de IDs (útil para la pantalla de favoritos)
  Future<List<Character>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    // La API de Rick and Morty permite consultar múltiples IDs así: /character/1,2,3
    final idsParam = ids.join(',');
    final uri = Uri.parse('$_baseUrl/character/$idsParam');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        // Si se pide solo 1 ID, la API retorna un Map en lugar de un List
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => Character.fromJson(item))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          return [Character.fromJson(decoded)];
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ApiException(
          'Error al consultar favoritos (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'Sin conexión a Internet para cargar tus favoritos.',
      );
    } on TimeoutException {
      throw ApiException(
        'Tiempo de espera agotado al consultar favoritos.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al consultar lista de favoritos.');
    }
  }
}
