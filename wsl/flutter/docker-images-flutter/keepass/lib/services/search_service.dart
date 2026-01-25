import '../models/database_entry.dart';

class SearchService {
  /// Performs a global search across all fields of entries
  static List<DatabaseEntry> searchEntries(
    List<DatabaseEntry> entries,
    String query,
  ) {
    if (query.isEmpty) return entries;
    
    final lowerQuery = query.toLowerCase();
    
    return entries.where((entry) {
      return _matchesQuery(entry, lowerQuery);
    }).toList();
  }
  
  /// Filters entries by tags
  static List<DatabaseEntry> filterByTags(
    List<DatabaseEntry> entries,
    List<String> tags,
  ) {
    if (tags.isEmpty) return entries;
    
    return entries.where((entry) {
      return tags.any((tag) => entry.tags.contains(tag));
    }).toList();
  }
  
  /// Filters entries by a single tag
  static List<DatabaseEntry> filterByTag(
    List<DatabaseEntry> entries,
    String tag,
  ) {
    return entries.where((entry) => entry.tags.contains(tag)).toList();
  }
  
  /// Gets all unique tags from entries
  static List<String> getAllTags(List<DatabaseEntry> entries) {
    final tags = <String>{};
    for (final entry in entries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }
  
  /// Private helper to check if an entry matches a query
  static bool _matchesQuery(DatabaseEntry entry, String lowerQuery) {
    return entry.title.toLowerCase().contains(lowerQuery) ||
           entry.username.toLowerCase().contains(lowerQuery) ||
           entry.url.toLowerCase().contains(lowerQuery) ||
           entry.notes.toLowerCase().contains(lowerQuery) ||
           entry.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }
}