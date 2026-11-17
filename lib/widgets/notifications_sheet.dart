import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getNotifications();
      if (res.success && res.data is Map && res.data['notifications'] != null) {
        setState(() {
          _notifications = res.data['notifications'] as List<dynamic>;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback notifications if offline
    setState(() {
      _notifications = [
        {
          'id': 1,
          'title': 'New Order Received!',
          'message': 'You have 5 pending orders awaiting confirmation.',
          'type': 'order',
          'isRead': 0,
        },
        {
          'id': 2,
          'title': 'AI Price Alert',
          'message': 'Wheat demand expected to rise 22% next week. Check AI insights.',
          'type': 'alert',
          'isRead': 0,
        },
        {
          'id': 3,
          'title': 'Discount Available',
          'message': 'Claim 10% off on your next organic harvest order!',
          'type': 'promo',
          'isRead': 1,
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _markRead(int id) async {
    await ApiService().markNotificationRead(id);
    setState(() {
      final item = _notifications.firstWhere((n) => n['id'] == id, orElse: () => null);
      if (item != null) item['isRead'] = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
                    Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Notifications',
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
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No new notifications.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  final isUnread = (n['isRead'] ?? 0) == 0;
                  final type = n['type']?.toString() ?? 'info';

                  IconData icon = Icons.notifications;
                  Color iconColor = AppColors.primary;
                  if (type == 'order') {
                    icon = Icons.shopping_bag;
                    iconColor = AppColors.primary;
                  } else if (type == 'alert') {
                    icon = Icons.warning_amber_rounded;
                    iconColor = const Color(0xFFD97706);
                  } else if (type == 'promo') {
                    icon = Icons.local_offer;
                    iconColor = const Color(0xFF2563EB);
                  }

                  return InkWell(
                    onTap: () {
                      if (isUnread && n['id'] != null) {
                        _markRead(n['id'] as int);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUnread ? const Color(0xFFF0FDF4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title']?.toString() ?? 'Notification',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n['message']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

