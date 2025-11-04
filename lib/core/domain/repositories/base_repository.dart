import 'dart:async';

import '../base_entity.dart';

/// Base interface for all repositories
abstract class BaseRepository<T extends BaseEntity> {
  /// Saves an entity
  /// Returns the saved entity with updated fields (e.g., ID, timestamps)
  Future<T> save(T entity);

  /// Retrieves an entity by ID
  /// Returns null if not found
  Future<T?> findById(String id);

  /// Retrieves all entities
  /// Optionally filtered by the provided query function
  Future<List<T>> findAll({bool Function(T)? where});

  /// Deletes an entity by ID
  /// Returns true if the entity was deleted, false otherwise
  Future<bool> delete(String id);

  /// Deletes all entities
  /// Returns the number of deleted entities
  Future<int> deleteAll({bool Function(T)? where});

  /// Counts all entities
  /// Optionally filtered by the provided query function
  Future<int> count({bool Function(T)? where});

  /// Checks if an entity with the given ID exists
  Future<bool> exists(String id);

  /// Stream of all entities
  /// Emits a new list whenever the underlying data changes
  Stream<List<T>> watchAll({bool Function(T)? where});

  /// Stream of a single entity
  /// Emits a new value whenever the entity changes
  Stream<T?> watchById(String id);
}

/// Repository with additional pagination support
abstract class PaginatedRepository<T extends BaseEntity> extends BaseRepository<T> {
  /// Retrieves a paginated list of entities
  /// [page] is 1-based
  /// [limit] is the maximum number of items per page
  /// [where] is an optional filter function
  Future<PaginatedResult<T>> findPaginated({
    int page = 1,
    int limit = 20,
    bool Function(T)? where,
    int Function(T, T)? sort,
    bool descending = false,
  });

  /// Stream of paginated results
  /// Emits a new value whenever the underlying data changes
  Stream<PaginatedResult<T>> watchPaginated({
    int page = 1,
    int limit = 20,
    bool Function(T)? where,
    int Function(T, T)? sort,
    bool descending = false,
  });
}

/// Result of a paginated query
class PaginatedResult<T> {
  /// The items in the current page
  final List<T> items;
  
  /// The current page number (1-based)
  final int currentPage;
  
  /// The number of items per page
  final int itemsPerPage;
  
  /// The total number of items across all pages
  final int totalItems;
  
  /// The total number of pages
  int get totalPages => (totalItems / itemsPerPage).ceil();
  
  /// Whether there is a next page
  bool get hasNextPage => currentPage < totalPages;
  
  /// Whether there is a previous page
  bool get hasPreviousPage => currentPage > 1;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
  });

  /// Creates a copy with updated fields
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  /// Maps the items to a new type
  PaginatedResult<R> map<R>(R Function(T) mapper) {
    return PaginatedResult<R>(
      items: items.map(mapper).toList(),
      currentPage: currentPage,
      itemsPerPage: itemsPerPage,
      totalItems: totalItems,
    );
  }
}
