part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default([]) List<HomeEntity> items,
    Failure? failure,
  }) = _HomeState;
}

