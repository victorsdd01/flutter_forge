import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/core/core.dart';

abstract interface class HomeRemoteDataSource {
  Future<Either<Failure, void>> fetchData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<Either<Failure, void>> fetchData() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(ServerFailure(message: 'Failed to fetch data'));
    }
  }
}

