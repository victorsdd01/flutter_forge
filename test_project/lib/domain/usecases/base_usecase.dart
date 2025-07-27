import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base use case class for all use cases
abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();
  
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters use case
abstract class NoParamsUseCase<Type> {
  const NoParamsUseCase();
  
  Future<Either<Failure, Type>> call();
}
