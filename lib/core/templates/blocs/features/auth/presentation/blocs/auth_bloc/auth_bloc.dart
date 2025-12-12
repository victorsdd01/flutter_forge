import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/use_cases/auth_use_cases.dart';
import '../../../domain/entities/user_entity.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthUseCases _authUseCases;

  AuthBloc({
    required AuthUseCases authUseCases,
  }) : _authUseCases = authUseCases,
       super(const AuthState()) {
    on<AuthEvent>((AuthEvent event, Emitter<AuthState> emit) async {
      await event.map(
        login: (_Login e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, UserEntity> result = await _authUseCases.login(e.email, e.password);
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false, isAuthenticated: false),
            ),
            (UserEntity user) => emit(
              state.copyWith(
                user: user,
                isLoading: false,
                failure: null,
                isAuthenticated: true,
              ),
            ),
          );
        },
        register: (_Register e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, UserEntity> result = await _authUseCases.register(e.email, e.password, e.name);
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false, isAuthenticated: false),
            ),
            (UserEntity user) => emit(
              state.copyWith(
                user: user,
                isLoading: false,
                failure: null,
                isAuthenticated: true,
              ),
            ),
          );
        },
        logout: (_Logout e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, void> result = await _authUseCases.logout();
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false),
            ),
            (void _) => emit(
              state.copyWith(
                user: null,
                isLoading: false,
                failure: null,
                isAuthenticated: false,
              ),
            ),
          );
        },
        checkAuth: (_CheckAuth e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, bool> result = await _authUseCases.isAuthenticated();
          if (result.isLeft()) {
            final Failure failure = result.fold((Failure l) => l, (bool r) => throw Exception());
            emit(
              state.copyWith(failure: failure, isLoading: false, isAuthenticated: false),
            );
          } else {
            final bool isAuth = result.fold((Failure l) => throw Exception(), (bool r) => r);
            if (isAuth) {
              final Either<Failure, UserEntity?> userResult = await _authUseCases.getCurrentUser();
              userResult.fold(
                (Failure failure) => emit(
                  state.copyWith(failure: failure, isLoading: false, isAuthenticated: false),
                ),
                (UserEntity? user) => emit(
                  state.copyWith(
                    user: user,
                    isLoading: false,
                    failure: null,
                    isAuthenticated: user != null,
                  ),
                ),
              );
            } else {
              emit(state.copyWith(isLoading: false, isAuthenticated: false));
            }
          }
        },
      );
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(AuthState state) => null;
}

