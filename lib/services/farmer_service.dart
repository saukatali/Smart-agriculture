import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class FarmerService {
  static final FarmerService _instance = FarmerService._internal();
  factory FarmerService() => _instance;
  FarmerService._internal();

  /// Fetch dashboard metrics, revenue, sales history, active listings
  Future<ApiResponse> getDashboard() async {
    return await ApiClient.get(ApiEndpoints.farmerDashboard);
  }

  /// Fetch 7-day weekly sales performance history
  Future<ApiResponse> getSalesHistory() async {
    return await ApiClient.get(ApiEndpoints.farmerSalesHistory);
  }

  /// List products published by this farmer
  Future<ApiResponse> getProducts() async {
    return await ApiClient.get(ApiEndpoints.farmerProducts);
  }

  /// Publish a new agricultural listing to MySQL
  Future<ApiResponse> addProduct(Map<String, dynamic> productData) async {
    return await ApiClient.post(
      ApiEndpoints.farmerProducts,
      body: productData,
    );
  }

  /// Get orders placed for this farmer's produce
  Future<ApiResponse> getOrders() async {
    return await ApiClient.get(ApiEndpoints.farmerOrders);
  }

  /// Update order fulfillment status ('confirmed', 'shipped', 'delivered', 'cancelled')
  Future<ApiResponse> updateOrderStatus(int orderId, String status) async {
    return await ApiClient.put(
      ApiEndpoints.farmerOrderStatus(orderId),
      body: {'status': status},
    );
  }
}

