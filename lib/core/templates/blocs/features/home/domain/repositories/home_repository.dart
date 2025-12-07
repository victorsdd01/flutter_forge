import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/core/core.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, void>> fetchData();
}

