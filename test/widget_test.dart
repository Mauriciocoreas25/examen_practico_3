import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:examen_practico_3/models/character.dart';
import 'package:examen_practico_3/models/api_response.dart';
import 'package:examen_practico_3/providers/character_provider.dart';
import 'package:examen_practico_3/providers/favorites_provider.dart';
import 'package:examen_practico_3/screens/character_list_screen.dart';

void main() {
  group('Character Model Tests', () {
    test('Parsea correctamente JSON válido con todos los campos', () {
      final json = {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin': {'name': 'Earth (C-137)', 'url': 'https://rickandmortyapi.com/api/location/1'},
        'location': {'name': 'Citadel of Ricks', 'url': 'https://rickandmortyapi.com/api/location/3'},
        'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        'episode': ['https://rickandmortyapi.com/api/episode/1'],
        'url': 'https://rickandmortyapi.com/api/character/1',
        'created': '2017-11-04T18:48:46.250Z'
      };

      final character = Character.fromJson(json);

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, 'Alive');
      expect(character.species, 'Human');
      expect(character.gender, 'Male');
      expect(character.originName, 'Earth (C-137)');
      expect(character.locationName, 'Citadel of Ricks');
      expect(character.episode.length, 1);
    });

    test('Maneja campos nulos y faltantes sin fallar', () {
      final json = <String, dynamic>{
        'id': '99',
        'name': null,
        'status': null,
        'species': null,
        'origin': null,
        'location': null,
        'episode': null,
      };

      final character = Character.fromJson(json);

      expect(character.id, 99);
      expect(character.name, 'Sin nombre');
      expect(character.status, 'unknown');
      expect(character.species, 'Desconocida');
      expect(character.originName, 'Desconocido');
      expect(character.locationName, 'Desconocido');
      expect(character.episode, isEmpty);
    });

    test('Parsea respuesta paginada con metadatos correctamente', () {
      final json = {
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': null,
        },
        'results': [
          {
            'id': 1,
            'name': 'Rick Sanchez',
            'status': 'Alive',
            'species': 'Human',
            'gender': 'Male',
          }
        ]
      };

      final response = CharacterResponse.fromJson(json);

      expect(response.info.count, 826);
      expect(response.info.pages, 42);
      expect(response.info.prev, isNull);
      expect(response.info.next, isNotNull);
      expect(response.results.length, 1);
      expect(response.results.first.name, 'Rick Sanchez');
    });
  });

  group('Widget Tests', () {
    testWidgets('Prueba de escritura en la barra de búsqueda', (WidgetTester tester) async {
      final characterProvider = CharacterProvider();
      final favoritesProvider = FavoritesProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: favoritesProvider),
            ChangeNotifierProvider.value(value: characterProvider),
          ],
          child: const MaterialApp(
            home: CharacterListScreen(),
          ),
        ),
      );

      await tester.pump();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Rick');
      await tester.pump();

      expect(characterProvider.searchQuery, 'Rick');
    });
  });
}
