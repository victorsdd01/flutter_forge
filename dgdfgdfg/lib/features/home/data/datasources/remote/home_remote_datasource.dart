import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../models/home_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<Either<Failure, List<HomeModel>>> fetchData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<Either<Failure, List<HomeModel>>> fetchData() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final models = [
        const HomeModel(id: '1', title: 'Home Item 1', description: 'Description 1'),
        const HomeModel(id: '2', title: 'Home Item 2', description: 'Description 2'),
      ];
      return Right(models);
    } catch (e) {
      return Left<Failure, List<HomeModel>>(ServerFailure(message: 'Failed to fetch data: $e'));
    }
  }
}

