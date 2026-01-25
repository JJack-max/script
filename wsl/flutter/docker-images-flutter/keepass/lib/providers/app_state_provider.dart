import 'package:flutter/foundation.dart';
import '../models/database_entry.dart';
import '../services/database_service.dart';
import '../services/security_service.dart';
import '../services/search_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppStateProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SecurityService _securityService = SecurityService();

  List<DatabaseEntry> _entries = [];
  List<DatabaseEntry> _filteredEntries = [];
  List<String> _selectedTags = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<DatabaseEntry> get entries => _entries;
  List<DatabaseEntry> get filteredEntries => _filteredEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDatabaseOpen => _databaseService.isOpen;
  bool get isDatabaseLocked =>
      _databaseService.isLocked || _securityService.isLocked;
  String? get databasePath => _databaseService.databasePath;

  // Get default database path
  Future<String> getDefaultDatabasePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/keepass.db';
    } catch (e) {
      // Fallback for web environment or when path_provider is not available
      if (kIsWeb) {
        return 'keepass.db';
      } else {
        // Fallback for other platforms
        return '/tmp/keepass.db';
      }
    }
  }

  // Check if database exists
  Future<bool> databaseExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      // In web environment, we can't check file existence the same way
      // We'll assume it exists and let the open/create logic handle it
      return kIsWeb ? true : false;
    }
  }

  // Load entries from database
  Future<void> loadEntries() async {
    if (!_databaseService.isOpen || _databaseService.isLocked) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = _databaseService.getAllEntries();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply search and tag filters
  void _applyFilters() {
    var result = _entries;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = SearchService.searchEntries(result, _searchQuery);
    }

    // Apply tag filters
    if (_selectedTags.isNotEmpty) {
      result = SearchService.filterByTags(result, _selectedTags);
    }

    _filteredEntries = result;
    notifyListeners();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Update selected tags
  void updateSelectedTags(List<String> tags) {
    _selectedTags = tags;
    _applyFilters();
  }

  // Create new database
  Future<bool> createDatabase(String path, String masterPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.createDatabase(path, masterPassword);
      await loadEntries();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open existing database
  Future<bool> openDatabase(String path, String masterPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.openDatabase(path, masterPassword);
      await loadEntries();
      _securityService.cancelAutoLock();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lock database
  Future<void> lockDatabase() async {
    await _databaseService.lockDatabase();
    _entries = [];
    _filteredEntries = [];
    notifyListeners();
  }

  // Unlock database
  Future<bool> unlockDatabase(String masterPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.unlockDatabase(masterPassword);
      await loadEntries();
      _securityService.cancelAutoLock();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new entry
  Future<bool> addEntry(DatabaseEntry entry) async {
    if (!_databaseService.isOpen || _databaseService.isLocked) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.addEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing entry
  Future<bool> updateEntry(DatabaseEntry entry) async {
    if (!_databaseService.isOpen || _databaseService.isLocked) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateEntry(entry);
      await loadEntries();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete entry
  Future<bool> deleteEntry(String entryId) async {
    if (!_databaseService.isOpen || _databaseService.isLocked) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteEntry(entryId);
      await loadEntries();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
