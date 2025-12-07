import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/database/app_database.dart';
import '../../models/user_model.dart';
import 'package:drift/drift.dart';

abstract interface class AuthLocalDataSource {
  Future<Either<Failure, UserModel?>> getUserByEmail(String email);
  Future<Either<Failure, List<UserModel>>> getAllUsers();
  Future<Either<Failure, void>> saveUser(UserModel user);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> clearUsers();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase _database;

  AuthLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  @override
  Future<Either<Failure, UserModel?>> getUserByEmail(String email) async {
    try {
      final User? user = await _database.getUserByEmail(email);
      if (user == null) {
        return const Right<Failure, UserModel?>(null);
      }
      final UserModel model = UserModel(
        id: user.id.toString(),
        email: user.email,
        name: user.name,
        token: user.token,
        createdAt: user.createdAt,
      );
      return Right<Failure, UserModel?>(model);
    } catch (e) {
      return Left<Failure, UserModel?>(CacheFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserModel user) async {
    try {
      final User? existingUser = await _database.getUserByEmail(user.email);
      if (existingUser != null) {
        await _database.updateUser(
          User(
            id: existingUser.id,
            email: user.email,
            name: user.name,
            token: user.token,
            createdAt: existingUser.createdAt,
          ),
        );
      } else {
        await _database.insertUser(
          UsersCompanion(
            email: Value<String>(user.email),
            name: Value<String?>(user.name),
            token: Value<String?>(user.token),
          ),
        );
      }
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(CacheFailure(message: 'Failed to save user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await _database.deleteUser(int.parse(userId));
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(CacheFailure(message: 'Failed to delete user: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getAllUsers() async {
    try {
      final List<User> users = await _database.getAllUsers();
      final List<UserModel> models = users.map((User user) => UserModel(
        id: user.id.toString(),
        email: user.email,
        name: user.name,
        token: user.token,
        createdAt: user.createdAt,
      )).toList();
      return Right<Failure, List<UserModel>>(models);
    } catch (e) {
      return Left<Failure, List<UserModel>>(CacheFailure(message: 'Failed to get users: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUsers() async {
    try {
      await _database.clearUsers();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(CacheFailure(message: 'Failed to clear users: $e'));
    }
  }
}

