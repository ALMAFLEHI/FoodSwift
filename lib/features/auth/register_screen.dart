import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'auth_controller.dart';
import '../../../app/theme/color_scheme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _register() async {
    try {
      await ref
          .read(authControllerProvider)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      Navigator.pushReplacementNamed(context, '/menu');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _mapFirebaseError(e.code);
      });
    } catch (e) {
      setState(() => _error = 'An unexpected error occurred. Try again.');
    }
  }

  void _registerWithGoogle() async {
    try {
      await ref.read(authControllerProvider).signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/menu');
    } catch (e) {
      setState(() => _error = 'Google Sign-In failed. Try again.');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    boxShadow: [AppShadows.card],
                  ),
                  child: Lottie.asset(
                    'assets/animations/chef_cooking.json',
                    height: 180,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Create Account',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign up to start placing orders',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [AppShadows.card],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: BorderSide(color: AppColors.textLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: BorderSide(color: AppColors.textLight),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: BorderSide(color: AppColors.textLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            borderSide: BorderSide(color: AppColors.textLight),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                            shadowColor: AppColors.shadow,
                          ),
                          child: Text('Register', style: AppTextStyles.button),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _registerWithGoogle,
                    icon: Image.asset('assets/images/Google.png', height: 24),
                    label: Text(
                      "Continue with Google",
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(color: AppColors.textLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    "Already have an account? Login",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
