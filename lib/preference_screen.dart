import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dashboard_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final List<String> allTopics = [
    "Hard times",
    "Working out",
    "Productivity",
    "Self-esteem",
    "Achieving goals",
    "Inspiration",
    "Letting go",
    "Love",
    "Relationships",
    "Faith and spirituality",
    "Positive thinking",
    "Stress and anxiety",
  ];

  final Set<String> selectedTopics = {};

  void toggleSelection(String topic) {
    setState(() {
      if (selectedTopics.contains(topic)) {
        selectedTopics.remove(topic);
      } else {
        selectedTopics.add(topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80.h),
            Text(
              'Select all topics that motivates you',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: allTopics.map((topic) {
                    final isSelected = selectedTopics.contains(topic);
                    return GestureDetector(
                      onTap: () => toggleSelection(topic),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                          isSelected ? Colors.white : Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                            isSelected ? Colors.black : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()),

                  );
                },

                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
