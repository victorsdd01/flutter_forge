import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../application/injector.dart';
import '../services/talker_service.dart';
import '../utils/secure_storage_utils.dart';
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
        } on RefreshTokenAuthException {
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
    } on DioException {
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

