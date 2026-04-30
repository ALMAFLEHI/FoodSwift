import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/menu/menu_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/order/order_status_screen.dart';
import '../features/profile/settings_sheet.dart';
import '../features/common/widgets/animated_appbar.dart';

import '../app/theme/color_scheme.dart';

class HomeWrapperScreen extends ConsumerStatefulWidget {
  const HomeWrapperScreen({super.key});

  @override
  ConsumerState<HomeWrapperScreen> createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends ConsumerState<HomeWrapperScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 3) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (_) => const SettingsSheet(),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MenuScreen(),
      CartScreen(
        onOrderPlaced: () {
          setState(() {
            _selectedIndex = 2; // Switch to Orders tab
          });
        },
      ),
      const OrderStatusScreen(),
      const SizedBox(), // Profile shown via modal
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AnimatedAppBar(userName: 'Moayad'),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(Icons.restaurant_menu_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              label: 'Explore Menu',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(Icons.shopping_bag_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              label: 'My Cart',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(Icons.local_shipping_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(Icons.account_circle_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: const Icon(
                  Icons.account_circle,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
