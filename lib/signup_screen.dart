import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness/preference_screen.dart';

import 'dashboard_screen.dart'; // Adjust the path as per your project

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool rememberMe = false;
  bool isLoading = false;
  String errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> createUserInFirestore(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signUp() async {
    setState(() {
      errorMessage = '';
    });

    if (nameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your name";
      });
      return;
    }
    if (emailController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter your email";
      });
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      setState(() {
        errorMessage = "Please enter a valid email";
      });
      return;
    }
    if (passwordController.text.trim().length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters";
      });
      return;
    }
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(nameController.text.trim());

      final user = userCredential.user;
      if (user != null) {
        await createUserInFirestore(user);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PreferenceScreen(
        )),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "An error occurred";
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return; // user cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await createUserInFirestore(user);
      }

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PreferenceScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Google sign-in failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your wellness journey today',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32.h),

                // Name Field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/person.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.h),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/mail.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.email, color: Colors.white),
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/lock.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.lock, color: Colors.white),
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.h),

                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/lock.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.lock_outline, color: Colors.white),
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.h),

                // Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                    ),
                    const Text('Remember Me', style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 16.h),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                  ),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Sign Up', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),

                SizedBox(height: 20.h),

                // Google Sign Up
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(
                      'Sign up with Google',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : signInWithGoogle,
                  ),
                ),

                SizedBox(height: 24.h),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      "Already have an account? Login",
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
