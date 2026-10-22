import 'character.dart';

class PageInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  PageInfo({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory PageInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PageInfo(count: 0, pages: 0, next: null, prev: null);
    }
    return PageInfo(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      pages: json['pages'] is int
          ? json['pages'] as int
          : int.tryParse(json['pages']?.toString() ?? '0') ?? 0,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}

class CharacterResponse {
  final PageInfo info;
  final List<Character> results;

  CharacterResponse({
    required this.info,
    required this.results,
  });

  factory CharacterResponse.fromJson(Map<String, dynamic> json) {
    final info = PageInfo.fromJson(
      json['info'] is Map<String, dynamic>
          ? json['info'] as Map<String, dynamic>
          : null,
    );

    List<Character> results = [];
    if (json['results'] is List) {
      results = (json['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Character.fromJson(item))
          .toList();
    }

    return CharacterResponse(
      info: info,
      results: results,
    );
  }
}
