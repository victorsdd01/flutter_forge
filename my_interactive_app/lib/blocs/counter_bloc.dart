import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementCounter>(_onIncrement);
    on<DecrementCounter>(_onDecrement);
  }

  void _onIncrement(IncrementCounter event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      emit(CounterLoaded(currentState.count + 1));
    } else {
      emit(const CounterLoaded(1));
    }
  }

  void _onDecrement(DecrementCounter event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      emit(CounterLoaded(currentState.count - 1));
    } else {
      emit(const CounterLoaded(-1));
    }
  }
}
