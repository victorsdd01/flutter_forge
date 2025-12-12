part of 'home_bloc.dart';

@freezed
abstract class HomeStatus with _$HomeStatus {
  const factory HomeStatus({
    @Default(false) bool isGetItems,
  }) = _HomeStatus;
}

@freezed
abstract class HomeSuccessStatus with _$HomeSuccessStatus {
  const factory HomeSuccessStatus({
    @Default(false) bool getItems,
  }) = _HomeSuccessStatus;
}

@freezed
abstract class HomeErrorStatus with _$HomeErrorStatus {
  const factory HomeErrorStatus({
    @Default(false) bool getItems,
  }) = _HomeErrorStatus;
}

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(HomeStatus()) HomeStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(HomeSuccessStatus()) HomeSuccessStatus successStatus,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(HomeErrorStatus()) HomeErrorStatus errorStatus,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Failure? failure,
    @Default(<HomeEntity>[]) List<HomeEntity> items,
  }) = _HomeState;
}

