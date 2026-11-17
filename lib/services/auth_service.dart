import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/token_storage.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    ApiClient.onUnauthorized = _handleUnauthorized;
  }

  bool _isCheckingSession = false;

  bool get isCheckingSession => _isCheckingSession;

  /// Check whether user is currently authenticated
  bool get isAuthenticated => TokenStorage.isAuthenticated && !_isTokenExpired(TokenStorage.token);

  /// Get current user profile data
  Map<String, dynamic>? get currentUser => TokenStorage.currentUser;

  /// Get active AppRole from persisted user
  AppRole get currentRole {
    final role = TokenStorage.userRole;
    if (role == 'farmer') return AppRole.farmer;
    if (role == 'admin') return AppRole.admin;
    return AppRole.customer;
  }

  void _handleUnauthorized() {
    if (TokenStorage.isAuthenticated) {
      TokenStorage.clearAuth().then((_) => notifyListeners());
    }
  }

  /// Checks locally whether a JWT exp claim is expired.
  bool _isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadJson);
      if (payload is Map && payload['exp'] != null) {
        final expSeconds = int.tryParse(payload['exp'].toString());
        if (expSeconds != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
          return DateTime.now().toUtc().isAfter(expiry);
        }
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  /// Validates the stored session against `GET /api/auth/me` on app startup.
  Future<bool> validateSession() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      await ApiClient.init();
      final token = TokenStorage.token;
      if (token == null || token.isEmpty || _isTokenExpired(token)) {
        await TokenStorage.clearAuth();
        return false;
      }

      final response = await ApiClient.get(ApiEndpoints.authMe);
      if (response.success && response.data is Map) {
        final userMap = response.data['user'] is Map
            ? Map<String, dynamic>.from(response.data['user'] as Map)
            : Map<String, dynamic>.from(response.data as Map);
        await TokenStorage.saveAuth(token: token, user: userMap);
        return true;
      }

      if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 404) {
        await TokenStorage.clearAuth();
        return false;
      }

      // If server is temporarily unreachable, keep valid non-expired local session if cached user exists
      return TokenStorage.currentUser != null;
    } catch (_) {
      return false;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  /// Login with email and password against FastAPI + MySQL
  Future<ApiResponse> login(String email, String password) async {
    final response = await ApiClient.post(
      ApiEndpoints.authLogin,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.success && response.data is Map) {
      final token = response.data['access_token'] ?? response.data['token'];
      final user = response.data['user'] as Map<String, dynamic>? ?? {};
      if (token != null) {
        await TokenStorage.saveAuth(
          token: token.toString(),
          user: user,
        );
        notifyListeners();
      }
    }
    return response;
  }

  /// Register new user in MySQL (`agrisokat.users`).
  /// Does not leave the user auto-logged-in so they explicitly sign in, or caller can choose flow.
  Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    String? confirmPassword,
    String role = 'customer',
    String phone = '',
    String location = 'Ahmedabad, Gujarat',
    String? farmName,
    String? farmLocation,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.authRegister,
      body: {
        'full_name': name.trim(),
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (confirmPassword != null) 'confirm_password': confirmPassword,
        'role': role,
        'phone': phone.trim(),
        'location': location,
        if (farmName != null) 'farmName': farmName,
        if (farmLocation != null) 'farmLocation': farmLocation,
      },
    );
    return response;
  }

  /// Get authenticated user profile details from backend
  Future<ApiResponse> getMe() async {
    return await ApiClient.get(ApiEndpoints.authMe);
  }

  /// Logout, revoke JWT token on backend, and clear secure storage
  Future<void> logout() async {
    try {
      if (TokenStorage.token != null) {
        await ApiClient.post(ApiEndpoints.authLogout);
      }
    } catch (_) {}
    await TokenStorage.clearAuth();
    notifyListeners();
  }
}
