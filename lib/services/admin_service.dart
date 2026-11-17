import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  /// Retrieve full platform overview, KPIs, dispute reports, and compliance records
  Future<ApiResponse> getDashboard() async {
    return await ApiClient.get(ApiEndpoints.adminDashboard);
  }

  /// Get pending moderation queue
  Future<ApiResponse> getModerationReports() async {
    return await ApiClient.get(ApiEndpoints.adminModeration);
  }

  /// Resolve or dismiss user moderation dispute report
  Future<ApiResponse> resolveModerationReport(int reportId, {String status = 'Resolved'}) async {
    return await ApiClient.put(
      ApiEndpoints.adminModerationResolve(reportId),
      body: {'status': status},
    );
  }

  /// Get list of suppliers and compliance certificate statuses
  Future<ApiResponse> getSupplierCompliance() async {
    return await ApiClient.get(ApiEndpoints.adminCompliance);
  }

  /// Renew supplier organic/FSSAI certification
  Future<ApiResponse> renewSupplierCompliance(int supplierId) async {
    return await ApiClient.put(ApiEndpoints.adminComplianceRenew(supplierId));
  }

  /// Fetch all system-wide orders across the platform
  Future<ApiResponse> getAllOrders() async {
    return await ApiClient.get(ApiEndpoints.adminOrders);
  }

  /// Broadcast urgent weather advisory or platform alert to all users
  Future<ApiResponse> broadcastAlert(String title, String message, {String targetRole = 'all'}) async {
    return await ApiClient.post(
      ApiEndpoints.adminBroadcast,
      body: {
        'title': title,
        'message': message,
        'targetRole': targetRole,
      },
    );
  }
}

