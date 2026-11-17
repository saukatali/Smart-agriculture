import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/profile_sheet.dart';
import 'admin_control_center_screen.dart';
import 'ai_insights_screen.dart';
import 'customer_home_screen.dart';
import 'farmer_dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

enum AppView {
  onboarding,
  farmerDashboard,
  customerHome,
  aiInsights,
  adminControlCenter,
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final AuthService _authService = AuthService();

  AppView _currentView = AppView.farmerDashboard;
  AppRole _activeRole = AppRole.customer;
  int _navIndex = 0;
  bool _showDevBar = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthStateChanged);
    _restoreSession();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> _restoreSession() async {
    await _authService.validateSession();
    if (!mounted) return;
    _syncViewToAuthenticatedUser(resetToHome: true);
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    if (!_authService.isAuthenticated) {
      setState(() {
        _navIndex = 0;
        _currentView = AppView.onboarding;
      });
    } else {
      _syncViewToAuthenticatedUser(resetToHome: false);
    }
  }

  void _syncViewToAuthenticatedUser({required bool resetToHome}) {
    setState(() {
      _initialized = true;
      if (_authService.isAuthenticated) {
        _activeRole = _authService.currentRole;
        if (resetToHome || _currentView == AppView.onboarding) {
          _applyHomeViewForRole(_activeRole);
        }
      } else {
        _currentView = AppView.onboarding;
        _navIndex = 0;
      }
    });
  }

  void _applyHomeViewForRole(AppRole role) {
    switch (role) {
      case AppRole.farmer:
        _currentView = AppView.farmerDashboard;
        _navIndex = 0;
        break;
      case AppRole.customer:
        _currentView = AppView.customerHome;
        _navIndex = 0;
        break;
      case AppRole.admin:
        _currentView = AppView.adminControlCenter;
        _navIndex = 4;
        break;
    }
  }

  void _onLoginSuccess() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _syncViewToAuthenticatedUser(resetToHome: true);
  }

  void _onLogoutComplete() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() {
      _navIndex = 0;
      _currentView = AppView.onboarding;
      _showDevBar = false;
    });
  }

  void _onRoleContinue(AppRole selectedRole) {
    if (!_authService.isAuthenticated) return;
    setState(() {
      _activeRole = selectedRole;
      _applyHomeViewForRole(selectedRole);
    });
  }

  void _onBottomNavTap(int index) {
    if (!_authService.isAuthenticated) return;

    if (index == 4) {
      if (_activeRole == AppRole.admin &&
          _currentView != AppView.adminControlCenter) {
        setState(() {
          _navIndex = 4;
          _currentView = AppView.adminControlCenter;
        });
      } else {
        ProfileSheet.show(
          context,
          onLogoutConfirmed: _onLogoutComplete,
        );
      }
      return;
    }

    setState(() {
      _navIndex = index;
      switch (index) {
        case 0:
          _currentView = _activeRole == AppRole.customer
              ? AppView.customerHome
              : AppView.farmerDashboard;
          break;
        case 1:
          _currentView = AppView.customerHome;
          break;
        case 2:
          _currentView = _activeRole == AppRole.farmer
              ? AppView.farmerDashboard
              : AppView.customerHome;
          break;
        case 3:
          _currentView = AppView.aiInsights;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && _authService.isCheckingSession) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, size: 48, color: AppColors.primary),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Loading AgriSmart...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Strict Protected Route Gate: unauthenticated users only ever see LoginScreen.
    // PopScope(canPop: false) prevents the Android back button from returning to protected routes after logout.
    if (!_authService.isAuthenticated) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !Navigator.of(context).canPop()) {
            SystemNavigator.pop();
          }
        },
        child: LoginScreen(onLoginSuccess: _onLoginSuccess),
      );
    }

    Widget activeScreen;
    switch (_currentView) {
      case AppView.onboarding:
        activeScreen = OnboardingScreen(
          onRoleSelected: _onRoleContinue,
          onNavTap: _onBottomNavTap,
          currentNavIndex: _navIndex,
        );
        break;
      case AppView.farmerDashboard:
        activeScreen = FarmerDashboardScreen(
          onNavTap: _onBottomNavTap,
          currentNavIndex: _navIndex,
          onAskAiTap: () {
            setState(() {
              _currentView = AppView.aiInsights;
              _navIndex = 3;
            });
          },
        );
        break;
      case AppView.customerHome:
        activeScreen = CustomerHomeScreen(
          onNavTap: _onBottomNavTap,
          currentNavIndex: _navIndex,
        );
        break;
      case AppView.aiInsights:
        activeScreen = AiInsightsScreen(
          onNavTap: _onBottomNavTap,
          currentNavIndex: _navIndex,
        );
        break;
      case AppView.adminControlCenter:
        activeScreen = AdminControlCenterScreen(
          onNavTap: _onBottomNavTap,
          currentNavIndex: _navIndex,
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_showDevBar)
            SafeArea(
              bottom: false,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2922),
                  border: Border(
                    bottom: BorderSide(color: Colors.black26, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.layers,
                      size: 14,
                      color: Color(0xFF86EFAC),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Screens:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildScreenPill('Farmer Dashboard', AppView.farmerDashboard, 0),
                            _buildScreenPill('Customer Home', AppView.customerHome, 1),
                            _buildScreenPill('AI Insights', AppView.aiInsights, 3),
                            if (_activeRole == AppRole.admin)
                              _buildScreenPill('Admin', AppView.adminControlCenter, 4),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 14, color: Colors.white60),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() => _showDevBar = false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: activeScreen),
        ],
      ),
    );
  }

  Widget _buildScreenPill(String title, AppView view, int navIdx) {
    final isCurrent = _currentView == view;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentView = view;
            _navIndex = navIdx;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              color: isCurrent ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
