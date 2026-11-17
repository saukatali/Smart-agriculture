import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'crop_visual_widget.dart';

class CustomerCartSheet extends StatefulWidget {
  final VoidCallback? onOrderPlaced;

  const CustomerCartSheet({super.key, this.onOrderPlaced});

  static void show(BuildContext context, {VoidCallback? onOrderPlaced}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerCartSheet(onOrderPlaced: onOrderPlaced),
    );
  }

  @override
  State<CustomerCartSheet> createState() => _CustomerCartSheetState();
}

class _CustomerCartSheetState extends State<CustomerCartSheet> {
  bool _isLoading = true;
  bool _isCheckingOut = false;
  List<dynamic> _cartItems = [];
  double _totalAmount = 0;
  String _paymentMethod = 'COD';
  final _addressController = TextEditingController(
    text: 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat - 380015',
  );

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getCart();
      if (res.success && res.data is Map && res.data['items'] != null) {
        setState(() {
          _cartItems = res.data['items'] as List<dynamic>;
          _totalAmount = double.tryParse(res.data['totalAmount'].toString()) ?? 0;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback if offline
    setState(() {
      _cartItems = [
        {
          'id': 1,
          'productName': 'Organic Tomatoes',
          'price': 40.0,
          'quantity': 2.0,
          'unit': 'kg',
          'farmerName': 'Ramesh Patel',
          'primaryImage': 'tomatoes',
        },
        {
          'id': 2,
          'productName': 'Basmati Rice',
          'price': 85.0,
          'quantity': 5.0,
          'unit': 'kg',
          'farmerName': 'KisanSamaj',
          'primaryImage': 'rice',
        },
      ];
      _totalAmount = 505.0;
      _isLoading = false;
    });
  }

  Future<void> _updateQty(int cartItemId, double newQty) async {
    try {
      final res = await ApiService().updateCartItem(cartItemId, newQty);
      if (res.success && res.data is Map) {
        setState(() {
          _cartItems = res.data['items'] as List<dynamic>;
          _totalAmount = double.tryParse(res.data['totalAmount'].toString()) ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isCheckingOut = true);

    try {
      final res = await ApiService().checkout(
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        customerName: 'Priya Sharma',
        customerMobile: '+91 98765 43212',
      );

      if (res.success) {
        final orderNumber = res.data?['order']?['orderNumber'] ?? 'ORD-SUCCESS';
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text('Order Confirmed!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your order $orderNumber has been placed into MySQL database.'),
                  const SizedBox(height: 8),
                  Text(
                    'Total Amount: ₹${_totalAmount.toStringAsFixed(0)} ($_paymentMethod)',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text('Delivery to: ${_addressController.text.trim()}', style: const TextStyle(fontSize: 11)),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          widget.onOrderPlaced?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Checkout failed: ${res.message}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Your Cart & Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_cartItems.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 8),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text('Browse marketplace and add fresh produce!', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _cartItems.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  final itemId = item['id'] as int;
                  final qty = double.tryParse(item['quantity'].toString()) ?? 1;
                  final price = double.tryParse(item['price'].toString()) ?? 0;
                  final name = item['productName']?.toString() ?? 'Fresh Produce';
                  final unit = item['unit']?.toString() ?? 'kg';
                  final img = (item['imageUrl'] ?? item['image_url'] ?? item['primaryImage'] ?? 'grain').toString();

                  return Row(
                    children: [
                      CropVisualWidget(
                        cropType: img,
                        productName: name,
                        width: 44,
                        height: 44,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            Text(
                              '₹${price.toStringAsFixed(0)} / $unit',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      // Stepper [-] qty [+]
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => _updateQty(itemId, qty - 1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Icon(Icons.remove, size: 14),
                              ),
                            ),
                            Text(
                              qty.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            InkWell(
                              onTap: () => _updateQty(itemId, qty + 1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Icon(Icons.add, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Checkout Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  const Text('Delivery Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment method radio
                  Row(
                    children: [
                      const Text('Payment: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Cash on Delivery (COD)', style: TextStyle(fontSize: 10.5)),
                        selected: _paymentMethod == 'COD',
                        selectedColor: AppColors.primarySurface,
                        onSelected: (val) {
                          if (val) setState(() => _paymentMethod = 'COD');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('UPI', style: TextStyle(fontSize: 10.5)),
                        selected: _paymentMethod == 'UPI',
                        selectedColor: AppColors.primarySurface,
                        onSelected: (val) {
                          if (val) setState(() => _paymentMethod = 'UPI');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total & Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _isCheckingOut ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isCheckingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Confirm Order',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

