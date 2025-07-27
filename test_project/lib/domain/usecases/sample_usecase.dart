import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import 'base_usecase.dart';

/// Sample use case demonstrating Either<Failure, Type> pattern
class SampleUseCase implements NoParamsUseCase<String> {
  const SampleUseCase();

  @override
  Future<Either<Failure, String>> call() async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(seconds: 1));
      
      // Return success
      return const Right('Sample use case executed successfully!');
    } catch (e) {
      // Return failure
      return Left(ServerFailure('Sample use case failed: $e'));
    }
  }
}

/// Sample use case with parameters
class SampleWithParamsUseCase implements BaseUseCase<String, SampleParams> {
  const SampleWithParamsUseCase();

  @override
  Future<Either<Failure, String>> call(SampleParams params) async {
    try {
      // Simulate async operation with parameters
      await Future.delayed(const Duration(seconds: 1));
      
      // Return success with parameter
      return Right('Hello ${params.name}! Use case executed successfully!');
    } catch (e) {
      // Return failure
      return Left(ServerFailure('Sample use case failed: $e'));
    }
  }
}

/// Sample parameters class
class SampleParams {
  final String name;
  
  const SampleParams({required this.name});
}
