part of 'sample_bloc.dart';

enum SampleStatus { 
  initial,
  loading,
  success,
  error,
}

@freezed
sealed class SampleState with _$SampleState {
  const factory SampleState({
    @Default(SampleStatus.initial) SampleStatus status,
    @JsonKey(
      includeFromJson: false,
      includeToJson:   false,
    ) Failure? failure,
    @Default('') String data,
  }) = _SampleState;

  factory SampleState.fromJson(Map<String, dynamic> json) => _$SampleStateFromJson(json);
}
