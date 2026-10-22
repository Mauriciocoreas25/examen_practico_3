# Examen Práctico 3 - Desarrollo de Aplicaciones Moviles  
**Facilitador:** Ing. Eduardo Vásquez  

---

##  Integrantes del Equipo
- **Estudiante 1:** [Mauricio Enrique Coreas Chavez] - Carnet: [047025]
- **Estudiante 2:** [Jose  Moises  Buruca Giron ] - Carnet: [046725]


---

## 📌 Descripción de la Aplicación
Esta aplicación móvil desarrollada en Flutter permite explorar el catálogo oficial de personajes de la serie animada **Rick and Morty** consumiendo en tiempo real la [API pública de Rick and Morty](https://rickandmortyapi.com/).

La aplicación cuenta con paginación completa, filtrado local por nombre dentro de la página consultada, pantalla de detalle con atributos extendidos, gestión persistente de favoritos en almacenamiento local (`shared_preferences`), y manejo robusto de estados de interfaz (cargas, errores de red amigables con reintento y estados vacíos).

---

## Funcionalidades Implementadas (Rúbrica de Evaluación)

### Requerimientos Funcionales Obligatorios:
1. **RF-01: Catálogo de personajes (2.00 pts)**
   - Consulta HTTP real a la API (`GET https://rickandmortyapi.com/api/character?page=1`).
   - Muestra tarjetas de personajes con: **Imagen**, **Nombre**, **Estado** (con distintivo visual/badge según vivo, muerto o desconocido) y **Especie** (dato adicional del catálogo).

2. **RF-02: Detalle y navegación (1.00 pts)**
   - Al pulsar cualquier personaje, se abre la pantalla de detalle con navegación de regreso clara.
   - Presenta la imagen destacada, nombre, estado y **más de 3 datos adicionales**:
     - Especie
     - Género
     - Origen (`origin.name`)
     - Ubicación actual (`location.name`)
     - Tipo/Subespecie (si aplica)
     - Cantidad de episodios en que aparece

3. **RF-03: Búsqueda por nombre (1.00 pts)**
   - Barra de búsqueda local que filtra en tiempo real por coincidencia parcial de texto (case-insensitive) sobre los personajes de la página actual cargada.
   - Indica visualmente al usuario que la búsqueda aplica a la página actual.
   - Muestra un estado visual amigable cuando no existen coincidencias.

4. **RF-04: Paginación (1.00 pts)**
   - Botones **Anterior** y **Siguiente** que solicitan dinámicamente diferentes páginas a la API.
   - Muestra el indicador: `Página X de Y`.
   - Deshabilita los botones en límites (página 1 o última página) y durante la carga.

5. **RF-05: Favoritos persistentes (2.00 pts)**
   - Permite agregar y quitar favoritos desde las tarjetas y desde la pantalla de detalle.
   - Distintivo visual (icono de corazón relleno y rojo / borde gris).
   - Pantalla dedicada de Favoritos accesible desde el AppBar (con contador en tiempo real).
   - Los IDs de favoritos se almacenan en el dispositivo con `shared_preferences` y persisten al cerrar y reabrir la aplicación.

6. **RF-06: Estados de la interfaz (1.00 pts)**
   - **Cargando:** Indicadores de progreso animados (`CircularProgressIndicator`).
   - **Sin resultados:** Mensajes e ilustraciones amigables si no hay personajes o coincidencias.
   - **Fallo de red:** Manejo de excepciones de conectividad y HTTP con mensaje claro en español y botón de **Reintentar**.
   - UI fluida y sin bloqueos ni excepciones técnicas expuestas al usuario.

---

##  Requerimientos Técnicos
- **RT-01 - Consumo HTTP y Modelo Dart (1.00 pts):**
  - Implementación con paquete `http`.
  - Modelos `Character` y `CharacterResponse` con métodos `fromJson` robustos ante valores nulos, faltantes o tipos inconsistentes.
- **RT-02 - Arquitectura, Estado e Imágenes (1.00 pts):**
  - Arquitectura modular limpia:
    - `models/`: Modelos de datos y mapeo JSON.
    - `services/`: Capa de consumo HTTP y almacenamiento de persistencia.
    - `providers/`: Gestión de estado reactiva con `Provider` y `ChangeNotifier`.
    - `screens/`: Vistas de catálogo, detalle y favoritos.
    - `widgets/`: Componentes reutilizables (tarjeta, insignia de estado, widgets de error).
  - Carga de imágenes remotas vía HTTPS con indicador de carga y fallback visual (`Icons.broken_image`) ante fallos.

---

##  Estructura del Código

```text
lib/
├── main.dart                          # Punto de entrada y configuración de MultiProvider
├── models/
│   ├── api_response.dart             # Modelos PageInfo y CharacterResponse
│   └── character.dart                # Modelo Character con parser defensivo
├── services/
│   ├── api_service.dart              # Peticiones HTTP a la API de Rick and Morty
│   └── favorites_service.dart        # Persistencia en SharedPreferences
├── providers/
│   ├── character_provider.dart       # Estado del catálogo, paginación y búsqueda
│   └── favorites_provider.dart       # Estado reactivo y persistencia de favoritos
├── screens/
│   ├── character_list_screen.dart    # Catálogo inicial, buscador y controles de página
│   ├── character_detail_screen.dart  # Detalle completo con datos adicionales
│   └── favorites_screen.dart         # Listado de personajes guardados como favoritos
└── widgets/
    ├── character_card.dart           # Tarjeta individual con imagen y botón favorito
    ├── network_error_widget.dart     # Vista para error de conexión con botón reintentar
    └── status_badge.dart             # Insignia de estado (Vivo, Muerto, Desconocido)
```

---

##  Instrucciones para Ejecutar el Proyecto

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Mauriciocoreas25/examen_practico_3.git
   cd examen_practico_3
   ```

2. **Obtener las dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar pruebas unitarias:**
   ```bash
   flutter test
   ```

4. **Correr la aplicación:**
   ```bash
   flutter run
   ```
