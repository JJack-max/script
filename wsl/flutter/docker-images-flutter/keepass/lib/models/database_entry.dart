import 'package:uuid/uuid.dart';

class DatabaseEntry {
  final String id;
  String title;
  String username;
  String password;
  String url;
  String notes;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;

  DatabaseEntry({
    String? id,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for updating entries
  DatabaseEntry copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return DatabaseEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from map
  factory DatabaseEntry.fromMap(Map<String, dynamic> map) {
    return DatabaseEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      url: map['url'] as String,
      notes: map['notes'] as String,
      tags: List<String>.from(map['tags'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
