import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_screen.dart';
import 'quotes_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('entries').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          // Extract categories live from entries collection
          final Set<String> quoteCategories = {};
          final Set<String> healthCategories = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = (data['type'] as String?) ?? '';
            final category = (data['category'] as String?) ?? '';

            if (type == 'Quotes' && category.isNotEmpty) {
              quoteCategories.add(category);
            } else if (type == 'HealthTips' && category.isNotEmpty) {
              healthCategories.add(category);
            }
          }

          return SingleChildScrollView(
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
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
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

                // Today's Quote section
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
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('- Alice Morse Earle',
                            style:
                            TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Quotes Categories Section
                Text("Quotes",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 10.h),
                Column(
                  children: quoteCategories
                      .map((category) =>
                      _buildRectCategoryTile(context, category, 'Quotes'))
                      .toList(),
                ),

                SizedBox(height: 30.h),

                // Health Tips Categories Section
                Text("Health Tips",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 10.h),
                Column(
                  children: healthCategories
                      .map((category) =>
                      _buildRectCategoryTile(context, category, 'HealthTips'))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBox(IconData icon, String label) {
    return Container(
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
    );
  }

  Widget _buildRectCategoryTile(BuildContext context, String category, String type) {
    return GestureDetector(
      onTap: () async {
        final snapshot = await FirebaseFirestore.instance
            .collection('entries')
            .where('type', isEqualTo: type)
            .where('category', isEqualTo: category)
            .get();

        final entries = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        if (context.mounted && entries.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuotesDetailScreen(
                title: category,
                type: type,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No ${type == 'Quotes' ? 'quotes' : 'health tips'} found in "$category"')),
          );
        }
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
            Text(category,
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
