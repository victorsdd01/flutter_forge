import 'package:equatable/equatable.dart';

abstract class CounterState extends Equatable {
  const CounterState();
  
  @override
  List<Object> get props => [];
}

class CounterInitial extends CounterState {}

class CounterLoading extends CounterState {}

class CounterLoaded extends CounterState {
  final int count;
  
  const CounterLoaded(this.count);
  
  @override
  List<Object> get props => [count];
}

class CounterError extends CounterState {
  final String message;
  
  const CounterError(this.message);
  
  @override
  List<Object> get props => [message];
}
