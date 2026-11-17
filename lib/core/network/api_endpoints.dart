class ApiEndpoints {
  // Optional compile-time override:
  // flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  // Centralized FastAPI backend base URL for USB ADB reverse port forwarding
  // (`adb reverse tcp:8000 tcp:8000`) and local development.
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api';

  // Override custom base URL at runtime if needed
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    return defaultBaseUrl;
  }

  static String get health => '$baseUrl/health';

  // Auth
  static String get authLogin => '$baseUrl/auth/login';
  static String get authRegister => '$baseUrl/auth/register';
  static String get authLogout => '$baseUrl/auth/logout';
  static String get authMe => '$baseUrl/auth/me';

  // Farmer
  static String get farmerDashboard => '$baseUrl/farmer/dashboard';
  static String get farmerSalesHistory => '$baseUrl/farmer/sales-history';
  static String get farmerProducts => '$baseUrl/farmer/products';
  static String farmerProductById(int id) => '$baseUrl/farmer/products/$id';
  static String get farmerOrders => '$baseUrl/farmer/orders';
  static String farmerOrderStatus(int id) => '$baseUrl/farmer/orders/$id/status';

  // Customer
  static String get customerCategories => '$baseUrl/customer/categories';
  static String get customerProducts => '$baseUrl/customer/products';
  static String customerProductById(int id) => '$baseUrl/customer/products/$id';
  static String get customerFarmers => '$baseUrl/customer/farmers';
  static String get customerCart => '$baseUrl/customer/cart';
  static String customerCartItem(int id) => '$baseUrl/customer/cart/$id';
  static String get customerCheckout => '$baseUrl/customer/checkout';
  static String get customerOrders => '$baseUrl/customer/orders';

  // Admin
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminModeration => '$baseUrl/admin/moderation';
  static String adminModerationResolve(int id) => '$baseUrl/admin/moderation/$id';
  static String get adminCompliance => '$baseUrl/admin/compliance';
  static String adminComplianceRenew(int id) => '$baseUrl/admin/compliance/$id/renew';
  static String get adminOrders => '$baseUrl/admin/orders';
  static String get adminBroadcast => '$baseUrl/admin/broadcast';

  // Insights
  static String get insightsPredictions => '$baseUrl/insights/predictions';
  static String get insightsRecommendations => '$baseUrl/insights/recommendations';
  static String insightsApplyStrategy(int id) => '$baseUrl/insights/apply-strategy/$id';

  // Notifications
  static String get notifications => '$baseUrl/notifications';
  static String notificationRead(int id) => '$baseUrl/notifications/$id/read';
}
