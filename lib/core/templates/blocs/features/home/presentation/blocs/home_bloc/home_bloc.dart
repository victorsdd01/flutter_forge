import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import 'package:{{project_name}}/core/core.dart';
import 'package:{{project_name}}/features/home/domain/use_cases/home_use_cases.dart';

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
      await event.map(
        initialized: (e) async {
          emit(state.copyWith(isLoading: true));
          final Either<Failure, void> result = await _homeUseCases.fetchData();
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false),
            ),
            (_) => emit(state.copyWith(isLoading: false)),
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

