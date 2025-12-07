import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

