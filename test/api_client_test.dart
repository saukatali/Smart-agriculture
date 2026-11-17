import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrismart/core/storage/token_storage.dart';
import 'package:agrismart/core/network/api_endpoints.dart';
import 'package:agrismart/core/network/api_exceptions.dart';
import 'package:agrismart/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage & Network Architecture Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await TokenStorage.init();
    });

    test('Initial auth state is empty', () {
      expect(TokenStorage.isAuthenticated, isFalse);
      expect(TokenStorage.token, isNull);
      expect(TokenStorage.currentUser, isNull);
    });

    test('Save and clear auth tokens correctly', () async {
      await TokenStorage.saveAuth(
        token: 'test_jwt_token_sample',
        user: {'id': 1, 'name': 'Rajesh Kumar', 'role': 'farmer'},
      );

      expect(TokenStorage.isAuthenticated, isTrue);
      expect(TokenStorage.token, 'test_jwt_token_sample');
      expect(TokenStorage.currentUser?['name'], 'Rajesh Kumar');
      expect(TokenStorage.userRole, 'farmer');

      await TokenStorage.clearAuth();
      expect(TokenStorage.isAuthenticated, isFalse);
      expect(TokenStorage.token, isNull);
    });

    test('ApiEndpoints default to 127.0.0.1:8000 for USB ADB reverse', () {
      ApiEndpoints.customBaseUrl = null;
      expect(ApiEndpoints.baseUrl, 'http://127.0.0.1:8000/api');
      expect(ApiEndpoints.authLogin, 'http://127.0.0.1:8000/api/auth/login');
      expect(ApiEndpoints.authRegister, 'http://127.0.0.1:8000/api/auth/register');
      expect(ApiEndpoints.farmerDashboard, 'http://127.0.0.1:8000/api/farmer/dashboard');
      expect(ApiEndpoints.customerProducts, 'http://127.0.0.1:8000/api/customer/products');
      expect(ApiEndpoints.customerCart, 'http://127.0.0.1:8000/api/customer/cart');
      expect(ApiEndpoints.adminDashboard, 'http://127.0.0.1:8000/api/admin/dashboard');
      expect(ApiEndpoints.insightsPredictions, 'http://127.0.0.1:8000/api/insights/predictions');

      // Test custom base URL override
      ApiEndpoints.customBaseUrl = 'http://192.168.1.50:8000/api';
      expect(ApiEndpoints.authLogin, 'http://192.168.1.50:8000/api/auth/login');
      ApiEndpoints.customBaseUrl = null;
    });

    test('ApiClient configures expected Dio timeouts', () {
      expect(ApiClient.dio.options.connectTimeout, const Duration(seconds: 15));
      expect(ApiClient.dio.options.receiveTimeout, const Duration(seconds: 20));
      expect(ApiClient.dio.options.sendTimeout, const Duration(seconds: 15));
    });

    test('ApiException maps timeout, connectionError, and validation list clearly', () {
      final req = RequestOptions(path: '/api/auth/login');

      final timeoutEx = ApiException.fromDioException(
        DioException(requestOptions: req, type: DioExceptionType.connectionTimeout),
      );
      expect(timeoutEx.statusCode, 408);
      expect(timeoutEx.message, contains('adb reverse tcp:8000 tcp:8000'));

      final connEx = ApiException.fromDioException(
        DioException(
          requestOptions: req,
          type: DioExceptionType.connectionError,
          error: const SocketException('Connection refused'),
        ),
      );
      expect(connEx.statusCode, 503);
      expect(connEx.message, contains('connection refused'));

      final validationEx = ApiException.fromDioException(
        DioException(
          requestOptions: req,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: req,
            statusCode: 422,
            data: {
              'detail': [
                {'msg': 'value is not a valid email address'}
              ],
            },
          ),
        ),
      );
      expect(validationEx.statusCode, 422);
      expect(validationEx.message, 'value is not a valid email address');
    });

    test('ApiResponse parses properly', () {
      final res = ApiResponse(
        success: true,
        statusCode: 200,
        data: {'status': 'healthy'},
        message: 'Success',
      );
      expect(res.success, isTrue);
      expect(res.statusCode, 200);
      expect(res.data['status'], 'healthy');
    });

    test('ApiService modular delegations are instantiated', () {
      final api = ApiService();
      expect(api, isNotNull);
    });
  });
}
