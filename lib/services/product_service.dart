import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  /// Discover all produce categories
  Future<ApiResponse> getCategories() async {
    return await ApiClient.get(ApiEndpoints.customerCategories);
  }

  /// Discover available products
  Future<ApiResponse> getProducts({
    dynamic categoryId,
    String? search,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.toString().isNotEmpty) {
      queryParams['categoryId'] = categoryId.toString();
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return await ApiClient.get(
      ApiEndpoints.customerProducts,
      queryParams: queryParams,
    );
  }

  /// Get details of single product
  Future<ApiResponse> getProductById(int id) async {
    return await ApiClient.get(ApiEndpoints.customerProductById(id));
  }

  /// Create new product listing (Farmer)
  Future<ApiResponse> createProduct(Map<String, dynamic> data) async {
    return await ApiClient.post(ApiEndpoints.farmerProducts, body: data);
  }

  /// Update existing product
  Future<ApiResponse> updateProduct(int id, Map<String, dynamic> data) async {
    return await ApiClient.put(ApiEndpoints.farmerProductById(id), body: data);
  }

  /// Delete product listing
  Future<ApiResponse> deleteProduct(int id) async {
    return await ApiClient.delete(ApiEndpoints.farmerProductById(id));
  }
}

