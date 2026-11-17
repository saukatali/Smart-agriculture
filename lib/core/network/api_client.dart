import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import 'api_exceptions.dart';

class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message = '',
  });

  @override
  String toString() => 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
}

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;

  static bool _initialized = false;
  static VoidCallback? onUnauthorized;

  /// Initializes Dio client with interceptors and loads persisted token.
  static Future<void> init() async {
    if (_initialized) return;

    await TokenStorage.init();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('[Dio Request] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[Dio Response] ${response.statusCode} from ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint('[Dio Error] ${error.type} at ${error.requestOptions.uri}: ${error.message}');
          }
          final status = error.response?.statusCode;
          final path = error.requestOptions.uri.path;
          if (status == 401 &&
              !path.endsWith('/auth/login') &&
              !path.endsWith('/auth/register')) {
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  // Token delegation helpers
  static String? get token => TokenStorage.token;
  static Map<String, dynamic>? get currentUser => TokenStorage.currentUser;
  static Future<void> saveAuth({required String token, required Map<String, dynamic> user}) =>
      TokenStorage.saveAuth(token: token, user: user);
  static Future<void> clearAuth() => TokenStorage.clearAuth();

  static Future<ApiResponse> get(
    String url, {
    Map<String, dynamic>? queryParams,
  }) async {
    await init();
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Unexpected network error: $e',
      );
    }
  }

  static Future<ApiResponse> post(
    String url, {
    dynamic body,
  }) async {
    await init();
    try {
      final response = await _dio.post(
        url,
        data: body,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Unexpected network error: $e',
      );
    }
  }

  static Future<ApiResponse> put(
    String url, {
    dynamic body,
  }) async {
    await init();
    try {
      final response = await _dio.put(
        url,
        data: body,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Unexpected network error: $e',
      );
    }
  }

  static Future<ApiResponse> delete(String url) async {
    await init();
    try {
      final response = await _dio.delete(url);
      return _processResponse(response);
    } on DioException catch (e) {
      return _processError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Unexpected network error: $e',
      );
    }
  }

  static ApiResponse _processResponse(Response response) {
    final data = response.data;
    final statusCode = response.statusCode ?? 200;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    String msg = isSuccess ? 'Success' : 'Request completed with code $statusCode';
    if (data is Map) {
      if (data['message'] != null) {
        msg = data['message'].toString();
      } else if (data['detail'] != null) {
        msg = data['detail'].toString();
      }
    }

    return ApiResponse(
      success: isSuccess && (data is Map ? (data['success'] ?? true) : true),
      statusCode: statusCode,
      data: data,
      message: msg,
    );
  }

  static ApiResponse _processError(DioException dioError) {
    final apiEx = ApiException.fromDioException(dioError);
    return ApiResponse(
      success: false,
      statusCode: apiEx.statusCode ?? 0,
      data: apiEx.details,
      message: apiEx.message,
    );
  }
}
