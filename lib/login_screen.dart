import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
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
      }

      Navigator.pushNamed(context, '/preference'); // or '/dashboard'
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user cancelled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await createUserInFirestore(user);
      }

      Navigator.pushNamed(context, '/preference');
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
      backgroundColor: Colors.black, // keep original theme
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
                      side: BorderSide(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google.png', height: 24.h),
                        SizedBox(width: 10.w),
                        Text("Sign in with Google",
                            style:
                            TextStyle(color: Colors.white, fontSize: 14.sp)),
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
