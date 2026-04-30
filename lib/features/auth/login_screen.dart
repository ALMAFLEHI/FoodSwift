import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'auth_controller.dart';
import '/models/user_model.dart';
import '../../../app/theme/color_scheme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _login() async {
    try {
      final userCredential = await ref
          .read(authControllerProvider)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) {
        setState(() => _error = "User not found.");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() => _error = "User profile not found.");
        await FirebaseAuth.instance.signOut();
        return;
      }

      final userModel = UserModel.fromMap(userDoc.data()!);

      // ✅ Firestore-stored admin password check
      if (userModel.role == 'admin') {
        final enteredPassword = _passwordController.text.trim();
        if (userModel.password != null &&
            userModel.password != enteredPassword) {
          setState(() => _error = "Incorrect admin password.");
          await FirebaseAuth.instance.signOut();
          return;
        }
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseError(e.code));
    } catch (e) {
      setState(() => _error = 'An unexpected error occurred. Try again.');
    }
  }

  void _loginWithGoogle() async {
    try {
      final userCredential = await ref
          .read(authControllerProvider)
          .signInWithGoogle();
      final user = userCredential?.user;
      if (user == null) {
        setState(() => _error = "User not found.");
        return;
      }

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userDoc = await userDocRef.get();

      // Auto-create profile only for Google sign-in
      if (!userDoc.exists) {
        final defaultUser = UserModel(email: user.email ?? '', role: 'user');
        await userDocRef.set(defaultUser.toMap());
      }

      final userData = (await userDocRef.get()).data();
      if (userData == null) {
        setState(() => _error = "User profile not found.");
        return;
      }

      final userModel = UserModel.fromMap(userData);

      if (userModel.role == 'admin') {
        setState(() => _error = 'Admins must log in with email and password.');
        await FirebaseAuth.instance.signOut();
        return;
      }

      Navigator.pushReplacementNamed(context, '/menu');
    } catch (e) {
      setState(() => _error = 'Google Sign-In failed. Try again.');
    }
  }

  void _showForgotPasswordDialog() {
    final _resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: _resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Enter your email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _resetEmailController.text.trim();
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password reset email sent."),
                    backgroundColor: Colors.green,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_mapFirebaseError(e.code)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Send Email"),
          ),
        ],
      ),
    );
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Login failed. Please try again.';
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
                  'Welcome Back!',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Login to continue ordering your favorite meals',
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
                          onPressed: _login,
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
                          child: Text('Login', style: AppTextStyles.button),
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
                    onPressed: _loginWithGoogle,
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        "Forgot Password?",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 1,
                      color: AppColors.textLight,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: Text(
                        "Sign up",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
