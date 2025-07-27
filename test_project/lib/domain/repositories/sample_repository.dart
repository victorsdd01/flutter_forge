import 'package:dartz/dartz.dart';
import '../entities/sample_entity.dart';
import '../../core/errors/failures.dart';
import 'base_repository.dart';

/// Sample repository interface
abstract class SampleRepository extends BaseRepository {
  Future<Either<Failure, List<SampleEntity>>> getSamples();
  Future<Either<Failure, SampleEntity>> getSampleById(String id);
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample);
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample);
  Future<Either<Failure, bool>> deleteSample(String id);
}
