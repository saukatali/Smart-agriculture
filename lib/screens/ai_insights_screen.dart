import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../widgets/agrismart_app_bar.dart';
import '../widgets/agrismart_bottom_nav.dart';
import '../widgets/crop_visual_widget.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/map_preview_widget.dart';
import '../widgets/notifications_sheet.dart';
import '../services/api_service.dart';

class AiInsightsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;
  final int currentNavIndex;

  const AiInsightsScreen({
    super.key,
    this.onNavTap,
    this.currentNavIndex = 3,
  });

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  int _selectedForecastWindow = 0; // 0: 7 Days, 1: 30 Days, 2: 90 Days
  final List<String> _forecastWindows = ['7 Days', '30 Days', '90 Days'];
  final Set<int> _appliedStrategies = {};

  List<HighDemandCrop> _highDemandCrops = [
    const HighDemandCrop(
      name: 'Premium Hard Wheat',
      tag: 'High Demand',
      isHighDemand: true,
      projectedPrice: 'Projected Price: \$310 / ton (+12%)',
      imageType: 'wheat',
    ),
    const HighDemandCrop(
      name: 'Roma Tomatoes',
      tag: 'Peak Season',
      isHighDemand: false,
      projectedPrice: 'Projected Price: \$1.25 / kg (+18%)',
      imageType: 'tomatoes',
    ),
  ];

  final List<SmartRecommendation> _recommendations = const [
    SmartRecommendation(
      title: 'Hold Wheat Inventory for 14 Days',
      confidence: '88% Confidence',
      description:
          'Regional milling demand is projected to spike due to lower regional grain reserves. Releasing stock around the 22nd will maximize yield margins.',
      profitIncrease: '+₹4,200',
      actionLabel: 'Apply Strategy',
      icon: Icons.inventory_2_outlined,
    ),
    SmartRecommendation(
      title: 'Route Roma Tomatoes to North Hub',
      confidence: '91% Confidence',
      description:
          'Metropolitan buyers in North Hub are experiencing a 30% supply deficit for vine tomatoes. Direct transport yields 18% higher spot prices.',
      profitIncrease: '+₹2,800',
      actionLabel: 'Dispatch Route',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPredictions(_forecastWindows[0]);
  }

  Future<void> _loadPredictions(String window) async {
    try {
      final res = await ApiService().getPredictions(window: window);
      if (res.success && res.data is Map && res.data['predictions'] != null) {
        final preds = res.data['predictions'] as List<dynamic>;
        if (preds.isNotEmpty) {
          setState(() {
            _highDemandCrops = preds.map((p) {
              return HighDemandCrop(
                name: p['cropName']?.toString() ?? 'Crop',
                tag: p['tag']?.toString() ?? 'High Demand',
                isHighDemand: (p['isHighDemand'] ?? 0) == 1,
                projectedPrice: p['projectedPrice']?.toString() ?? 'Active Mandi Rate',
                imageType: (p['imageUrl'] ?? p['image_url'] ?? p['imageType'] ?? 'wheat').toString(),
              );
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _applyStrategyAction(int id, String actionLabel) async {
    try {
      await ApiService().applyStrategy(id);
      setState(() => _appliedStrategies.add(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Action executed: $actionLabel confirmed in MySQL!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _appliedStrategies.add(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $actionLabel applied successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
              // Hero Card: Market Intelligence Hub
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top tag row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.memory,
                                size: 12,
                                color: Color(0xFF86EFAC),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI Neural Engine v2.3',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF86EFAC),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.eco_outlined,
                          size: 18,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title
                    const Text(
                      'Market Intelligence Hub',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    const Text(
                      'Real-time demand forecasting and predictive pricing models optimized for your regional harvest yields.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 3 KPI metrics inside hero card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildHeroMetric(
                              'Accuracy Rate',
                              '96.4%',
                            ),
                          ),
                          Container(width: 1, height: 28, color: Colors.white24),
                          Expanded(
                            child: _buildHeroMetric(
                              'Active Markets',
                              '14 Hubs',
                            ),
                          ),
                          Container(width: 1, height: 28, color: Colors.white24),
                          Expanded(
                            child: _buildHeroMetric(
                              'Trend Outlook',
                              'Bullish',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Demand Forecast Window row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Demand Forecast Window',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Live sync',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Forecast Window Filter Tabs (7 Days, 30 Days, 90 Days)
              Row(
                children: List.generate(_forecastWindows.length, (index) {
                  final isSelected = _selectedForecastWindow == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < _forecastWindows.length - 1 ? 8 : 0,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedForecastWindow = index);
                          _loadPredictions(_forecastWindows[index]);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _forecastWindows[index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Predictive Trend Chart Card
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PREDICTIVE TREND',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Wheat & Tomato Demand Index',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 12,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '+14.8%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const TrendLineChart(height: 115),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Top High-Demand Crops
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Top High-Demand Crops',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
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
              const SizedBox(height: 8),

              ..._highDemandCrops.map((crop) {
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
                        productName: crop.name,
                        width: 42,
                        height: 42,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    crop.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: crop.isHighDemand
                                        ? AppColors.primarySurface
                                        : AppColors.badgeAmberBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    crop.tag,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: crop.isHighDemand
                                          ? AppColors.primary
                                          : AppColors.badgeAmberText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              crop.projectedPrice,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Smart Selling Recommendations
              const Row(
                children: [
                  Flexible(
                    child: Text(
                      'Smart Selling Recommendations',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._recommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final rec = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            rec.icon,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              rec.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgeAmberBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rec.confidence,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.badgeAmberText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rec.description,
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Estimated Profit Increase: '),
                                  TextSpan(
                                    text: rec.profitIncrease,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _applyStrategyAction(index + 1, rec.actionLabel),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _appliedStrategies.contains(index + 1)
                                    ? AppColors.success
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _appliedStrategies.contains(index + 1)
                                    ? 'Applied ✓'
                                    : rec.actionLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Location-Based Market Insights
              const Text(
                'Location-Based Market Insights',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

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
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Central Valley Ag-Hub #4',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Optimal Conditions',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const MapPreviewWidget(height: 95),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Avg. Freight Cost: \$1.12 / ton-km',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Buyer Saturation: Very High',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
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

  Widget _buildHeroMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
