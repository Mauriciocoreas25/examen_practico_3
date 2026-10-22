class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String originUrl;
  final String locationName;
  final String locationUrl;
  final String image;
  final List<String> episode;
  final String url;
  final String created;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.originUrl,
    required this.locationName,
    required this.locationUrl,
    required this.image,
    required this.episode,
    required this.url,
    required this.created,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    // origin y location son objetos anidados que pueden ser nulos o tener formato inesperado
    String originName = 'Desconocido';
    String originUrl = '';
    if (json['origin'] is Map<String, dynamic>) {
      final origin = json['origin'] as Map<String, dynamic>;
      originName = (origin['name'] as String?)?.isNotEmpty == true
          ? origin['name'] as String
          : 'Desconocido';
      originUrl = (origin['url'] as String?) ?? '';
    }

    String locationName = 'Desconocido';
    String locationUrl = '';
    if (json['location'] is Map<String, dynamic>) {
      final location = json['location'] as Map<String, dynamic>;
      locationName = (location['name'] as String?)?.isNotEmpty == true
          ? location['name'] as String
          : 'Desconocido';
      locationUrl = (location['url'] as String?) ?? '';
    }

    // Lista de episodios
    List<String> episodesList = [];
    if (json['episode'] is List) {
      episodesList = (json['episode'] as List)
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return Character(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] as String?)?.isNotEmpty == true
          ? json['name'] as String
          : 'Sin nombre',
      status: (json['status'] as String?)?.isNotEmpty == true
          ? json['status'] as String
          : 'unknown',
      species: (json['species'] as String?)?.isNotEmpty == true
          ? json['species'] as String
          : 'Desconocida',
      type: (json['type'] as String?) ?? '',
      gender: (json['gender'] as String?)?.isNotEmpty == true
          ? json['gender'] as String
          : 'Desconocido',
      originName: originName,
      originUrl: originUrl,
      locationName: locationName,
      locationUrl: locationUrl,
      image: (json['image'] as String?) ?? '',
      episode: episodesList,
      url: (json['url'] as String?) ?? '',
      created: (json['created'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': {
        'name': originName,
        'url': originUrl,
      },
      'location': {
        'name': locationName,
        'url': locationUrl,
      },
      'image': image,
      'episode': episode,
      'url': url,
      'created': created,
    };
  }
}
