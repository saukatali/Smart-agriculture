import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class FarmerOrdersSheet extends StatefulWidget {
  final VoidCallback? onOrdersUpdated;

  const FarmerOrdersSheet({super.key, this.onOrdersUpdated});

  static void show(BuildContext context, {VoidCallback? onOrdersUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FarmerOrdersSheet(onOrdersUpdated: onOrdersUpdated),
    );
  }

  @override
  State<FarmerOrdersSheet> createState() => _FarmerOrdersSheetState();
}

class _FarmerOrdersSheetState extends State<FarmerOrdersSheet> {
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getFarmerOrders();
      if (res.success && res.data is Map && res.data['orders'] != null) {
        setState(() {
          _orders = res.data['orders'] as List<dynamic>;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback if offline
    setState(() {
      _orders = [
        {
          'id': 1,
          'orderNumber': 'ORD-2026-8801',
          'customerName': 'Priya Sharma',
          'totalAmount': 1200,
          'status': 'pending',
          'deliveryAddress': 'Flat 402, Shivalik Residency, Ahmedabad',
          'paymentMethod': 'COD',
        },
        {
          'id': 2,
          'orderNumber': 'ORD-2026-8802',
          'customerName': 'Priya Sharma',
          'totalAmount': 2450,
          'status': 'confirmed',
          'deliveryAddress': 'Flat 402, Shivalik Residency, Ahmedabad',
          'paymentMethod': 'UPI',
        },
        {
          'id': 3,
          'orderNumber': 'ORD-2026-8803',
          'customerName': 'Kavita Patel',
          'totalAmount': 850,
          'status': 'pending',
          'deliveryAddress': 'Bungalow 12, Satellite, Ahmedabad',
          'paymentMethod': 'COD',
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      final res = await ApiService().updateOrderStatus(orderId, newStatus);
      if (res.success) {
        setState(() {
          final order = _orders.firstWhere((o) => o['id'] == orderId, orElse: () => null);
          if (order != null) order['status'] = newStatus;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order status updated to ${newStatus.toUpperCase()}!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        widget.onOrdersUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.primarySurface;
      case 'shipped':
        return const Color(0xFFEFF6FF);
      case 'delivered':
        return AppColors.successLight;
      default:
        return AppColors.badgeAmberBg;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.primary;
      case 'shipped':
        return const Color(0xFF2563EB);
      case 'delivered':
        return AppColors.success;
      default:
        return AppColors.badgeAmberText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
                    Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Farmer Order Management',
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
          else if (_orders.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No orders received yet.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final o = _orders[index];
                  final status = (o['status'] ?? 'pending').toString();
                  final id = o['id'] as int;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              o['orderNumber']?.toString() ?? 'ORD-0000',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusBg(status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusTextColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              o['customerName']?.toString() ?? 'Customer',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              '₹${o['totalAmount']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (o['deliveryAddress'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            o['deliveryAddress'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Action Status Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (status == 'pending') ...[
                              OutlinedButton(
                                onPressed: () => _updateStatus(id, 'cancelled'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(0, 28),
                                  side: const BorderSide(color: Colors.redAccent),
                                ),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(fontSize: 10.5, color: Colors.redAccent),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _updateStatus(id, 'confirmed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text(
                                  'Confirm Order',
                                  style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ] else if (status == 'confirmed') ...[
                              ElevatedButton(
                                onPressed: () => _updateStatus(id, 'shipped'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text(
                                  'Mark Shipped',
                                  style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ] else if (status == 'shipped') ...[
                              ElevatedButton(
                                onPressed: () => _updateStatus(id, 'delivered'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text(
                                  'Mark Delivered',
                                  style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Order completed',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

