import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../widgets/agrismart_app_bar.dart';
import '../widgets/agrismart_bottom_nav.dart';
import '../widgets/custom_bar_chart.dart';
import '../widgets/admin_actions_sheet.dart';
import '../widgets/farmer_orders_sheet.dart';
import '../widgets/notifications_sheet.dart';
import '../services/api_service.dart';

class AdminControlCenterScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;
  final int currentNavIndex;

  const AdminControlCenterScreen({
    super.key,
    this.onNavTap,
    this.currentNavIndex = 4,
  });

  @override
  State<AdminControlCenterScreen> createState() => _AdminControlCenterScreenState();
}

class _AdminControlCenterScreenState extends State<AdminControlCenterScreen> {
  List<AdminMetric> _kpis = const [
    AdminMetric(
      title: 'TOTAL REVENUE',
      value: '₹142,800',
      subtext: '+18.2% MoM',
      icon: Icons.trending_up,
      isPositive: true,
    ),
    AdminMetric(
      title: 'TOTAL USERS',
      value: '12,450',
      subtext: '1.4k Farmers • 10.8k Cust',
      icon: Icons.people_outline,
    ),
    AdminMetric(
      title: 'PRODUCTS LISTED',
      value: '4,520',
      subtext: '98% Active Quality',
      icon: Icons.inventory_2_outlined,
    ),
    AdminMetric(
      title: 'ACTIVE ORDERS',
      value: '342',
      subtext: '12 in transit',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final res = await ApiService().getAdminDashboard();
      if (res.success && res.data is Map && res.data['kpis'] != null) {
        final kpis = res.data['kpis'];
        setState(() {
          _kpis = [
            AdminMetric(
              title: 'GROSS MERCHANDISE',
              value: kpis['grossMerchandiseValue']?.toString() ?? '₹84.2L',
              subtext: kpis['gmvSubtitle']?.toString() ?? 'Across 4 hubs',
              icon: Icons.trending_up,
              isPositive: true,
            ),
            AdminMetric(
              title: 'TOTAL ACTIVE USERS',
              value: kpis['activeUsers']?.toString() ?? '12,450',
              subtext: kpis['activeUsersSubtitle']?.toString() ?? '+18% this month',
              icon: Icons.people_outline,
            ),
            AdminMetric(
              title: 'DISPUTED ORDERS',
              value: kpis['disputedOrders']?.toString() ?? '18',
              subtext: kpis['disputesSubtitle']?.toString() ?? '3 urgent review',
              icon: Icons.inventory_2_outlined,
            ),
            AdminMetric(
              title: 'PLATFORM UPTIME',
              value: kpis['platformUptime']?.toString() ?? '99.9%',
              subtext: kpis['uptimeSubtitle']?.toString() ?? '0 incidents today',
              icon: Icons.local_shipping_outlined,
            ),
          ];
        });
      }
    } catch (_) {}
  }

  final List<BarData> _revenueWeekly = const [
    BarData(day: 'Mon', value: 0.40, label: '₹18k'),
    BarData(day: 'Tue', value: 0.55, label: '₹22k'),
    BarData(day: 'Wed', value: 0.65, label: '₹27k'),
    BarData(day: 'Thu', value: 0.60, label: '₹24k'),
    BarData(day: 'Fri', value: 0.80, label: '₹31k'),
    BarData(day: 'Sat', value: 0.70, label: '₹28k'),
    BarData(day: 'Sun', value: 0.95, label: '₹38k'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(
        onNotificationTap: () => NotificationsSheet.show(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Systems Normal Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBgDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF86EFAC),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ALL SYSTEMS NORMAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF86EFAC),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Control Center',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4 Key KPI Metrics Cards (2x2 Grid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.45,
                ),
                itemCount: _kpis.length,
                itemBuilder: (context, index) {
                  final kpi = _kpis[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              kpi.title,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Icon(
                              kpi.icon,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        Text(
                          kpi.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            if (index == 0) ...[
                              const Icon(
                                Icons.arrow_upward,
                                size: 10,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 2),
                            ],
                            if (index == 2) ...[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              kpi.subtext,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: index == 0
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Revenue Growth Bar Chart
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Revenue Growth',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Weekly performance overview',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Live Data',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomBarChart(
                      bars: _revenueWeekly,
                      activeIndex: 6, // Sunday is active
                      height: 90,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Management Portal Section
              const Text(
                'Management Portal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              _buildManagementItem(
                icon: Icons.shield_outlined,
                title: 'User Moderation',
                subtitle: '14 pending approvals & flag reports',
                onTap: () => AdminActionsSheet.showModerationQueue(context, onUpdated: _loadDashboard),
              ),
              const SizedBox(height: 8),

              _buildManagementItem(
                icon: Icons.verified_outlined,
                title: 'Supplier Compliance',
                subtitle: '6 certifications due for renewal',
                onTap: () => AdminActionsSheet.showSupplierCompliance(context, onUpdated: _loadDashboard),
              ),
              const SizedBox(height: 8),

              _buildManagementItem(
                icon: Icons.local_shipping_outlined,
                title: 'Order Logistics & Hubs',
                subtitle: 'Manage dispatch centers & carriers',
                onTap: () => FarmerOrdersSheet.show(context, onOrdersUpdated: _loadDashboard),
              ),
              const SizedBox(height: 16),

              // Platform Health Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Health',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Icon(
                          Icons.monitor_heart_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHealthProgress(
                      label: 'Server Load (CPU)',
                      valueText: '24%',
                      progress: 0.24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildHealthProgress(
                      label: 'Database Latency',
                      valueText: '14ms',
                      progress: 0.18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildHealthProgress(
                      label: 'Cloud Storage',
                      valueText: '62% (1.8 TB / 2 TB)',
                      progress: 0.62,
                      color: const Color(0xFF92400E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Broadcast Alert Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Broadcast Alert',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Send weather warning to active farmers',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => AdminActionsSheet.showBroadcastDialog(context, onSent: _loadDashboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AgriSmartBottomNav(
        currentIndex: widget.currentNavIndex,
        onTap: widget.onNavTap ?? (_) {},
      ),
    );
  }

  Widget _buildManagementItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthProgress({
    required String label,
    required String valueText,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
