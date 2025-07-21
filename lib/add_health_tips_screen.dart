import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHealthTipsScreen extends StatefulWidget {
  const AddHealthTipsScreen({super.key});

  @override
  State<AddHealthTipsScreen> createState() => _AddHealthTipsScreenState();
}

class _AddHealthTipsScreenState extends State<AddHealthTipsScreen> {
  List<String> categories = [];
  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoadingCategories = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where('type', isEqualTo: 'HealthTips')
          .get();

      final cats = snapshot.docs
          .map((doc) => (doc.data()['category'] as String?) ?? '')
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();

      setState(() {
        categories = cats;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    }
  }

  Future<void> _submitTip() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (selectedCategory == null || title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Search for existing category document (without quote/title)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where('type', isEqualTo: 'HealthTips')
          .where('category', isEqualTo: selectedCategory)
          .get();

      DocumentSnapshot? existingDoc;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final hasQuote = data.containsKey('quote');
        final hasTitle = data.containsKey('title');
        if (!hasQuote && !hasTitle) {
          existingDoc = doc;
          break;
        }
      }

      if (existingDoc != null) {
        // Update existing document with new tip details
        await FirebaseFirestore.instance
            .collection('entries')
            .doc(existingDoc.id)
            .update({
          'title': title,
          'quote': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // No category doc found, create new document
        await FirebaseFirestore.instance.collection('entries').add({
          'category': selectedCategory,
          'title': title,
          'quote': description,
          'type': 'HealthTips',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Health tip added successfully.")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add health tip: $e")),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Add Health Tip"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : categories.isEmpty
            ? const Center(
          child: Text(
            "No categories found. Please add categories first.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        )
            : SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: inputBorder,
                  hintText: "Select a category",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                value: selectedCategory,
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 24),
              const Text(
                "Tip Title",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  hintText: "Enter tip title",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: inputBorder,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Write Health Tip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  hintText: "Enter health tip description",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: inputBorder,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submitTip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
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
