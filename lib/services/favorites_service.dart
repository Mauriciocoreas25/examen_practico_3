import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_character_ids';

  /// Obtiene el conjunto de IDs guardados como favoritos
  Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_favoritesKey) ?? [];
    return stringList
        .map((str) => int.tryParse(str))
        .whereType<int>()
        .toSet();
  }

  /// Guarda el conjunto completo de IDs favoritos
  Future<bool> saveFavoriteIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = ids.map((id) => id.toString()).toList();
    return await prefs.setStringList(_favoritesKey, stringList);
  }

  /// Alterna un favorito (agrega si no está, remueve si está)
  Future<bool> toggleFavorite(int id) async {
    final ids = await getFavoriteIds();
    final isFav = ids.contains(id);
    if (isFav) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await saveFavoriteIds(ids);
    return !isFav;
  }
}
