import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/favorites_provider.dart';
import '../widgets/status_badge.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(character.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          character.name,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Regresar al catálogo',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.redAccent : null,
              size: 28,
            ),
            tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: () {
              favoritesProvider.toggleFavorite(character);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav
                        ? '${character.name} eliminado de favoritos'
                        : '${character.name} agregado a favoritos',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen principal grande
            Container(
              height: 320,
              color: Colors.black12,
              child: character.image.isNotEmpty
                  ? Image.network(
                      character.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagen no disponible',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y Estado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: character.status),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Divider(),
                  const SizedBox(height: 12),

                  Text(
                    'Información Detallada',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildDetailTile(
                    icon: Icons.category_outlined,
                    label: 'Especie',
                    value: character.species,
                  ),

                  // 2. Género
                  _buildDetailTile(
                    icon: Icons.wc_outlined,
                    label: 'Género',
                    value: _translateGender(character.gender),
                  ),

                  // 3. Origen
                  _buildDetailTile(
                    icon: Icons.public_outlined,
                    label: 'Origen',
                    value: character.originName,
                  ),

                  // 4. Ubicación actual
                  _buildDetailTile(
                    icon: Icons.location_on_outlined,
                    label: 'Ubicación actual',
                    value: character.locationName,
                  ),

                  // 5. Tipo o Subespecie (si aplica)
                  if (character.type.isNotEmpty)
                    _buildDetailTile(
                      icon: Icons.nature_people_outlined,
                      label: 'Subtipo / Raza',
                      value: character.type,
                    ),

                  // 6. Cantidad de episodios
                  _buildDetailTile(
                    icon: Icons.movie_creation_outlined,
                    label: 'Apariciones en episodios',
                    value: '${character.episode.length} episodio(s)',
                  ),

                  const SizedBox(height: 24),

                  // Botón de acción para favoritos
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFav
                            ? Colors.red.shade50
                            : theme.colorScheme.primaryContainer,
                        foregroundColor: isFav
                            ? Colors.red.shade700
                            : theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(
                        isFav
                            ? 'Eliminar de mis favoritos'
                            : 'Guardar en mis favoritos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        favoritesProvider.toggleFavorite(character);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav
                                  ? '${character.name} eliminado de favoritos'
                                  : '${character.name} agregado a favoritos',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Femenino';
      case 'genderless':
        return 'Sin género';
      case 'unknown':
      default:
        return 'Desconocido';
    }
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blueGrey.shade700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
