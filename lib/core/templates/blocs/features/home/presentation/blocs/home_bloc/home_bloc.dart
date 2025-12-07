import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/use_cases/home_use_cases.dart';
import '../../../domain/entities/home_entity.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HomeUseCases _homeUseCases;

  HomeBloc({
    required HomeUseCases homeUseCases,
  }) : _homeUseCases = homeUseCases,
       super(const HomeState()) {
    on<HomeEvent>((HomeEvent event, Emitter<HomeState> emit) async {
      event.map(
        initialized: (_Initialized e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, List<HomeEntity>> result = await _homeUseCases.fetchData();
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false),
            ),
            (List<HomeEntity> entities) => emit(
              state.copyWith(items: entities, isLoading: false, failure: null),
            ),
          );
        },
      );
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(HomeState state) => null;
}

