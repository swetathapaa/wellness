import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_health_tips_screen.dart';
import 'add_qoute_screen.dart';
import 'add_category_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Stream<int> usersCountStream;
  late final Stream<int> categoriesCountStream;
  late final Stream<int> quotesCountStream;
  late final Stream<int> healthTipsCountStream;

  @override
  void initState() {
    super.initState();

    // Stream for total users count
    usersCountStream = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);

    // Stream for unique categories count (from Quotes and HealthTips docs)
    categoriesCountStream = FirebaseFirestore.instance
        .collection('entries')
        .snapshots()
        .map((snapshot) {
      final categories = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? '';
        final category = data['category'] as String? ?? '';

        if ((type == 'Quotes' || type == 'HealthTips') && category.isNotEmpty) {
          categories.add(category);
        }
      }
      return categories.length;
    });

    // Stream for total quotes count
    quotesCountStream = FirebaseFirestore.instance
        .collection('entries')
        .where('type', isEqualTo: 'Quotes')
        .snapshots()
        .map((snapshot) => snapshot.size);

    // Stream for total health tips count
    healthTipsCountStream = FirebaseFirestore.instance
        .collection('entries')
        .where('type', isEqualTo: 'HealthTips')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Dashboard", style: TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              StreamBuilder<int>(
                stream: usersCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return dashboardCard(
                    icon: Icons.groups,
                    label: 'Total Users',
                    count: count,
                    isAddVisible: false,
                  );
                },
              ),
              StreamBuilder<int>(
                stream: categoriesCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return dashboardCard(
                    label: 'Total Categories',
                    count: count,
                    isAddVisible: true,
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddCategoryScreen()),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<int>(
                stream: quotesCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return dashboardCard(
                    label: 'Total Quotes',
                    count: count,
                    isAddVisible: true,
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddQuoteScreen()),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<int>(
                stream: healthTipsCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return dashboardCard(
                    label: 'Total Health Tips',
                    count: count,
                    isAddVisible: true,
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHealthTipsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String label,
    required int count,
    bool isAddVisible = true,
    IconData? icon,
    VoidCallback? onAdd,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          if (icon != null)
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 40.sp),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          const Spacer(),
          if (isAddVisible)
            Column(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: Colors.grey[800],
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.white, size: 16.sp),
                    onPressed: onAdd,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Add New",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}
