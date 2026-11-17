import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  /// Place order / checkout cart to MySQL
  Future<ApiResponse> checkout({
    String deliveryAddress = 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat',
    String paymentMethod = 'COD',
    String customerName = 'Priya Sharma',
    String customerMobile = '+91 98765 43212',
    Map<String, dynamic>? directItem,
  }) async {
    return await ApiClient.post(
      ApiEndpoints.customerCheckout,
      body: {
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'customerName': customerName,
        'customerMobile': customerMobile,
        if (directItem != null) 'directItem': directItem,
      },
    );
  }

  /// Customer past orders
  Future<ApiResponse> getCustomerOrders() async {
    return await ApiClient.get(ApiEndpoints.customerOrders);
  }

  /// Farmer incoming orders
  Future<ApiResponse> getFarmerOrders() async {
    return await ApiClient.get(ApiEndpoints.farmerOrders);
  }

  /// Update order status
  Future<ApiResponse> updateOrderStatus(int orderId, String status) async {
    return await ApiClient.put(
      ApiEndpoints.farmerOrderStatus(orderId),
      body: {'status': status},
    );
  }
}

