part of 'sample_bloc.dart';

@freezed
sealed class SampleEvent with _$SampleEvent {
  const factory SampleEvent.fetchData() = _FetchData;
}
