import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../widgets/agrismart_app_bar.dart';
import '../widgets/agrismart_bottom_nav.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/auth_dialog.dart';

class OnboardingScreen extends StatefulWidget {
  final ValueChanged<AppRole>? onRoleSelected;
  final ValueChanged<int>? onNavTap;
  final int currentNavIndex;

  const OnboardingScreen({
    super.key,
    this.onRoleSelected,
    this.onNavTap,
    this.currentNavIndex = 0,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedLanguageIndex = 0; // 0: English, 1: Hindi, 2: Gujarati
  AppRole _selectedRole = AppRole.farmer;

  final List<String> _languages = ['English', 'हिन्दी', 'ગુજરાતી'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(
        onNotificationTap: () => NotificationsSheet.show(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // AgriSmart Leaf Logo Emblem Box
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.eco,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Language Selector Pills
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_languages.length, (index) {
                          final isSelected = _selectedLanguageIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedLanguageIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _languages[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Title
                    const Text(
                      'Smart Farming, Direct Marketplace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Connect directly with sustainable producers, leverage AI-driven forecasts, and trade fresh yield seamlessly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Step indicator row
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Your Role',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Step 1 of 2',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Role 1: Farmer / Producer
                    _buildRoleCard(
                      role: AppRole.farmer,
                      icon: Icons.agriculture,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      title: 'Farmer / Producer',
                      description:
                          'Sell produce directly to buyers, access smart weather insights, and get AI-powered yield forecasts.',
                      tags: ['AI Forecasts', 'Direct Sales'],
                    ),
                    const SizedBox(height: 10),

                    // Role 2: Customer / Buyer
                    _buildRoleCard(
                      role: AppRole.customer,
                      icon: Icons.shopping_basket_outlined,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      title: 'Customer / Buyer',
                      description:
                          'Buy fresh, organic produce directly from verified local farmers with transparent supply chains.',
                      tags: ['Farm Fresh', 'Best Prices'],
                    ),
                    const SizedBox(height: 10),

                    // Role 3: Platform Admin
                    _buildRoleCard(
                      role: AppRole.admin,
                      icon: Icons.admin_panel_settings_outlined,
                      iconBg: AppColors.accentAmberLight,
                      iconColor: AppColors.accentAmber,
                      title: 'Platform Admin',
                      description:
                          'Manage platform analytics, verify supplier compliance, and oversee marketplace logistics.',
                      tags: ['Analytics', 'Moderation'],
                    ),
                    const SizedBox(height: 18),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onRoleSelected?.call(_selectedRole);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4EDE5),
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to AgriSmart',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Custom Account Sign In / Register
                    TextButton.icon(
                      onPressed: () {
                        AuthDialog.show(
                          context,
                          onAuthSuccess: (role) {
                            setState(() => _selectedRole = role);
                            widget.onRoleSelected?.call(role);
                          },
                        );
                      },
                      icon: const Icon(Icons.login, size: 15, color: AppColors.primary),
                      label: const Text(
                        'Sign In with Custom Account / Register',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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

  Widget _buildRoleCard({
    required AppRole role,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> tags,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.12),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
