import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/sample_usecase.dart';

part 'sample_bloc.g.dart';
part 'sample_bloc.freezed.dart';
part 'sample_event.dart';
part 'sample_state.dart';

class SampleBloc extends HydratedBloc<SampleEvent, SampleState> {
  final SampleUseCase _sampleUseCase;

  SampleBloc({required SampleUseCase sampleUseCase}) 
    : _sampleUseCase = sampleUseCase, super(const SampleState()) {
    on<SampleEvent>((SampleEvent event, Emitter<SampleState> emit) async {
      switch (event) {
         case _FetchData():
          {
            final Either<Failure, String> result = await _sampleUseCase();
            result.fold(
              (Failure failure) => emit(state.copyWith(failure: failure)),
              (String data) {
                emit(state.copyWith(
                  status: SampleStatus.success,
                  data: data,
                ));
              },
            );
            break;
          }
      }
    });
  }

  @override
  SampleState? fromJson(Map<String, dynamic> json) => SampleState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SampleState state) => state.toJson();
}
