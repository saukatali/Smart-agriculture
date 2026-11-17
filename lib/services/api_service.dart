import '../core/network/api_client.dart';
import 'auth_service.dart';
import 'farmer_service.dart';
import 'customer_service.dart';
import 'product_service.dart';
import 'cart_service.dart';
import 'order_service.dart';
import 'admin_service.dart';
import 'insight_service.dart';

export '../core/network/api_client.dart';
export 'auth_service.dart';
export 'farmer_service.dart';
export 'customer_service.dart';
export 'product_service.dart';
export 'cart_service.dart';
export 'order_service.dart';
export 'admin_service.dart';
export 'insight_service.dart';

/// Centralized ApiService façade delegating to specialized services
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _auth = AuthService();
  final FarmerService _farmer = FarmerService();
  final CustomerService _customer = CustomerService();
  final ProductService _product = ProductService();
  final CartService _cart = CartService();
  final OrderService _order = OrderService();
  final AdminService _admin = AdminService();
  final InsightService _insight = InsightService();

  // -------------------------------------------------------------
  // AUTH
  // -------------------------------------------------------------
  Future<ApiResponse> login(String email, String password) =>
      _auth.login(email, password);

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
  }) =>
      _auth.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        phone: phone,
        location: location,
        farmName: farmName,
        farmLocation: farmLocation,
      );

  Future<void> logout() => _auth.logout();

  Future<ApiResponse> getMe() => _auth.getMe();

  // -------------------------------------------------------------
  // FARMER
  // -------------------------------------------------------------
  Future<ApiResponse> getFarmerDashboard() => _farmer.getDashboard();

  Future<ApiResponse> getFarmerSalesHistory() => _farmer.getSalesHistory();

  Future<ApiResponse> getFarmerProducts() => _farmer.getProducts();

  Future<ApiResponse> addFarmerProduct(Map<String, dynamic> productData) =>
      _farmer.addProduct(productData);

  Future<ApiResponse> getFarmerOrders() => _farmer.getOrders();

  Future<ApiResponse> updateOrderStatus(int orderId, String status) =>
      _farmer.updateOrderStatus(orderId, status);

  // -------------------------------------------------------------
  // CUSTOMER / MARKETPLACE
  // -------------------------------------------------------------
  Future<ApiResponse> getCustomerCategories() => _customer.getCategories();

  Future<ApiResponse> getCustomerProducts({dynamic categoryId, String? search}) =>
      _customer.getProducts(categoryId: categoryId, search: search);

  Future<ApiResponse> getProductById(int id) => _customer.getProductById(id);

  Future<ApiResponse> createProduct(Map<String, dynamic> data) =>
      _product.createProduct(data);

  Future<ApiResponse> updateProduct(int id, Map<String, dynamic> data) =>
      _product.updateProduct(id, data);

  Future<ApiResponse> deleteProduct(int id) => _product.deleteProduct(id);

  Future<ApiResponse> getNearbyFarmers() => _customer.getNearbyFarmers();

  Future<ApiResponse> getCart() => _cart.getCart();

  Future<ApiResponse> addToCart(int productId, {double quantity = 1}) =>
      _cart.addToCart(productId, quantity: quantity);

  Future<ApiResponse> updateCartItem(int cartItemId, double quantity) =>
      _cart.updateQuantity(cartItemId, quantity);

  Future<ApiResponse> removeFromCart(int cartItemId) =>
      _cart.removeItem(cartItemId);

  Future<ApiResponse> checkout({
    String deliveryAddress = 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat',
    String paymentMethod = 'COD',
    String customerName = 'Priya Sharma',
    String customerMobile = '+91 98765 43212',
    Map<String, dynamic>? directItem,
  }) =>
      _order.checkout(
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        customerName: customerName,
        customerMobile: customerMobile,
        directItem: directItem,
      );

  Future<ApiResponse> getCustomerOrders() => _customer.getOrders();

  // -------------------------------------------------------------
  // ADMIN CONTROL CENTER
  // -------------------------------------------------------------
  Future<ApiResponse> getAdminDashboard() => _admin.getDashboard();

  Future<ApiResponse> getModerationReports() => _admin.getModerationReports();

  Future<ApiResponse> resolveModerationReport(int reportId, {String status = 'Resolved'}) =>
      _admin.resolveModerationReport(reportId, status: status);

  Future<ApiResponse> getSupplierCompliance() => _admin.getSupplierCompliance();

  Future<ApiResponse> renewSupplierCompliance(int supplierId) =>
      _admin.renewSupplierCompliance(supplierId);

  Future<ApiResponse> getAdminOrders() => _admin.getAllOrders();

  Future<ApiResponse> broadcastAlert(String title, String message, {String targetRole = 'all'}) =>
      _admin.broadcastAlert(title, message, targetRole: targetRole);

  // -------------------------------------------------------------
  // AI INSIGHTS
  // -------------------------------------------------------------
  Future<ApiResponse> getPredictions({String window = '7 Days'}) =>
      _insight.getPredictions(window: window);

  Future<ApiResponse> getRecommendations() => _insight.getRecommendations();

  Future<ApiResponse> applyStrategy(int id) => _insight.applyStrategy(id);

  // -------------------------------------------------------------
  // NOTIFICATIONS
  // -------------------------------------------------------------
  Future<ApiResponse> getNotifications() => _insight.getNotifications();

  Future<ApiResponse> markNotificationRead(int id) =>
      _insight.markNotificationRead(id);
}
