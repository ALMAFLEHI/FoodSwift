import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String error = '';

  Future<void> _changePassword() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      // Step 1: Reauthenticate
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Step 2: Update password
      if (newPasswordController.text == confirmPasswordController.text) {
        await user.updatePassword(newPasswordController.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        setState(() {
          error = 'New passwords do not match.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Authentication failed');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _changePassword,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
