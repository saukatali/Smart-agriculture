import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'agrismart_auth_token';
  static const String _userKey = 'agrismart_auth_user';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static String? _cachedToken;
  static Map<String, dynamic>? _cachedUser;

  /// Initializes token storage from FlutterSecureStorage on app startup.
  static Future<void> init() async {
    String? token;
    String? userJson;

    try {
      token = await _secureStorage.read(key: _tokenKey);
      userJson = await _secureStorage.read(key: _userKey);
    } on MissingPluginException {
      // Headless VM test fallback when platform channels are unavailable
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
      userJson = prefs.getString(_userKey);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_tokenKey);
      userJson = prefs.getString(_userKey);
    }

    _cachedToken = (token != null && token.isNotEmpty) ? token : null;
    if (userJson != null && userJson.isNotEmpty) {
      try {
        _cachedUser = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        _cachedUser = null;
      }
    } else {
      _cachedUser = null;
    }
  }

  /// Returns active JWT token (cached in memory)
  static String? get token => _cachedToken;

  /// Returns current authenticated user payload
  static Map<String, dynamic>? get currentUser => _cachedUser;

  /// Check whether user has a token stored locally
  static bool get isAuthenticated => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Get current user role ('farmer', 'customer', 'admin')
  static String get userRole => _cachedUser?['role']?.toString().toLowerCase() ?? 'customer';

  /// Save JWT token and user profile securely
  static Future<void> saveAuth({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    _cachedToken = token;
    _cachedUser = user;
    final encodedUser = jsonEncode(user);

    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userKey, value: encodedUser);
    } on MissingPluginException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, encodedUser);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, encodedUser);
    }
  }

  /// Remove auth state on logout or token invalidation
  static Future<void> clearAuth() async {
    _cachedToken = null;
    _cachedUser = null;

    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
    } on MissingPluginException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }
}
