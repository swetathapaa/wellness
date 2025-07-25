import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'profile_screen.dart';
import 'quotes_detail_screen.dart';
import 'favorite_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, String> quoteCategories = {};
  Map<String, String> healthCategories = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategoriesBasedOnUserPreferences();
  }

  Future<void> loadCategoriesBasedOnUserPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userPrefSnap = await _firestore
          .collection('user_preference')
          .where('userId', isEqualTo: user.uid)
          .get();

      final preferenceIds = userPrefSnap.docs
          .map((doc) => doc['preferenceId'] as String)
          .toSet();

      final categoriesSnap = await _firestore.collection('categories').get();

      for (var doc in categoriesSnap.docs) {
        final data = doc.data();
        final prefId = data['preferenceId'];
        final type = data['type'] ?? 'Quotes';
        final categoryName = data['categoryName'];
        final categoryId = doc.id;

        if (preferenceIds.contains(prefId)) {
          final entrySnap = await _firestore
              .collection('entries')
              .where('categoryId', isEqualTo: categoryId)
              .limit(1)
              .get();

          if (entrySnap.docs.isNotEmpty) {
            final entryType = entrySnap.docs.first['type'];
            if (entryType == 'Quotes') {
              quoteCategories[categoryName] = categoryId;
            } else if (entryType == 'HealthTips') {
              healthCategories[categoryName] = categoryId;
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Explore",
                    style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage:
                    const AssetImage('assets/images/avatar.png'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Favorites & Remind Me Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBox(Icons.favorite_border, "My Favorites"),
                _buildBox(Icons.alarm, "Remind Me"),
              ],
            ),

            SizedBox(height: 30.h),

            // Today's Quote
            Text("Today's Quote",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"Every day may not be good, but there is something good in every day."',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('- Alice Morse Earle',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 14.sp)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // Quotes Section
            Text("Quotes",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10.h),
            Column(
              children: quoteCategories.entries
                  .map((entry) => _buildRectCategoryTile(
                  context, entry.key, entry.value, 'Quotes'))
                  .toList(),
            ),

            SizedBox(height: 30.h),

            // Health Tips Section
            Text("Health Tips",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10.h),
            Column(
              children: healthCategories.entries
                  .map((entry) => _buildRectCategoryTile(
                  context, entry.key, entry.value, 'HealthTips'))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "My Favorites") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyFavoritesScreen()),
          );
        } else if (label == "Remind Me") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Remind Me coming soon!")),
          );
        }
      },
      child: Container(
        width: 150.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8.w),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildRectCategoryTile(
      BuildContext context, String categoryName, String categoryId, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuotesDetailScreen(
              title: categoryName,
              categoryId: categoryId,
              type: type,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(categoryName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
