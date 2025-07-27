import 'package:dartz/dartz.dart';
import '../../domain/entities/sample_entity.dart';
import '../../domain/repositories/sample_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/sample_data_source.dart';

/// Implementation of SampleRepository
class SampleRepositoryImpl implements SampleRepository {
  final SampleDataSource _remoteDataSource;
  final SampleDataSource _localDataSource;

  SampleRepositoryImpl({
    required SampleDataSource remoteDataSource,
    required SampleDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<SampleEntity>>> getSamples() async {
    try {
      // Try remote first, fallback to local
      final remoteResult = await _remoteDataSource.getSamples();
      
      return remoteResult.fold(
        (failure) async {
          // If remote fails, try local
          final localResult = await _localDataSource.getSamples();
          return localResult.fold(
            (localFailure) => Left(ServerFailure('Both remote and local failed')),
            (localSamples) => Right(localSamples),
          );
        },
        (samples) async {
          // If remote succeeds, cache the data
          for (final sample in samples) {
            await _localDataSource.createSample(sample);
          }
          return Right(samples);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> getSampleById(String id) async {
    try {
      // Try remote first, fallback to local
      final remoteResult = await _remoteDataSource.getSampleById(id);
      
      return remoteResult.fold(
        (failure) async {
          // If remote fails, try local
          final localResult = await _localDataSource.getSampleById(id);
          return localResult.fold(
            (localFailure) => Left(ServerFailure('Sample not found')),
            (localSample) => Right(localSample),
          );
        },
        (sample) async {
          // If remote succeeds, cache the data
          await _localDataSource.createSample(sample);
          return Right(sample);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample) async {
    try {
      // Create in remote first
      final remoteResult = await _remoteDataSource.createSample(sample);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (createdSample) async {
          // If remote succeeds, cache locally
          await _localDataSource.createSample(createdSample);
          return Right(createdSample);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: $e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample) async {
    try {
      // Update in remote first
      final remoteResult = await _remoteDataSource.updateSample(sample);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (updatedSample) async {
          // If remote succeeds, update locally
          await _localDataSource.updateSample(updatedSample);
          return Right(updatedSample);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Delete from remote first
      final remoteResult = await _remoteDataSource.deleteSample(id);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (success) async {
          // If remote succeeds, delete locally
          await _localDataSource.deleteSample(id);
          return Right(success);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: $e'));
    }
  }
}
