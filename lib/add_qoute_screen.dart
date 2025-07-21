import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  List<String> categories = [];
  String? selectedCategory;
  final TextEditingController authorController = TextEditingController();
  final TextEditingController quoteController = TextEditingController();
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where('type', isEqualTo: 'Quotes')
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

  void _saveQuote() async {
    if (selectedCategory == null ||
        authorController.text.trim().isEmpty ||
        quoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final quoteData = {
      'category': selectedCategory!,
      'author': authorController.text.trim(),
      'quote': quoteController.text.trim(),
      'title': selectedCategory!,  // You can set title same as category or as needed
      'type': 'Quotes',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('entries').add(quoteData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quote added successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add quote: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Add Quote"),
        backgroundColor: const Color(0xFF121212),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                      borderSide:
                      const BorderSide(color: Colors.white)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat,
                      style:
                      const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedCategory = value),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Author Name",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                      borderSide:
                      const BorderSide(color: Colors.white)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  hintText: "Enter author name",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Quote",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quoteController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                      borderSide:
                      const BorderSide(color: Colors.white)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  hintText: "Enter your quote here",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF323232),
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Quote",
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
