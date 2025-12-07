import 'package:dartz/dartz.dart';
import '../repositories/home_repository.dart';
import '../entities/home_entity.dart';
import '../../../../core/errors/failures.dart';

class HomeUseCases {
  const HomeUseCases({
    required HomeRepository repository,
  }) : _homeRepository = repository;

  final HomeRepository _homeRepository;

  Future<Either<Failure, List<HomeEntity>>> fetchData() async => await _homeRepository.fetchData();
}

