import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_entity.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.homeRemoteDataSource,
  });

  final HomeRemoteDataSource homeRemoteDataSource;

  @override
  Future<Either<Failure, List<HomeEntity>>> fetchData() async {
    final Either<Failure, List<HomeModel>> result = await homeRemoteDataSource.fetchData();
    return result.fold(
      (Failure failure) => Left<Failure, List<HomeEntity>>(failure),
      (List<HomeModel> models) => Right<Failure, List<HomeEntity>>(models.map((HomeModel model) => HomeEntity.fromModel(model)).toList()),
    );
  }
}

