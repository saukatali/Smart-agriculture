import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AdminActionsSheet {
  // 1. Moderation Queue Sheet
  static void showModerationQueue(BuildContext context, {VoidCallback? onUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModerationSheet(onUpdated: onUpdated),
    );
  }

  // 2. Supplier Compliance Sheet
  static void showSupplierCompliance(BuildContext context, {VoidCallback? onUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SupplierSheet(onUpdated: onUpdated),
    );
  }

  // 3. Broadcast Alert Dialog
  static void showBroadcastDialog(BuildContext context, {VoidCallback? onSent}) {
    final titleController = TextEditingController(text: 'Severe Rain Forecast & Cold Storage Advisory');
    final messageController = TextEditingController(
      text: 'Unseasonal monsoon depression approaching Gujarat region. Move all open-harvest grain to covered hubs.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Broadcast System Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alert Headline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Message Body', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final msg = messageController.text.trim();
              if (title.isNotEmpty && msg.isNotEmpty) {
                Navigator.pop(ctx);
                final res = await ApiService().broadcastAlert(title, msg);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message.isNotEmpty ? res.message : 'Broadcast sent to all users!'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  onSent?.call();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Send Alert Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ModerationSheet extends StatefulWidget {
  final VoidCallback? onUpdated;
  const _ModerationSheet({this.onUpdated});

  @override
  State<_ModerationSheet> createState() => _ModerationSheetState();
}

class _ModerationSheetState extends State<_ModerationSheet> {
  bool _isLoading = true;
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService().getAdminDashboard();
      if (res.success && res.data is Map && res.data['moderation'] != null) {
        setState(() {
          _reports = res.data['moderation'] as List<dynamic>;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _reports = [
        {
          'id': 1,
          'userName': 'KisanSamaj AgroTrader',
          'userRole': 'Farmer',
          'reason': 'Bulk unverified pricing claim for cotton shipment',
          'status': 'Pending Review',
        },
        {
          'id': 2,
          'userName': 'Express Agrologistics #4',
          'userRole': 'Logistics',
          'reason': 'Delivery delay dispute for perishable produce',
          'status': 'Pending Review',
        },
        {
          'id': 3,
          'userName': 'City Organics Retail',
          'userRole': 'Customer',
          'reason': 'Payment settlement inquiry on batch delivery',
          'status': 'Pending Review',
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _resolve(int id) async {
    await ApiService().resolveModerationReport(id, status: 'Resolved');
    setState(() {
      final r = _reports.firstWhere((item) => item['id'] == id, orElse: () => null);
      if (r != null) r['status'] = 'Resolved';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report resolved and logged.'), backgroundColor: AppColors.primary),
      );
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Moderation & Dispute Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final r = _reports[index];
                  final isResolved = (r['status'] ?? '').toString().toLowerCase() == 'resolved';
                  final id = r['id'] as int;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r['userName']?.toString() ?? 'User',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isResolved ? AppColors.successLight : AppColors.badgeAmberBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r['status']?.toString() ?? 'Pending',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isResolved ? AppColors.success : AppColors.badgeAmberText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r['reason']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (!isResolved) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => _resolve(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(0, 26),
                              ),
                              child: const Text('Mark Resolved', style: TextStyle(fontSize: 10.5, color: Colors.white)),
                            ),
                          ),
                        ],
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

class _SupplierSheet extends StatefulWidget {
  final VoidCallback? onUpdated;
  const _SupplierSheet({this.onUpdated});

  @override
  State<_SupplierSheet> createState() => _SupplierSheetState();
}

class _SupplierSheetState extends State<_SupplierSheet> {
  bool _isLoading = true;
  List<dynamic> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService().getAdminDashboard();
      if (res.success && res.data is Map && res.data['compliance'] != null) {
        setState(() {
          _suppliers = res.data['compliance'] as List<dynamic>;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _suppliers = [
        {
          'id': 1,
          'supplierName': 'Ramesh Patel Organic Farms',
          'certificationType': 'NPOP India Organic',
          'status': 'Due for Renewal',
          'renewalDate': 'Expires in 14 days',
        },
        {
          'id': 2,
          'supplierName': 'Gujarat Bio Fertilizer Co.',
          'certificationType': 'ISO 22000 Food Safety',
          'status': 'Due for Renewal',
          'renewalDate': 'Expires in 21 days',
        },
        {
          'id': 3,
          'supplierName': 'Surat Agro Greens Hub',
          'certificationType': 'FSSAI Central License',
          'status': 'Valid',
          'renewalDate': 'Active until Nov 2027',
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _renew(int id) async {
    await ApiService().renewSupplierCompliance(id);
    setState(() {
      final s = _suppliers.firstWhere((item) => item['id'] == id, orElse: () => null);
      if (s != null) {
        s['status'] = 'Valid';
        s['renewalDate'] = 'Active until Nov 2027';
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier certification renewed!'), backgroundColor: AppColors.primary),
      );
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Supplier Compliance Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _suppliers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final s = _suppliers[index];
                  final isValid = (s['status'] ?? '').toString().toLowerCase() == 'valid';
                  final id = s['id'] as int;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s['supplierName']?.toString() ?? 'Supplier',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isValid ? AppColors.successLight : AppColors.badgeAmberBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['status']?.toString() ?? 'Valid',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isValid ? AppColors.success : AppColors.badgeAmberText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s['certificationType']} • ${s['renewalDate']}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (!isValid) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => _renew(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(0, 26),
                              ),
                              child: const Text('Renew Certification', style: TextStyle(fontSize: 10.5, color: Colors.white)),
                            ),
                          ),
                        ],
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

