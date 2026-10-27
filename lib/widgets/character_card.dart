import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/favorites_provider.dart';
import 'status_badge.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(character.id);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del personaje con soporte de carga y fallback de error
            SizedBox(
              width: 110,
              height: 120,
              child: character.image.isNotEmpty
                  ? Image.network(
                      character.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                color: Colors.grey,
                                size: 36,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sin imagen',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Información del personaje: Nombre, Estado, Especie (dato adicional)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: character.status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 15,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Especie: ${character.species}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : Colors.grey,
                  size: 26,
                ),
                tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                onPressed: () {
                  favoritesProvider.toggleFavorite(character);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
