import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/features/home/domain/repositories/home_repository.dart';
import 'package:{{project_name}}/core/core.dart';

class HomeUseCases {
  const HomeUseCases({
    required HomeRepository repository,
  }) : _homeRepository = repository;

  final HomeRepository _homeRepository;

  Future<Either<Failure, void>> fetchData() async => await _homeRepository.fetchData();
}

