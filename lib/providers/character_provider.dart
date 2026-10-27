import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

class CharacterProvider extends ChangeNotifier {
  final ApiService _apiService;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCharacters = 0;
  bool _hasPrev = false;
  bool _hasNext = false;

  bool _isLoading = false;
  String? _errorMessage;

  List<Character> _pageCharacters = [];
  String _searchQuery = '';

  CharacterProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    loadPage(1);
  }

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCharacters => _totalCharacters;
  bool get hasPrev => _hasPrev && !_isLoading;
  bool get hasNext => _hasNext && !_isLoading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Character> get displayedCharacters {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _pageCharacters;
    }
    return _pageCharacters.where((character) {
      return character.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Character> get pageCharacters => _pageCharacters;

  Future<void> loadPage(int page) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final CharacterResponse response = await _apiService.getCharacters(page: page);
      _currentPage = page;
      _totalPages = response.info.pages;
      _totalCharacters = response.info.count;
      _hasPrev = response.info.prev != null;
      _hasNext = response.info.next != null;
      _pageCharacters = response.results;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (hasNext && !_isLoading) {
      await loadPage(_currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    if (hasPrev && !_isLoading && _currentPage > 1) {
      await loadPage(_currentPage - 1);
    }
  }

  Future<void> retry() async {
    await loadPage(_currentPage);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
