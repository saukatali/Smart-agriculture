import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'profile_sheet.dart';

class AgriSmartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? rightAction;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showNotificationBadge;

  const AgriSmartAppBar({
    super.key,
    this.rightAction,
    this.onNotificationTap,
    this.onProfileTap,
    this.showNotificationBadge = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'AgriSmart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (rightAction != null)
          rightAction!
        else ...[
          // Notification Bell
          IconButton(
            onPressed: onNotificationTap ?? () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                if (showNotificationBadge)
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
          // User / Profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: onProfileTap ??
                  () {
                    if (AuthService().isAuthenticated) {
                      ProfileSheet.show(context);
                    }
                  },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
