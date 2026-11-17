import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  /// Retrieve current active shopping cart items & subtotal
  Future<ApiResponse> getCart() async {
    return await ApiClient.get(ApiEndpoints.customerCart);
  }

  /// Add produce item to shopping cart in MySQL
  Future<ApiResponse> addToCart(int productId, {double quantity = 1.0}) async {
    return await ApiClient.post(
      ApiEndpoints.customerCart,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  /// Update item quantity in cart
  Future<ApiResponse> updateQuantity(int cartItemId, double quantity) async {
    return await ApiClient.put(
      ApiEndpoints.customerCartItem(cartItemId),
      body: {
        'quantity': quantity,
      },
    );
  }

  /// Remove item from cart
  Future<ApiResponse> removeItem(int cartItemId) async {
    return await ApiClient.delete(ApiEndpoints.customerCartItem(cartItemId));
  }
}

