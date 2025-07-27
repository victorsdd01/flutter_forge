import 'package:equatable/equatable.dart';

/// Base entity class for all domain entities
abstract class BaseEntity extends Equatable {
  const BaseEntity();
  
  @override
  List<Object?> get props => [];
}
