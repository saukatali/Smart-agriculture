import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class InsightService {
  static final InsightService _instance = InsightService._internal();
  factory InsightService() => _instance;
  InsightService._internal();

  /// Retrieve AI crop price and demand predictions for selected forecast window
  Future<ApiResponse> getPredictions({String window = '7 Days'}) async {
    return await ApiClient.get(
      ApiEndpoints.insightsPredictions,
      queryParams: {'window': window},
    );
  }

  /// Retrieve actionable smart selling recommendations
  Future<ApiResponse> getRecommendations() async {
    return await ApiClient.get(ApiEndpoints.insightsRecommendations);
  }

  /// Apply recommendation strategy to supply chain/farmer operations
  Future<ApiResponse> applyStrategy(int id) async {
    return await ApiClient.post(ApiEndpoints.insightsApplyStrategy(id));
  }

  /// Get real-time system and weather notifications
  Future<ApiResponse> getNotifications() async {
    return await ApiClient.get(ApiEndpoints.notifications);
  }

  /// Mark specific notification as read
  Future<ApiResponse> markNotificationRead(int id) async {
    return await ApiClient.put(ApiEndpoints.notificationRead(id));
  }
}

