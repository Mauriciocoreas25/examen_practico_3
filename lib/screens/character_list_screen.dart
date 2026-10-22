import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/network_error_widget.dart';
import 'character_detail_screen.dart';
import 'favorites_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rick and Morty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón para acceder a la pantalla de Favoritos con contador
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                    tooltip: 'Ver Favoritos',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  if (favoritesProvider.favoriteIds.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${favoritesProvider.favoriteIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda local (RF-03)
          // Usamos ValueListenableBuilder para el icono de limpiar sin reconstruir el TextField
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar en la página actual...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              context.read<CharacterProvider>().clearSearch();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (text) {
                    context.read<CharacterProvider>().setSearchQuery(text);
                  },
                );
              },
            ),
          ),

          // Aviso explícito que indica que la búsqueda es local a la página actual (RF-03)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 2.0),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: Colors.blueGrey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Búsqueda local sobre los personajes de la página actual.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Contenido principal (RF-01, RF-06)
          Expanded(
            child: Consumer<CharacterProvider>(
              builder: (context, characterProvider, child) {
                // Estado de carga inicial o de cambio de página
                if (characterProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando personajes...',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                // Estado de error de conexión / API
                if (characterProvider.errorMessage != null) {
                  return NetworkErrorWidget(
                    message: characterProvider.errorMessage!,
                    onRetry: () => characterProvider.retry(),
                  );
                }

                final displayedCharacters = characterProvider.displayedCharacters;

                // Estado de sin coincidencias de búsqueda local
                if (displayedCharacters.isEmpty) {
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              characterProvider.searchQuery.isNotEmpty
                                  ? 'No se encontraron resultados para "${characterProvider.searchQuery}" en la página actual.'
                                  : 'No hay personajes disponibles.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            if (characterProvider.searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  characterProvider.clearSearch();
                                },
                                icon: const Icon(Icons.clear_all_rounded),
                                label: const Text('Limpiar búsqueda'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Lista de personajes
                return RefreshIndicator(
                  onRefresh: () => characterProvider.retry(),
                  child: ListView.builder(
                    itemCount: displayedCharacters.length,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemBuilder: (context, index) {
                      final character = displayedCharacters[index];
                      return CharacterCard(
                        character: character,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CharacterDetailScreen(
                                character: character,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Barra inferior de paginación (RF-04)
          // Se oculta limpiamente cuando el teclado está abierto para no sobrecargar el espacio
          if (!isKeyboardOpen)
            Consumer<CharacterProvider>(
              builder: (context, characterProvider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, -2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Anterior
                      ElevatedButton.icon(
                        onPressed: characterProvider.hasPrev
                            ? () {
                                _searchController.clear();
                                characterProvider.clearSearch();
                                characterProvider.prevPage();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: const Text('Anterior'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Indicador de página actual y total
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Página ${characterProvider.currentPage} de ${characterProvider.totalPages}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      // Botón Siguiente
                      ElevatedButton(
                        onPressed: characterProvider.hasNext
                            ? () {
                                _searchController.clear();
                                characterProvider.clearSearch();
                                characterProvider.nextPage();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Siguiente'),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
