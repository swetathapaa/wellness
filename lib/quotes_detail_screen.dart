import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuotesDetailScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String type;

  const QuotesDetailScreen({
    Key? key,
    required this.categoryId,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  State<QuotesDetailScreen> createState() => _QuotesDetailScreenState();
}

class _QuotesDetailScreenState extends State<QuotesDetailScreen> {
  List<Map<String, dynamic>> entries = [];
  bool isLoading = true;

  final user = FirebaseAuth.instance.currentUser;
  Set<String> favoriteQuoteIds = {};

  @override
  void initState() {
    super.initState();
    fetchEntries();
    if (user != null) {
      fetchFavoriteQuotes();
    }
  }

  Future<void> fetchEntries() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where('type', isEqualTo: widget.type)
          .where('categoryId', isEqualTo: widget.categoryId)
          .get();

      final List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        final quote = doc.data()['quote']?.toString() ?? '';
        final author = doc.data()['author']?.toString() ?? '';
        return {
          'id': doc.id,
          'quote': quote,
          'author': author,
        };
      }).toList();

      setState(() {
        entries = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching entries: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchFavoriteQuotes() async {
    try {
      final favSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user!.uid)
          .get();

      final favIds = favSnapshot.docs.map((doc) => doc.data()['quoteId'] as String).toSet();

      setState(() {
        favoriteQuoteIds = favIds;
      });
    } catch (e) {
      print("❌ Error fetching favorites: $e");
    }
  }

  Future<void> toggleFavorite(String quoteId) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to favorite quotes.")),
      );
      return;
    }

    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

    final isCurrentlyFavorite = favoriteQuoteIds.contains(quoteId);

    try {
      if (isCurrentlyFavorite) {
        // Remove favorite
        final favDocs = await favoritesCollection
            .where('userId', isEqualTo: user!.uid)
            .where('quoteId', isEqualTo: quoteId)
            .get();

        for (var doc in favDocs.docs) {
          await favoritesCollection.doc(doc.id).delete();
        }

        setState(() {
          favoriteQuoteIds.remove(quoteId);
        });
      } else {
        // Add favorite
        await favoritesCollection.add({
          'userId': user!.uid,
          'quoteId': quoteId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          favoriteQuoteIds.add(quoteId);
        });
      }
    } catch (e) {
      print("❌ Error toggling favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update favorite: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
          ? Center(
        child: Text(
          'No ${widget.type} found in "${widget.title}".',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      )
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final quoteId = entry['id'] as String;
          final isFavorite = favoriteQuoteIds.contains(quoteId);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 80.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 28.sp,
                      ),
                      onPressed: () => toggleFavorite(quoteId),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Text(
                  '"${entry['quote']}"',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '- ${entry['author']}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Icon(Icons.keyboard_arrow_up, size: 40.sp, color: Colors.white),
                ),
                Center(
                  child: Text(
                    'Swipe up for more',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
