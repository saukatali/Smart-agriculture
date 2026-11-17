import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  /// Discover marketplace categories
  Future<ApiResponse> getCategories() async {
    return await ApiClient.get(ApiEndpoints.customerCategories);
  }

  /// List products with optional category and search query filters
  Future<ApiResponse> getProducts({dynamic categoryId, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.toString().isNotEmpty) {
      queryParams['categoryId'] = categoryId.toString();
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    return await ApiClient.get(
      ApiEndpoints.customerProducts,
      queryParams: queryParams,
    );
  }

  /// Get product details by ID
  Future<ApiResponse> getProductById(int id) async {
    return await ApiClient.get(ApiEndpoints.customerProductById(id));
  }

  /// Discover verified organic farmers nearby
  Future<ApiResponse> getNearbyFarmers() async {
    return await ApiClient.get(ApiEndpoints.customerFarmers);
  }

  /// Get customer's past orders
  Future<ApiResponse> getOrders() async {
    return await ApiClient.get(ApiEndpoints.customerOrders);
  }
}

