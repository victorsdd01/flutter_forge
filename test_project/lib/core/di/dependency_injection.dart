import 'package:get_it/get_it.dart';
import '../../domain/usecases/sample_usecase.dart';import '../../presentation/blocs/sample_bloc.dart';

/// Custom Dependency Injection container using GetIt
class Injector {
  Injector._();

  static final GetIt _locator = GetIt.instance;

  static void init() {
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

  //** ---- Data Sources ---- */
  static void _registerDataSources() {
    // Example: registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
    // Example: registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  }

  //** ---- Repositories ---- */
  static void _registerRepositories() {
    // Example: registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    //   authRemoteDataSource: get<AuthRemoteDataSource>(),
    //   authLocalDataSource: get<AuthLocalDataSource>(),
    // ));
  }

  //** ---- Use Cases ---- */
  static void _registerUseCases() {
    // Example: registerLazySingleton<AuthUseCases>(() => AuthUseCases(
    //   repository: get<AuthRepository>(),
    // ));
    
    // Sample use cases
    registerLazySingleton<SampleUseCase>(() => const SampleUseCase());
    registerLazySingleton<SampleWithParamsUseCase>(() => const SampleWithParamsUseCase());
  }

  //** ---- BLoCs ---- */
  static void _registerBlocs() {
    // Example: registerLazySingleton(() => AuthBloc(
    //   authUseCases: get<AuthUseCases>(),
    // ));
        // Register SampleBloc
    registerLazySingleton<SampleBloc>(() => SampleBloc(sampleUseCase: get<SampleUseCase>()));
  }
}
