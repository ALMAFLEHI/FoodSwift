import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'change_password_dialog.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool showUid = false;
  String appVersion = '...';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: ['email'],
  );

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  Future<void> _signOut() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Check if signed in with Google
      final isGoogle =
          user?.providerData.any((info) => info.providerId == 'google.com') ??
          false;

      // 1. Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Only sign out from Google if signed in with Google
      if (isGoogle) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            const Text(
              '👤 Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? "N/A"}'),
            const Divider(height: 32),

            const Text(
              '🔐 Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showUid ? 'UID: ${user?.uid ?? "N/A"}' : 'UID: **********',
                ),
                TextButton(
                  onPressed: () => setState(() => showUid = !showUid),
                  child: Text(showUid ? 'Hide' : 'View'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ChangePasswordDialog(),
                );
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change Password'),
            ),

            const Divider(height: 32),
            const Text(
              'ℹ️ About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('App Version: $appVersion'),

            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
