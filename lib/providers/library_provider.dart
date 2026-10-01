import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/reading_goal.dart';
import '../data/mock_books_data.dart';

class LibraryProvider extends ChangeNotifier {
  final List<Book> _books = List.from(mockBooksCatalog);
  ReadingGoal _goal = ReadingGoal();
  String _selectedGenreFilter = 'All';
  String _searchQuery = '';
  
  // User Onboarding & Auth Profile
  String _userName = 'Reader';
  String _userTitle = 'Curator & Software Architect';
  List<String> _favoriteGenres = ['Technology', 'Philosophy'];
  bool _isOnboardingCompleted = false;
  bool _isLoggedIn = false;

  List<Book> get allBooks => _books;
  ReadingGoal get goal => _goal;
  String get selectedGenreFilter => _selectedGenreFilter;
  String get searchQuery => _searchQuery;
  String get userName => _userName;
  String get userTitle => _userTitle;
  List<String> get favoriteGenres => _favoriteGenres;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoggedIn => _isLoggedIn;

  void loginAsReader({String? name, bool isFirstTimeSignUp = false}) {
    if (name != null && name.trim().isNotEmpty) {
      _userName = name.trim();
    } else if (_userName.trim().isEmpty) {
      _userName = 'Reader';
    }
    _isLoggedIn = true;
    _isOnboardingCompleted = !isFirstTimeSignUp;
    notifyListeners();
  }

  void markOnboardingCompleted() {
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  void signOut() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void completeOnboarding({
    required String name,
    required String title,
    required int dailyTargetMinutes,
    required List<String> genres,
  }) {
    _userName = name.trim().isNotEmpty ? name.trim() : (_userName.isNotEmpty ? _userName : 'Reader');
    _userTitle = title.trim().isNotEmpty ? title.trim() : 'Avid Reader';
    _favoriteGenres = genres.isNotEmpty ? genres : ['Technology', 'Philosophy'];
    _goal = ReadingGoal(
      dailyTargetMinutes: dailyTargetMinutes,
      minutesReadToday: _goal.minutesReadToday,
      currentStreakDays: _goal.currentStreakDays,
      yearlyBookTarget: _goal.yearlyBookTarget,
      booksCompletedThisYear: _goal.booksCompletedThisYear,
      weeklyMinutesHistory: _goal.weeklyMinutesHistory,
    );
    _isOnboardingCompleted = true;
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? title,
  }) {
    if (name != null && name.trim().isNotEmpty) _userName = name.trim();
    if (title != null && title.trim().isNotEmpty) _userTitle = title.trim();
    notifyListeners();
  }

  void resetOnboarding() {
    _isOnboardingCompleted = false;
    notifyListeners();
  }

  // Shelf Getters
  List<Book> get currentlyReading =>
      _books.where((b) => b.shelfStatus == ShelfStatus.currentlyReading).toList();

  List<Book> get wantToRead =>
      _books.where((b) => b.shelfStatus == ShelfStatus.wantToRead).toList();

  List<Book> get completed =>
      _books.where((b) => b.shelfStatus == ShelfStatus.completed).toList();

  List<Book> get wishlist =>
      _books.where((b) => b.shelfStatus == ShelfStatus.wishlist).toList();

  List<Book> get favorites => _books.where((b) => b.isFavorite).toList();

  Book? get priorityBook {
    final reading = currentlyReading;
    if (reading.isNotEmpty) {
      // Return most recently read book
      reading.sort((a, b) {
        final aTime = a.lastReadAt ?? DateTime(2000);
        final bTime = b.lastReadAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return reading.first;
    }
    return _books.isNotEmpty ? _books.first : null;
  }

  // Genre Filters
  List<String> get availableGenres {
    final genres = {'All'};
    for (var b in _books) {
      genres.add(b.genre);
    }
    return genres.toList();
  }

  List<Book> get filteredBooks {
    return _books.where((b) {
      final matchesGenre =
          _selectedGenreFilter == 'All' || b.genre == _selectedGenreFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          b.isbn.contains(_searchQuery);
      return matchesGenre && matchesQuery;
    }).toList();
  }

  void setGenreFilter(String genre) {
    _selectedGenreFilter = genre;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index].isFavorite = !_books[index].isFavorite;
      notifyListeners();
    }
  }

  void updateShelfStatus(String bookId, ShelfStatus newStatus) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index].shelfStatus = newStatus;
      if (newStatus == ShelfStatus.completed) {
        _books[index].currentPage = _books[index].totalPages;
        _goal.booksCompletedThisYear += 1;
      }
      notifyListeners();
    }
  }

  void updateReadingProgress(String bookId, int newPage) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index].currentPage = newPage.clamp(0, _books[index].totalPages);
      _books[index].lastReadAt = DateTime.now();
      if (_books[index].currentPage >= _books[index].totalPages) {
        _books[index].shelfStatus = ShelfStatus.completed;
      } else {
        _books[index].shelfStatus = ShelfStatus.currentlyReading;
      }
      notifyListeners();
    }
  }

  void addMinutesReadToday(int minutes) {
    _goal.minutesReadToday += minutes;
    notifyListeners();
  }

  void addBookToNest(Book newBook) {
    if (!_books.any((b) => b.id == newBook.id)) {
      _books.insert(0, newBook);
      notifyListeners();
    }
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
