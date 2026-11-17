import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../widgets/agrismart_app_bar.dart';
import '../widgets/agrismart_bottom_nav.dart';
import '../widgets/crop_visual_widget.dart';
import '../widgets/customer_cart_sheet.dart';
import '../widgets/notifications_sheet.dart';
import '../services/api_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavTap;
  final int currentNavIndex;

  const CustomerHomeScreen({
    super.key,
    this.onNavTap,
    this.currentNavIndex = 0,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _cartCount = 2;
  String? _selectedCategorySlug;

  List<CatalogProduct> _displayedProducts = [
    const CatalogProduct(
      name: 'Organic Tomatoes',
      farmer: 'by Ramesh Patel',
      price: '₹40 / kg',
      badge: 'Organic',
      badgeColor: AppColors.primarySurface,
      badgeTextColor: AppColors.primary,
      imageType: 'tomatoes',
    ),
    const CatalogProduct(
      name: 'Fresh Potatoes',
      farmer: 'by Suresh Desai',
      price: '₹25 / kg',
      badge: 'Fresh',
      badgeColor: AppColors.badgeAmberBg,
      badgeTextColor: AppColors.badgeAmberText,
      imageType: 'potatoes',
    ),
    const CatalogProduct(
      name: 'Basmati Rice',
      farmer: 'by KisanSamaj',
      price: '₹85 / kg',
      badge: 'Grade A',
      badgeColor: AppColors.primarySurface,
      badgeTextColor: AppColors.primary,
      imageType: 'rice',
    ),
    const CatalogProduct(
      name: 'Groundnuts',
      farmer: 'by Dhanyadnya',
      price: '₹60 / kg',
      badge: 'New Crop',
      badgeColor: AppColors.badgeAmberBg,
      badgeTextColor: AppColors.badgeAmberText,
      imageType: 'groundnuts',
    ),
  ];

  // Map product IDs for API calls
  List<int> _productIds = [4, 5, 6, 7];

  final List<CategoryItem> _categories = const [
    CategoryItem(
      label: 'Grains',
      icon: Icons.grain,
      bgColor: Color(0xFFF3EFE6),
    ),
    CategoryItem(
      label: 'Vegetables',
      icon: Icons.eco,
      bgColor: Color(0xFFEAF5ED),
    ),
    CategoryItem(
      label: 'Fruits',
      icon: Icons.apple,
      bgColor: Color(0xFFFBECEB),
    ),
    CategoryItem(
      label: 'Spices',
      icon: Icons.soup_kitchen,
      bgColor: Color(0xFFFFF3E0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketplace();
    _updateCartCount();
  }

  Future<void> _updateCartCount() async {
    try {
      final res = await ApiService().getCart();
      if (res.success && res.data is Map && res.data['items'] != null) {
        final items = res.data['items'] as List<dynamic>;
        setState(() => _cartCount = items.length);
      }
    } catch (_) {}
  }

  Future<void> _loadMarketplace({String? categoryId, String? search}) async {
    try {
      final res = await ApiService().getCustomerProducts(categoryId: categoryId, search: search);
      if (res.success && res.data is Map && res.data['products'] != null) {
        final prods = res.data['products'] as List<dynamic>;
        if (prods.isNotEmpty) {
          setState(() {
            _productIds = prods.map((p) => p['id'] as int).toList();
            _displayedProducts = prods.map((p) {
              final price = p['pricePerKg'] ?? 0;
              final unit = p['unit'] ?? 'kg';
              final farmer = p['farmerName'] ?? p['farmName'] ?? 'Local Farmer';
              return CatalogProduct(
                name: p['name']?.toString() ?? 'Produce',
                farmer: 'by $farmer',
                price: '₹$price / $unit',
                badge: p['qualityGrade']?.toString() ?? 'Fresh',
                badgeColor: AppColors.primarySurface,
                badgeTextColor: AppColors.primary,
                imageType: (p['imageUrl'] ?? p['image_url'] ?? p['primaryImage'] ?? 'tomatoes').toString(),
              );
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _addToCart(int productId, String name) async {
    try {
      final res = await ApiService().addToCart(productId, quantity: 1);
      if (res.success) {
        await _updateCartCount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Added $name to cart!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showProductDetailsSheet(CatalogProduct product, int productId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Stack(
                children: [
                  CropVisualWidget(
                    cropType: product.imageType,
                    productName: product.name,
                    width: double.infinity,
                    height: 185,
                    borderRadius: 14,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.badge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: product.badgeTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.farmer,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _addToCart(productId, product.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<FarmerProfile> _nearbyFarmers = const [
    FarmerProfile(
      name: 'Ramesh Patel Farms',
      initials: 'RP',
      rating: 4.8,
      reviewsCount: 120,
      distance: '2.2 km away',
    ),
    FarmerProfile(
      name: 'Suresh Desai Organics',
      initials: 'SD',
      rating: 4.6,
      reviewsCount: 84,
      distance: '4.5 km away',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(
        rightAction: Row(
          children: [
            IconButton(
              onPressed: () => CustomerCartSheet.show(
                context,
                onOrderPlaced: () {
                  _loadMarketplace();
                  _updateCartCount();
                },
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => NotificationsSheet.show(context),
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _loadMarketplace();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marketplace refreshed from MySQL!'), backgroundColor: AppColors.primary),
                );
              },
              icon: const Icon(
                Icons.tune,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Selector
              const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ahmedabad, Gujarat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search Bar with "Find" button
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Search fresh tomatoes, wheat, organic produce...',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _loadMarketplace(search: _searchController.text.trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Find',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hero Special Offer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBgDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Special Offer',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Direct from Farm\nto Table',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '10% off organic wheat harvested this season.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              _addToCart(1, 'Premium Organic Wheat');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎉 10% Discount applied on Organic Wheat! Added to Cart.'),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4E157),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Claim Discount',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E3A1A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Image thumbnail
                    const CropVisualWidget(
                      cropType: 'offer_wheat',
                      width: 74,
                      height: 74,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Explore Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontSize: 13,
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

              // Categories Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategorySlug == cat.label.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedCategorySlug == cat.label.toLowerCase()) {
                          _selectedCategorySlug = null;
                          _loadMarketplace();
                        } else {
                          _selectedCategorySlug = cat.label.toLowerCase();
                          int catId = 1;
                          if (cat.label == 'Grains') catId = 3;
                          if (cat.label == 'Vegetables') catId = 1;
                          if (cat.label == 'Fruits') catId = 2;
                          if (cat.label == 'Spices') catId = 4;
                          _loadMarketplace(categoryId: catId.toString());
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              cat.icon,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Recommended for You Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _loadMarketplace();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All products loaded.'), backgroundColor: AppColors.primary),
                      );
                    },
                    child: const Text(
                      'See More',
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

              // 2x2 Grid of Product Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: _displayedProducts.length,
                itemBuilder: (context, index) {
                  final p = _displayedProducts[index];
                  final pId = index < _productIds.length ? _productIds[index] : (index + 1);
                  return GestureDetector(
                    onTap: () => _showProductDetailsSheet(p, pId),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with badge
                          Stack(
                            children: [
                              CropVisualWidget(
                                cropType: p.imageType,
                                productName: p.name,
                                width: double.infinity,
                                height: 72,
                                borderRadius: 8,
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p.badge,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.badgeTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          p.farmer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.price,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            InkWell(
                              onTap: () => _addToCart(pId, p.name),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Nearby Farmers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearby Farmers',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View Map',
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

              ..._nearbyFarmers.map((farmer) {
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
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            farmer.initials,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${farmer.rating} (${farmer.reviewsCount} reviews) • ${farmer.distance}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Row(
                                children: [
                                  const Icon(Icons.storefront, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      farmer.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('⭐ Rating: ${farmer.rating} (${farmer.reviewsCount} verified reviews)'),
                                  const SizedBox(height: 4),
                                  Text('📍 Location: ${farmer.distance}'),
                                  const SizedBox(height: 4),
                                  const Text('🌾 Verified Organic Producer (NPOP India Organic)'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Contact Hub: +91 98765 43210',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: const Text(
                            'Visit',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
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
}
