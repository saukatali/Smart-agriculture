import 'dart:io' show SocketException;
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message:
              'Connection timed out contacting the AgriSmart backend. Ensure FastAPI is running on port 8000 and run: adb reverse tcp:8000 tcp:8000',
          statusCode: 408,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request timed out while sending data to the server. Please try again.',
          statusCode: 408,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message:
              'Server took too long to respond. Verify FastAPI and MySQL are running normally and try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        final data = dioError.response?.data;
        return ApiException(
          message: _extractBadResponseMessage(status, data),
          statusCode: status,
          details: data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: 499,
        );
      case DioExceptionType.connectionError:
        return _connectionFailure(dioError);
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate verification failed.',
          statusCode: 495,
        );
      case DioExceptionType.unknown:
      default:
        if (dioError.error is SocketException) {
          return _connectionFailure(dioError);
        }
        final underlying = dioError.error?.toString();
        final fallback = dioError.message?.isNotEmpty == true
            ? dioError.message!
            : (underlying?.isNotEmpty == true
                ? underlying!
                : 'An unexpected network error occurred.');
        return ApiException(
          message: fallback,
          statusCode: dioError.response?.statusCode ?? 500,
        );
    }
  }

  static ApiException _connectionFailure(DioException dioError) {
    final errText = '${dioError.error ?? ''} ${dioError.message ?? ''}'.toLowerCase();
    if (errText.contains('connection refused')) {
      return ApiException(
        message:
            'Cannot reach AgriSmart backend on 127.0.0.1:8000 (connection refused). Start FastAPI on port 8000 and ensure ADB reverse is active: adb reverse tcp:8000 tcp:8000',
        statusCode: 503,
      );
    }
    return ApiException(
      message:
          'Unable to connect to the AgriSmart backend (127.0.0.1:8000). Check your USB connection, FastAPI server, and run: adb reverse tcp:8000 tcp:8000',
      statusCode: 503,
    );
  }

  static String _extractBadResponseMessage(int? status, dynamic data) {
    String errMsg = 'Request failed with status $status';
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return detail.first.toString();
      }
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      final err = data['error']?.toString();
      if (err != null && err.isNotEmpty) {
        return err;
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return errMsg;
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
