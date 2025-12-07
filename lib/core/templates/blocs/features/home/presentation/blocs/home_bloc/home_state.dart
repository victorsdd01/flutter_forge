part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(<HomeEntity>[]) List<HomeEntity> items,
    Failure? failure,
  }) = _HomeState;
}

