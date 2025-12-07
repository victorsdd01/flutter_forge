import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<HomeEntity>>> fetchData();
}

