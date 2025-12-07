import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

class AuthUseCases {
  const AuthUseCases({
    required AuthRepository repository,
  }) : _authRepository = repository;

  final AuthRepository _authRepository;

  Future<Either<Failure, UserEntity>> login(String email, String password) => _authRepository.login(email, password);

  Future<Either<Failure, UserEntity>> register(String email, String password, String? name) => _authRepository.register(email, password, name);

  Future<Either<Failure, void>> logout() => _authRepository.logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser() => _authRepository.getCurrentUser();

  Future<Either<Failure, bool>> isAuthenticated() => _authRepository.isAuthenticated();
}

