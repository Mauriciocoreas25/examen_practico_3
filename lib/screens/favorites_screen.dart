import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/network_error_widget.dart';
import 'character_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetchFavoriteCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favoriteIds = favoritesProvider.favoriteIds;
    final favoriteCharacters = favoritesProvider.favoriteCharacters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personajes Favoritos'),
      ),
      body: Builder(
        builder: (context) {
          if (favoritesProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando tus personajes favoritos...'),
                ],
              ),
            );
          }

          if (favoritesProvider.errorMessage != null) {
            return NetworkErrorWidget(
              message: favoritesProvider.errorMessage!,
              onRetry: () {
                favoritesProvider.fetchFavoriteCharacters();
              },
            );
          }

          if (favoriteIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No tienes favoritos aún',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Marca el corazón en cualquier personaje del catálogo o del detalle para guardarlo aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteCharacters.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final character = favoriteCharacters[index];
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
          );
        },
      ),
    );
  }
}
