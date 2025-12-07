import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(String email, String password, String? name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      
      final mockUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      
      return Right(mockUser);
    } catch (e) {
      return Left<Failure, UserModel>(
        ServerFailure(message: 'Login failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(String email, String password, String? name) async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      
      final mockUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name ?? email.split('@').first,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      
      return Right(mockUser);
    } catch (e) {
      return Left<Failure, UserModel>(
        ServerFailure(message: 'Registration failed: $e'),
      );
    }
  }
}

