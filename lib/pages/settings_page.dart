import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _feedbackMessage;

  Future<void> _updatePassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Password Change"),
        content: const Text("Are you sure you want to change your password?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      setState(() => _feedbackMessage = "✅ Password updated successfully.");
    } catch (e) {
      setState(() => _feedbackMessage = "❌ Failed to update password: $e");
    }
  }

  void _logout() async {
    final user = FirebaseAuth.instance.currentUser;
    final wasGuest = user?.isAnonymous ?? false;

    await _auth.signOut();
    if (wasGuest) {
      await user?.delete();
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isGuest
            ? Column(
          children: [
            const Text(
              "You're in guest mode.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Register"),
            ),
          ],
        )
            : Column(
          children: [
            if (_feedbackMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    color: _feedbackMessage!.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: "Current Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text("Update Password"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _logout,
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
