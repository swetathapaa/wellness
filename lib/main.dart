import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_category_screen.dart';
import 'add_health_tips_screen.dart';
import 'add_qoute_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'preference_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wellness App',
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(secondary: Color(0xFF262626)),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => SignUpScreen(),
            '/preference': (context) => const PreferenceScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/add_category': (context) => const AddCategoryScreen(),
            '/add_health_tip': (context) => const AddHealthTipsScreen(),
            '/add_quote': (context) => const AddQuoteScreen(),





          },
        );
      },
    );
  }
}
