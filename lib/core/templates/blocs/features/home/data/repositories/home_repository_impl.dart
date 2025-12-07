import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/features/home/data/datasources/remote/home_remote_datasource.dart';
import 'package:{{project_name}}/features/home/domain/repositories/home_repository.dart';
import 'package:{{project_name}}/core/core.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.homeRemoteDataSource,
  });

  final HomeRemoteDataSource homeRemoteDataSource;

  @override
  Future<Either<Failure, void>> fetchData() async {
    final Either<Failure, void> result = await homeRemoteDataSource.fetchData();
    return result.fold(
      (Failure failure) => Left<Failure, void>(failure),
      (_) => const Right<Failure, void>(null),
    );
  }
}

