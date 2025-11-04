import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Base class for all domain entities
abstract class BaseEntity extends Equatable {
  /// Unique identifier for the entity
  final String id;
  
  /// Timestamp of when the entity was created
  final DateTime createdAt;
  
  /// Timestamp of when the entity was last updated
  final DateTime updatedAt;

  @protected
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of the entity with updated fields
  BaseEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
