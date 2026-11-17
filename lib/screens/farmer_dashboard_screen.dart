import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../widgets/agrismart_app_bar.dart';
import '../widgets/agrismart_bottom_nav.dart';
import '../widgets/crop_visual_widget.dart';
import '../widgets/custom_bar_chart.dart';
import '../widgets/add_product_sheet.dart';
import '../widgets/farmer_orders_sheet.dart';
import '../widgets/notifications_sheet.dart';
import '../services/api_service.dart';

class FarmerDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;
  final int currentNavIndex;
  final VoidCallback? onAskAiTap;

  const FarmerDashboardScreen({
    super.key,
    this.onNavTap,
    this.currentNavIndex = 0,
    this.onAskAiTap,
  });

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  String _totalSales = '₹72,450';
  String _productsCount = '16';
  String _pendingOrders = '5 Orders';
  String _farmerName = 'Rajesh Kumar';

  List<BarData> _weeklySales = const [
    BarData(day: 'Mon', value: 0.35, label: '₹1,200'),
    BarData(day: 'Tue', value: 0.45, label: '₹1,500'),
    BarData(day: 'Wed', value: 0.58, label: '₹2,100'),
    BarData(day: 'Thu', value: 0.50, label: '₹1,800'),
    BarData(day: 'Fri', value: 0.95, label: '₹2,840'),
    BarData(day: 'Sat', value: 0.70, label: '₹2,300'),
    BarData(day: 'Sun', value: 0.30, label: '₹950'),
  ];

  List<TrendingCropItem> _trendingCrops = const [
    TrendingCropItem(
      title: 'Premium Organic Wheat',
      badgeText: 'High Demand',
      subBadgeText: 'Grade A',
      priceInfo: '₹210 / quintal • 45 quintals left',
      imageType: 'wheat',
    ),
    TrendingCropItem(
      title: 'Desi White Cotton',
      badgeText: 'Trending Up',
      subBadgeText: 'Long Staple',
      priceInfo: '₹620 / bale • 12 bales left',
      imageType: 'cotton',
    ),
    TrendingCropItem(
      title: 'Hybrid Roma Tomatoes',
      badgeText: 'Harvest Ready',
      subBadgeText: 'Farm Fresh',
      priceInfo: '₹25 / crate • 120 crates left',
      imageType: 'tomatoes',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final res = await ApiService().getFarmerDashboard();
      if (res.success && res.data is Map) {
        final stats = res.data['stats'];
        final history = res.data['salesHistory'] as List<dynamic>?;
        final products = res.data['products'] as List<dynamic>?;

        setState(() {
          if (stats != null) {
            _totalSales = stats['totalRevenue']?.toString() ?? _totalSales;
            _productsCount = stats['activeListings']?.toString() ?? _productsCount;
            _pendingOrders = '${stats['pendingOrders'] ?? 5} Orders';
            if (stats['farmer'] != null && stats['farmer']['name'] != null) {
              _farmerName = stats['farmer']['name'].toString();
            }
          }

          if (history != null && history.isNotEmpty) {
            _weeklySales = history.map((item) {
              return BarData(
                day: item['day']?.toString() ?? 'Mon',
                value: double.tryParse(item['value']?.toString() ?? '0.4') ?? 0.4,
                label: item['label']?.toString() ?? '',
              );
            }).toList();
          }

          if (products != null && products.isNotEmpty) {
            _trendingCrops = products.take(5).map((p) {
              final price = p['pricePerKg'] ?? 0;
              final unit = p['unit'] ?? 'kg';
              final qty = p['availableQuantity'] ?? 0;
              return TrendingCropItem(
                title: p['name']?.toString() ?? 'Produce Item',
                badgeText: p['salesCount'] != null && (p['salesCount'] as num) > 50 ? 'High Demand' : 'Fresh Harvest',
                subBadgeText: p['qualityGrade']?.toString() ?? 'Grade A',
                priceInfo: '₹$price / $unit • $qty $unit left',
                imageType: (p['imageUrl'] ?? p['image_url'] ?? p['primaryImage'] ?? 'wheat').toString(),
              );
            }).toList();
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(
        onNotificationTap: () => NotificationsSheet.show(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Farmer Identity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DASHBOARD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Namaste, $_farmerName!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3 Stats in white card container
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Total Sales',
                            value: _totalSales,
                            badgeText: '+12.4%',
                            badgeColor: AppColors.successLight,
                            badgeTextColor: AppColors.success,
                          ),
                        ),
                        Container(width: 1, height: 44, color: AppColors.borderLight),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Products',
                            value: _productsCount,
                            badgeText: 'Active',
                            badgeColor: AppColors.primarySurface,
                            badgeTextColor: AppColors.primary,
                          ),
                        ),
                        Container(width: 1, height: 44, color: AppColors.borderLight),
                        Expanded(
                          child: _buildStatItem(
                            icon: Icons.pending_actions_outlined,
                            label: 'Pending',
                            value: _pendingOrders,
                            badgeText: 'Action',
                            badgeColor: AppColors.badgeAmberBg,
                            badgeTextColor: AppColors.badgeAmberText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // AI Insight Card (Dark Forest Green)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBgDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background watermark leaf contour
                        Positioned(
                          right: -10,
                          bottom: -15,
                          child: Icon(
                            Icons.psychology_outlined,
                            size: 110,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 14,
                                      color: Color(0xFF86EFAC),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'AI INSIGHT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF86EFAC),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Updated 2m ago',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Heading
                            const Text(
                              'Wheat demand expected to rise 22% next week',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtext
                            const Text(
                              'Regional millers are increasing stock ahead of the festival season. Consider listing additional batches now.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Optimize Pricing pill button
                            InkWell(
                              onTap: widget.onAskAiTap ?? () {},
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Optimize Pricing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Buttons Row (3 buttons)
                  Row(
                    children: [
                      // Add Product
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => AddProductSheet.show(context, onProductAdded: _loadDashboardData),
                            borderRadius: BorderRadius.circular(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Add Product',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // View Orders
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: InkWell(
                            onTap: () => FarmerOrdersSheet.show(context, onOrdersUpdated: _loadDashboardData),
                            borderRadius: BorderRadius.circular(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 15, color: AppColors.textPrimary),
                                SizedBox(width: 4),
                                Text(
                                  'View Orders',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AI Price Check
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: InkWell(
                            onTap: widget.onAskAiTap ?? () {},
                            borderRadius: BorderRadius.circular(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'AI Price Check',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Weekly Sales Overview
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly Sales Overview',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Performance across last 7 days',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹2,840 this week',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomBarChart(
                          bars: _weeklySales,
                          activeIndex: 4, // Friday is active
                          height: 90,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Trending Products Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trending Products',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Trending Crop List Items
                  ...List.generate(_trendingCrops.length, (index) {
                    final crop = _trendingCrops[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          CropVisualWidget(
                            cropType: crop.imageType,
                            productName: crop.title,
                            width: 44,
                            height: 44,
                            borderRadius: 8,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        crop.badgeText,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      crop.subBadgeText,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  crop.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  crop.priceInfo,
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
                    );
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),

            // Floating "Ask AI" pill button
            Positioned(
              right: 16,
              bottom: 12,
              child: GestureDetector(
                onTap: widget.onAskAiTap ?? () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ask AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AgriSmartBottomNav(
        currentIndex: widget.currentNavIndex,
        onTap: widget.onNavTap ?? (_) {},
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
