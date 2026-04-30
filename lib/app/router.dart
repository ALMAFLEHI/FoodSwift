import 'package:flutter/material.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

import '../features/cart/cart_screen.dart';
import '../features/order/customize_order_screen.dart' as customize;
import '../features/order/order_status_screen.dart' as order_status;

import '../features/menu/menu_screen.dart';
import '../home/home_wrapper_screen.dart';

import '../screens/admin_dashboard.dart';

import '../models/menu_item_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/menu':
        return MaterialPageRoute(builder: (_) => const HomeWrapperScreen());

      case '/customize':
        final args = settings.arguments as MenuItemModel;
        return MaterialPageRoute(
          builder: (_) => customize.CustomizeOrderScreen(menuItem: args),
        );

      case '/orders':
        return MaterialPageRoute(
          builder: (_) => const order_status.OrderStatusScreen(),
        );

      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case '/admin_dashboard': // ✅ Admin route
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 - Page Not Found'))),
        );
    }
  }
}
