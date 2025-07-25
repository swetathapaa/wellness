import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  List<Map<String, String>> preferences = [];
  String? selectedPreferenceId;

  // New: selected type toggle value, default "Quotes"
  String selectedType = "Quotes";

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('preferences').get();

      final prefs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': (data['name'] ?? '').toString(),
          'id': (data['preferenceId'] ?? doc.id).toString(),
        };
      }).toList();

      setState(() {
        preferences = prefs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load preferences: $e")),
      );
    }
  }

  void _submitCategory() async {
    final name = _categoryNameController.text.trim();

    if (name.isEmpty || selectedPreferenceId == null || selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter category, select preference and type")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'categoryName': name,
        'preferenceId': selectedPreferenceId,
        'type': selectedType, // <-- save the selected type here
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category added successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add category: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildTypeToggle(String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        width: 120.w,
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[700] : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.grey[400]! : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Add Category", style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Category Name",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextField(
                controller: _categoryNameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: border,
                  hintText: "Enter category name",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              SizedBox(height: 24.h),
              Text("Select Preference",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),
              preferences.isEmpty
                  ? const Text(
                "No preferences available.",
                style: TextStyle(color: Colors.white70),
              )
                  : DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                value: selectedPreferenceId,
                items: preferences.map((pref) {
                  return DropdownMenuItem<String>(
                    value: pref['id'],
                    child: Text(pref['name'] ?? '',
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPreferenceId = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: border,
                  hintText: "Select preference",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              SizedBox(height: 24.h),

              // New toggle UI for type selection
              Text("Select Category Type",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeToggle("Quotes", selectedType == "Quotes"),
                  SizedBox(width: 16.w),
                  _buildTypeToggle("HealthTips", selectedType == "HealthTips"),
                ],
              ),

              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
