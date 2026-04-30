import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/theme/color_scheme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), _navigateBasedOnAuth);
  }

  Future<void> _navigateBasedOnAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final role = userDoc.data()?['role'] ?? 'customer';

        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/menu');
          }
        }
      } catch (e) {
        // Fallback to menu if error occurs (e.g. no user doc found)
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/menu');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [AppShadows.card],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'FoodSwift',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Delicious meals, delivered fast',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.textWhite,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Loading your experience...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
