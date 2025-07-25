import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'forget_password_screen.dart';
import 'login_screen.dart';
import 'preference_screen.dart'; // Added this
// Removed admin_dashboard_screen.dart import

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String name = user?.displayName ?? "Guest User";
    String email = user?.email ?? "No email";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with Back Button and Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profile',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar + Name + Email Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E1E1E),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/images/avatar.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("Preferences",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                buildButton("Add More Preferences", Icons.add_circle_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PreferenceScreen()),
                  );
                }),

                const SizedBox(height: 30),
                const Text("Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                buildButton("Theme", Icons.dark_mode, () {}),
                const SizedBox(height: 10),
                buildButton("Change Password", Icons.lock_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                  );
                }),
                const SizedBox(height: 10),
                buildButton("Forgot Password", Icons.email_outlined, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgetPasswordScreen()),
                  );
                }),
                const SizedBox(height: 10),

                buildButton("Logout", Icons.logout, () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1E1E),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
