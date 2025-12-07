import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{project_name}}/core/core.dart';
import 'package:{{project_name}}/features/home/domain/repositories/home_repository.dart';
import 'package:{{project_name}}/features/home/domain/use_cases/home_use_cases.dart';
import 'package:{{project_name}}/features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:{{project_name}}/features/home/data/repositories/home_repository_impl.dart';
import 'package:{{project_name}}/features/home/data/datasources/remote/home_remote_datasource.dart';

class Injector {
  Injector._();

  static final GetIt _locator = GetIt.instance;

  static void init() {
    _other();
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static T get<T extends Object>() => _locator<T>();

  static void registerSingleton<T extends Object>(T instance) {
    _locator.registerSingleton<T>(instance);
  }

  static void registerLazySingleton<T extends Object>(T Function() factory) {
    _locator.registerLazySingleton<T>(factory);
  }

  static void registerFactory<T extends Object>(T Function() factory) {
    _locator.registerFactory<T>(factory);
  }

  static void reset() {
    _locator.reset();
  }

  static void _other() {
    registerLazySingleton<HttpClient>(
      () => HttpClient('https://api.example.com'),
    );
    final sharedPrefs = SharedPreferencesUtils();
    registerSingleton<SharedPreferencesUtils>(sharedPrefs);
  }

  static void _registerUseCases() {
    registerLazySingleton<HomeUseCases>(
      () => HomeUseCases(repository: get<HomeRepository>()),
    );
  }

  static void _registerRepositories() {
    registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(homeRemoteDataSource: get<HomeRemoteDataSource>()),
    );
  }

  static void _registerDataSources() {
    registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(),
    );
  }

  static void _registerBlocs() {
    registerLazySingleton<HomeBloc>(
      () => HomeBloc(homeUseCases: get<HomeUseCases>()),
    );
  }
}

