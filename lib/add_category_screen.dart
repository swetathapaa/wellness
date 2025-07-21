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
  String _selectedType = 'Quotes'; // Use capitalized type here
  bool _isSaving = false;

  void _submitCategory() async {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a category name")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('entries').add({
        'type': _selectedType,       // <-- Save type as 'Quotes' or 'HealthTips' exactly
        'category': name,            // Category name
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
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildCategoryTypeOption(String displayType, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700),
          color: Colors.grey.shade900,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: Colors.white,
              fillColor: MaterialStateProperty.all(Colors.white),
            ),
            SizedBox(width: 8.w),
            Text(
              displayType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          "Tap to Choose Image",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Category",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Category Name
              Text(
                "Category Name",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _categoryNameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Enter category name",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              SizedBox(height: 24.h),

              /// Category Type
              Text(
                "Category Type",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildCategoryTypeOption('Quotes', 'Quotes')),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildCategoryTypeOption('Health', 'HealthTips')),
                ],
              ),
              SizedBox(height: 24.h),

              /// Choose Image
              Text(
                "Choose Image for Category",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              _buildImagePickerBox(),
              SizedBox(height: 40.h),

              /// Save Button
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
                      : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
