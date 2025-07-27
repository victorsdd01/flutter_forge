import 'package:dartz/dartz.dart';
import '../../domain/entities/sample_entity.dart';
import '../../core/errors/failures.dart';

/// Sample data source interface
abstract class SampleDataSource {
  Future<Either<Failure, List<SampleEntity>>> getSamples();
  Future<Either<Failure, SampleEntity>> getSampleById(String id);
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample);
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample);
  Future<Either<Failure, bool>> deleteSample(String id);
}

/// Remote data source implementation
class SampleRemoteDataSource implements SampleDataSource {
  @override
  Future<Either<Failure, List<SampleEntity>>> getSamples() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final samples = [
        const SampleEntity(id: '1', name: 'Sample 1', description: 'Description 1'),
        const SampleEntity(id: '2', name: 'Sample 2', description: 'Description 2'),
      ];
      
      return Right(samples);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch samples: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> getSampleById(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final sample = SampleEntity(id: id, name: 'Sample $id', description: 'Description $id');
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch sample: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to create sample: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to update sample: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to delete sample: $e'));
    }
  }
}

/// Local data source implementation
class SampleLocalDataSource implements SampleDataSource {
  @override
  Future<Either<Failure, List<SampleEntity>>> getSamples() async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      
      final samples = [
        const SampleEntity(id: '1', name: 'Local Sample 1', description: 'Local Description 1'),
        const SampleEntity(id: '2', name: 'Local Sample 2', description: 'Local Description 2'),
      ];
      
      return Right(samples);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch samples from cache: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> getSampleById(String id) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      
      final sample = SampleEntity(id: id, name: 'Local Sample $id', description: 'Local Description $id');
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch sample from cache: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to create sample in cache: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to update sample in cache: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete sample from cache: $e'));
    }
  }
}
