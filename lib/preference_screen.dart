import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> allTopics = [];
  final Set<String> selectedTopics = {};
  Map<String, String> topicNameToId = {};

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    try {
      final snapshot = await _firestore.collection('preferences').get();

      final names = <String>[];
      final nameToId = <String, String>{};

      for (var doc in snapshot.docs) {
        final name = doc['name'] as String? ?? 'Unnamed';
        names.add(name);
        nameToId[name] = doc.id;
      }

      setState(() {
        allTopics = names;
        topicNameToId = nameToId;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching preferences: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching preferences')),
      );
    }
  }

  void toggleSelection(String topic) {
    setState(() {
      if (selectedTopics.contains(topic)) {
        selectedTopics.remove(topic);
      } else {
        selectedTopics.add(topic);
      }
    });
  }

  Future<void> submitPreferences() async {
    if (selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one topic.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      final existingPrefsSnapshot = await _firestore
          .collection('user_preference')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Extract existing preferenceIds for the user
      final existingPrefIds = existingPrefsSnapshot.docs
          .map((doc) => doc['preferenceId'] as String)
          .toSet();

      final batch = _firestore.batch();

      for (var topic in selectedTopics) {
        final prefId = topicNameToId[topic];
        if (prefId != null && !existingPrefIds.contains(prefId)) {
          final docRef = _firestore.collection('user_preference').doc();
          batch.set(docRef, {
            'id': docRef.id,
            'userId': user.uid,
            'preferenceId': prefId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preferences saved successfully.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      print("Error saving preferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // dark background
      appBar: AppBar(
        title: const Text("Select Preferences"),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Select all topics that motivate you',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: allTopics.length,
              itemBuilder: (context, index) {
                final topic = allTopics[index];
                final isSelected = selectedTopics.contains(topic);

                return GestureDetector(
                  onTap: () => toggleSelection(topic),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? Colors.white : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                        isSelected ? Colors.black : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitPreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  isSubmitting ? "Saving..." : "Continue",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
