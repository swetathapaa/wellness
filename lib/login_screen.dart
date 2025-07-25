import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'preference_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserInFirestore(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'customer',
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> navigateBasedOnRole(User user) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final role = userDoc.data()?['role']?.toString().trim() ?? 'customer';

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      // For customers, check if preferences exist
      final prefSnapshot = await FirebaseFirestore.instance
          .collection('user_preference')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (prefSnapshot.docs.isNotEmpty) {
        // User already selected preferences
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        // First time login, go to preference screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PreferenceScreen()),
        );
      }
    }
  }

  Future<void> loginWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await createUserInFirestore(user);
        await navigateBasedOnRole(user);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Always show popup

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await createUserInFirestore(user);
        await navigateBasedOnRole(user);
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Google Sign-In Failed'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40.h),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: loginWithEmail,
                    child: Text('Login', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google.png', height: 24.h),
                        SizedBox(width: 10.w),
                        Text("Sign in with Google",
                            style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
