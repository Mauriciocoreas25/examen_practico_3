import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService;
  final ApiService _apiService;

  Set<int> _favoriteIds = {};
  final Map<int, Character> _characterCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  FavoritesProvider({
    FavoritesService? favoritesService,
    ApiService? apiService,
  })  : _favoritesService = favoritesService ?? FavoritesService(),
        _apiService = apiService ?? ApiService() {
    init();
  }

  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Character> get favoriteCharacters {
    // Retorna los personajes en caché que están actualmente en _favoriteIds
    return _favoriteIds
        .where((id) => _characterCache.containsKey(id))
        .map((id) => _characterCache[id]!)
        .toList();
  }

  bool isFavorite(int id) {
    return _favoriteIds.contains(id);
  }

  /// Carga inicial de IDs desde SharedPreferences
  Future<void> init() async {
    try {
      _favoriteIds = await _favoritesService.getFavoriteIds();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al inicializar favoritos: $e');
    }
  }

  /// Registra un personaje en el caché local para que esté disponible de inmediato
  void cacheCharacter(Character character) {
    _characterCache[character.id] = character;
  }

  /// Registra una lista de personajes en caché
  void cacheCharacters(Iterable<Character> characters) {
    for (final char in characters) {
      _characterCache[char.id] = char;
    }
  }

  /// Alterna favorito para un personaje
  Future<void> toggleFavorite(Character character) async {
    cacheCharacter(character);
    final isFav = _favoriteIds.contains(character.id);

    if (isFav) {
      _favoriteIds.remove(character.id);
    } else {
      _favoriteIds.add(character.id);
    }
    notifyListeners();

    try {
      await _favoritesService.saveFavoriteIds(_favoriteIds);
    } catch (e) {
      debugPrint('Error al guardar favoritos: $e');
      // Revertir en caso de falla
      if (isFav) {
        _favoriteIds.add(character.id);
      } else {
        _favoriteIds.remove(character.id);
      }
      notifyListeners();
    }
  }

  /// Carga la información de los personajes favoritos desde la API si faltan en caché
  Future<void> fetchFavoriteCharacters() async {
    if (_favoriteIds.isEmpty) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    final missingIds = _favoriteIds.where((id) => !_characterCache.containsKey(id)).toList();
    if (missingIds.isEmpty) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final characters = await _apiService.getCharactersByIds(missingIds);
      for (final char in characters) {
        _characterCache[char.id] = char;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
