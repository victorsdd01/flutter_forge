class TemplateContents {
  TemplateContents._();

  static const String _core_core_dart = r'''export 'errors/failures.dart';
export 'utils/helpers/number_helper.dart';
export 'utils/secure_storage_utils.dart';
export 'utils/toast_util.dart';
export 'network/http_client.dart';
export 'states/tstatefull.dart';
export 'states/tstateless.dart';
export 'enums/server_status.dart';
export 'services/talker_service.dart';

''';
  static const String _core_network_http_client_dart = r'''import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../application/injector.dart';
import '../services/talker_service.dart';
import '../utils/secure_storage_utils.dart';
import '../enums/server_status.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

enum RequestType { GET, POST, PUT, DELETE, PATCH }

class RefreshTokenAuthException implements Exception {
  final String message;
  RefreshTokenAuthException(this.message);
  
  @override
  String toString() => 'RefreshTokenAuthException: $message';
}

class HttpClient {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = <_PendingRequest>[];

  HttpClient(String? baseUrl, {Map<String, String>? defaultHeaders})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? '',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ) {
    _dio.interceptors.addAll(<Interceptor>[
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      TalkerDioLogger(
        talker: TalkerService.instance,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printRequestData: false,
          printResponseHeaders: false,
          printResponseData: false,
          printResponseMessage: false,
        ),
      ),
      _buildInterceptor(),
    ]);
  }

  Interceptor _buildInterceptor() => InterceptorsWrapper(
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
      final String? token = await getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
      handler.next(response);
    },
    onError: (DioException error, ErrorInterceptorHandler handler) async {
      if (error.response?.statusCode == 401) {
        final RequestOptions options = error.requestOptions;
        
        if (options.path.contains('/auth/login') || options.path.contains('/auth/refresh')) {
          return handler.next(error);
        }
        
        if (options.headers['retry'] == true) {
          return handler.next(error);
        }

        if (_isRefreshing) {
          final Completer<Response<dynamic>> completer = Completer<Response<dynamic>>();
          _pendingRequests.add(_PendingRequest(
            options: options,
            handler: handler,
            completer: completer,
          ));
          return completer.future.then((Response<dynamic> response) {
            handler.resolve(response);
          }).catchError((dynamic e) {
            handler.next(e as DioException);
          });
        }
        
        _isRefreshing = true;
        try {
          final String? newToken = await refreshToken();
          
          if (newToken != null && newToken.isNotEmpty) {
            options.headers['retry'] = true;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            try {
              final Response<dynamic> response = await _dio.request(
                options.path,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );
              
              for (final _PendingRequest pendingRequest in _pendingRequests) {
                try {
                  pendingRequest.options.headers['retry'] = true;
                  pendingRequest.options.headers['Authorization'] = 'Bearer $newToken';
                  
                  final Response<dynamic> pendingResponse = await _dio.request(
                    pendingRequest.options.path,
                    options: Options(
                      method: pendingRequest.options.method,
                      headers: pendingRequest.options.headers,
                    ),
                    data: pendingRequest.options.data,
                    queryParameters: pendingRequest.options.queryParameters,
                  );
                  pendingRequest.completer.complete(pendingResponse);
                } catch (e) {
                  pendingRequest.completer.completeError(e);
                }
              }
              _pendingRequests.clear();
              
              return handler.resolve(response);
            } on DioException catch (retryError) {
              for (final _PendingRequest pendingRequest in _pendingRequests) {
                pendingRequest.completer.completeError(retryError);
              }
              _pendingRequests.clear();
              
              return handler.next(retryError);
            }
          } else {
            for (final _PendingRequest pendingRequest in _pendingRequests) {
              pendingRequest.completer.completeError(error);
            }
            _pendingRequests.clear();
            
            return handler.next(error);
          }
        } on RefreshTokenAuthException catch (refreshError) {
          for (final _PendingRequest pendingRequest in _pendingRequests) {
            pendingRequest.completer.completeError(error);
          }
          _pendingRequests.clear();
          
          return handler.next(error);
        } catch (e) {
          for (final _PendingRequest pendingRequest in _pendingRequests) {
            pendingRequest.completer.completeError(error);
          }
          _pendingRequests.clear();
          
          return handler.next(error);
        } finally {
          _isRefreshing = false;
        }
      }
      
      handler.next(error);
    },
  );

  Future<Response<dynamic>> request({
    required String endpoint,
    required RequestType method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool asMultipart = false,
    bool asFormUrlEncoded = false,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      Object? payload = data;
      if (asMultipart && data is! FormData) {
        if (data is Map<String, dynamic>) {
          payload = FormData.fromMap(data);
        }
      }
      String? contentTypeFromHeaders = headers?['Content-Type'] as String?;
      final bool isMultipart = payload is FormData;
      final String computedContentType =
          contentTypeFromHeaders ??
          (isMultipart
              ? 'multipart/form-data'
              : (asFormUrlEncoded
                    ? Headers.formUrlEncodedContentType
                    : Headers.jsonContentType));

      final Options opts = Options(
        headers: headers,
        responseType: responseType,
        contentType: computedContentType,
      );
      late final Response<dynamic> response;
      switch (method) {
        case RequestType.GET:
          response = await _dio.get(
            endpoint,
            queryParameters: queryParameters,
            options: opts,
          );
          break;
        case RequestType.POST:
          response = await _dio.post(
            endpoint,
            data: payload,
            queryParameters: queryParameters,
            options: opts,
          );
          break;
        case RequestType.PUT:
          response = await _dio.put(
            endpoint,
            data: payload,
            queryParameters: queryParameters,
            options: opts,
          );
          break;
        case RequestType.DELETE:
          response = await _dio.delete(
            endpoint,
            data: payload,
            queryParameters: queryParameters,
            options: opts,
          );
          break;
        case RequestType.PATCH:
          response = await _dio.patch(
            endpoint,
            data: payload,
            queryParameters: queryParameters,
            options: opts,
          );
          break;
      }
      return response;
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async => await Injector.get<SecureStorageUtils>().read('accessToken');

  Future<String?> refreshToken() async {
    final String? currentRefreshToken = await Injector.get<SecureStorageUtils>().read('refreshToken');
    
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw RefreshTokenAuthException('No refresh token available');
    }

    final Dio refreshDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    try {
      final Response<dynamic> response = await refreshDio.post(
        '/auth/refresh',
        data: <String, dynamic>{
          'refreshToken': currentRefreshToken,
        },
      );
      
      if (response.data?['data'] == null) {
        return null;
      }
      
      final Map<String, dynamic> responseData = response.data['data'] as Map<String, dynamic>;
      final String? newAccessToken = responseData['accessToken'] as String?;
      final String? newRefreshToken = responseData['refreshToken'] as String?;
      
      if (newAccessToken == null || newAccessToken.isEmpty) {
        return null;
      }

      await Injector.get<SecureStorageUtils>().write('accessToken', newAccessToken);
      
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await Injector.get<SecureStorageUtils>().write('refreshToken', newRefreshToken);
      }

      return newAccessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw RefreshTokenAuthException('Refresh token expired or invalid');
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final Completer<Response<dynamic>> completer;

  _PendingRequest({
    required this.options,
    required this.handler,
    required this.completer,
  });
}

''';
  static const String _core_enums_server_status_dart = r'''enum ServerStatus {
  none,
  conection_refused,
  available,
  unavailable;
}

''';
  static const String _core_utils_secure_storage_utils_dart = r'''import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtils {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}

''';
  static const String _core_utils_toast_util_dart = r'''import 'package:flutter/material.dart';

class ToastUtil {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

''';
  static const String _core_utils_helpers_number_helper_dart = r'''class NumberHelper {
  static String formatNumber(num value) {
    return value.toStringAsFixed(2);
  }
}

''';
  static const String _core_states_tstateless_dart = r'''import 'package:flutter/material.dart';

abstract class TStateless extends StatelessWidget {
  const TStateless({super.key});
}

''';
  static const String _core_states_tstatefull_dart = r'''import 'package:flutter/material.dart';

abstract class TStateful<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    onInit();
  }

  void onInit() {}
}

''';
  static const String _core_errors_failures_dart = r'''import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

''';
  static const String _core_services_talker_service_dart = r'''import 'package:talker_flutter/talker_flutter.dart';

class TalkerService {
  TalkerService._();
  
  static Talker? _instance;
  
  static Talker init() {
    if (_instance != null) {
      return _instance!;
    }

    _instance = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        useConsoleLogs: false,
        maxHistoryItems: 1000,
      ),
    );

    return _instance!;
  }

  static Talker get instance {
    if (_instance == null) {
      return init();
    }
    return _instance!;
  }

  static void dispose() {
    _instance = null;
  }
}

''';
  static const String _features_home_data_datasources_remote_home_remote_datasource_dart = r'''import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../models/home_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<Either<Failure, List<HomeModel>>> fetchData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<Either<Failure, List<HomeModel>>> fetchData() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final models = [
        const HomeModel(id: '1', title: 'Home Item 1', description: 'Description 1'),
        const HomeModel(id: '2', title: 'Home Item 2', description: 'Description 2'),
      ];
      return Right(models);
    } catch (e) {
      return Left<Failure, List<HomeModel>>(ServerFailure(message: 'Failed to fetch data: $e'));
    }
  }
}

''';
  static const String _features_home_data_repositories_home_repository_impl_dart = r'''import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/remote/home_remote_datasource.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_entity.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.homeRemoteDataSource,
  });

  final HomeRemoteDataSource homeRemoteDataSource;

  @override
  Future<Either<Failure, List<HomeEntity>>> fetchData() async {
    final Either<Failure, List<HomeModel>> result = await homeRemoteDataSource.fetchData();
    return result.fold(
      (Failure failure) => Left<Failure, List<HomeEntity>>(failure),
      (List<HomeModel> models) => Right(models.map((model) => HomeEntity.fromModel(model)).toList()),
    );
  }
}

''';
  static const String _features_home_data_models_home_model_dart = r'''import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
abstract class HomeModel with _$HomeModel {
  const factory HomeModel({
    required String id,
    required String title,
    required String description,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) => _$HomeModelFromJson(json);
}

''';
  static const String _features_home_domain_repositories_home_repository_dart = r'''import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<HomeEntity>>> fetchData();
}

''';
  static const String _features_home_domain_use_cases_home_use_cases_dart = r'''import 'package:dartz/dartz.dart';
import '../repositories/home_repository.dart';
import '../entities/home_entity.dart';
import '../../../../core/errors/failures.dart';

class HomeUseCases {
  const HomeUseCases({
    required HomeRepository repository,
  }) : _homeRepository = repository;

  final HomeRepository _homeRepository;

  Future<Either<Failure, List<HomeEntity>>> fetchData() async => await _homeRepository.fetchData();
}

''';
  static const String _features_home_domain_entities_home_entity_dart = r'''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/home_model.dart';

part 'home_entity.freezed.dart';
part 'home_entity.g.dart';

@freezed
abstract class HomeEntity with _$HomeEntity {
  const factory HomeEntity({
    required String id,
    required String title,
    required String description,
  }) = _HomeEntity;

  factory HomeEntity.fromJson(Map<String, dynamic> json) => _$HomeEntityFromJson(json);

  factory HomeEntity.fromModel(HomeModel model) => HomeEntity(
    id: model.id,
    title: model.title,
    description: model.description,
  );
}

''';
  static const String _features_home_presentation_blocs_home_bloc_home_state_dart = r'''part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default([]) List<HomeEntity> items,
    Failure? failure,
  }) = _HomeState;
}

''';
  static const String _features_home_presentation_blocs_home_bloc_home_bloc_dart = r'''import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/use_cases/home_use_cases.dart';
import '../../../domain/entities/home_entity.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HomeUseCases _homeUseCases;

  HomeBloc({
    required HomeUseCases homeUseCases,
  }) : _homeUseCases = homeUseCases,
       super(const HomeState()) {
    on<HomeEvent>((HomeEvent event, Emitter<HomeState> emit) async {
      await event.map(
        initialized: (e) async {
          emit(state.copyWith(isLoading: true, failure: null));
          final Either<Failure, List<HomeEntity>> result = await _homeUseCases.fetchData();
          result.fold(
            (Failure failure) => emit(
              state.copyWith(failure: failure, isLoading: false),
            ),
            (List<HomeEntity> entities) => emit(
              state.copyWith(items: entities, isLoading: false, failure: null),
            ),
          );
        },
      );
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(HomeState state) => null;
}

''';
  static const String _features_home_presentation_blocs_home_bloc_home_event_dart = r'''part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.initialized() = _Initialized;
}

''';
  static const String _features_home_presentation_pages_home_page_dart = r'''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../../../../application/injector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injector.get<HomeBloc>()..add(const HomeEvent.initialized()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.failure != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.failure!.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const HomeEvent.initialized());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Text('No items available'),
            );
          }

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                leading: CircleAvatar(
                  child: Text(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

''';
  static const String _shared_shared_dart = r'''export 'pages/server_unavailable_page.dart';
export 'widgets/widgets.dart';

''';
  static const String _shared_pages_server_unavailable_page_dart = r'''import 'package:flutter/material.dart';

class ServerUnavailablePage extends StatelessWidget {
  const ServerUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Server Unavailable', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Please try again later'),
          ],
        ),
      ),
    );
  }
}

''';
  static const String _shared_widgets_widgets_dart = r'''export 'app_header.dart';

''';
  static const String _shared_widgets_app_header_dart = r'''import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }
}

''';
  static const String _main_dart = r'''import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nested/nested.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'application/application.dart';
import 'application/injector.dart';
import 'features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'core/services/talker_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (kReleaseMode) {
      debugPrintRebuildDirtyWidgets = false;
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
  } finally {
    await runMainApp();
  }
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: !kIsWeb
        ? HydratedStorageDirectory((await getTemporaryDirectory()).path)
        : HydratedStorageDirectory.web,
  );

  TalkerService.init();

  Injector.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };

  runApp(
    MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<HomeBloc>(
          create: (BuildContext _) => Injector.get<HomeBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.light,
    themeMode: ThemeMode.light,
    routerConfig: AppRoutes.router,
    locale: AppLocalizationsSetup.supportedLocales.last,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
  );
} ''';
  static const String _application_application_dart = r'''export 'injector.dart';
export 'routes/routes.dart';
export 'theme/theme.dart';
export 'theme/app_colors.dart';
export 'l10n/app_localization_setup.dart';
export 'constants/assets.dart';

''';
  static const String _application_l10n_intl_es_arb = r'''{
  "@@locale": "es",
  "appTitle": "{{project_name}}",
  "@appTitle": {
    "description": "El título de la aplicación"
  }
}

''';
  static const String _application_l10n_app_localization_setup_dart = r'''import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../generated/l10n.dart';

class AppLocalizationsSetup {
  static final List<Locale> supportedLocales = S.delegate.supportedLocales;

  static final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

''';
  static const String _application_l10n_intl_en_arb = r'''{
  "@@locale": "en",
  "appTitle": "{{project_name}}",
  "@appTitle": {
    "description": "The application title"
  }
}

''';
  static const String _application_injector_dart = r'''import 'package:get_it/get_it.dart';
import '../core/network/http_client.dart';
import '../core/utils/secure_storage_utils.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/use_cases/home_use_cases.dart';
import '../features/home/presentation/blocs/home_bloc/home_bloc.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/data/datasources/remote/home_remote_datasource.dart';

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
    registerLazySingleton<SecureStorageUtils>(
      () => SecureStorageUtils(),
    );
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

''';
  static const String _application_constants_assets_dart = r'''class Assets {
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
}

''';
  static const String _application_theme_app_colors_dart = r'''import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blue = Color(0xFF4B60AA);
  static const Color lightBlue = Color(0xFF50A2FF);
  static const Color darkBlue = Color(0xFF4F3273);
}

''';
  static const String _application_theme_theme_dart = r'''import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}

''';
  static const String _application_routes_routes_dart = r'''import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';

class Routes {
  const Routes._();
  static const String home = '/home';
}

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get globalContext => _navigatorKey.currentContext;

  static final GoRouter router = GoRouter(
    errorBuilder: (BuildContext context, GoRouterState state) {
      debugPrint('Error en ruta: ${state.error}');
      return Scaffold(
        body: Center(
          child: Text('Error en la ruta: ${state.error}', style: const TextStyle(fontSize: 20)),
        ),
      );
    },
    navigatorKey: _navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.home,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.home,
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
    ],
  );
}

''';

  static Map<String, String> get templates => {
    'core/core.dart': _core_core_dart,
    'core/network/http_client.dart': _core_network_http_client_dart,
    'core/enums/server_status.dart': _core_enums_server_status_dart,
    'core/utils/secure_storage_utils.dart': _core_utils_secure_storage_utils_dart,
    'core/utils/toast_util.dart': _core_utils_toast_util_dart,
    'core/utils/helpers/number_helper.dart': _core_utils_helpers_number_helper_dart,
    'core/states/tstateless.dart': _core_states_tstateless_dart,
    'core/states/tstatefull.dart': _core_states_tstatefull_dart,
    'core/errors/failures.dart': _core_errors_failures_dart,
    'core/services/talker_service.dart': _core_services_talker_service_dart,
    'features/home/data/datasources/remote/home_remote_datasource.dart': _features_home_data_datasources_remote_home_remote_datasource_dart,
    'features/home/data/repositories/home_repository_impl.dart': _features_home_data_repositories_home_repository_impl_dart,
    'features/home/data/models/home_model.dart': _features_home_data_models_home_model_dart,
    'features/home/domain/repositories/home_repository.dart': _features_home_domain_repositories_home_repository_dart,
    'features/home/domain/use_cases/home_use_cases.dart': _features_home_domain_use_cases_home_use_cases_dart,
    'features/home/domain/entities/home_entity.dart': _features_home_domain_entities_home_entity_dart,
    'features/home/presentation/blocs/home_bloc/home_state.dart': _features_home_presentation_blocs_home_bloc_home_state_dart,
    'features/home/presentation/blocs/home_bloc/home_bloc.dart': _features_home_presentation_blocs_home_bloc_home_bloc_dart,
    'features/home/presentation/blocs/home_bloc/home_event.dart': _features_home_presentation_blocs_home_bloc_home_event_dart,
    'features/home/presentation/pages/home_page.dart': _features_home_presentation_pages_home_page_dart,
    'shared/shared.dart': _shared_shared_dart,
    'shared/pages/server_unavailable_page.dart': _shared_pages_server_unavailable_page_dart,
    'shared/widgets/widgets.dart': _shared_widgets_widgets_dart,
    'shared/widgets/app_header.dart': _shared_widgets_app_header_dart,
    'main.dart': _main_dart,
    'application/application.dart': _application_application_dart,
    'application/l10n/intl_es.arb': _application_l10n_intl_es_arb,
    'application/l10n/app_localization_setup.dart': _application_l10n_app_localization_setup_dart,
    'application/l10n/intl_en.arb': _application_l10n_intl_en_arb,
    'application/injector.dart': _application_injector_dart,
    'application/constants/assets.dart': _application_constants_assets_dart,
    'application/theme/app_colors.dart': _application_theme_app_colors_dart,
    'application/theme/theme.dart': _application_theme_theme_dart,
    'application/routes/routes.dart': _application_routes_routes_dart,
  };

  static String _processTemplate(String content, String projectName) {
    return content
        .replaceAll('{{project_name}}', projectName)
        .replaceAll('template_project', projectName);
  }

  static Map<String, String> getProcessedTemplates(String projectName) {
    return templates.map((key, value) => MapEntry(key, _processTemplate(value, projectName)));
  }
}
