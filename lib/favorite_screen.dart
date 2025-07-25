import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> favoriteQuotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchFavorites();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFavorites() async {
    try {
      final favSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user!.uid)
          .get();

      final quoteIds = favSnapshot.docs
          .map((doc) => doc.data()['quoteId'] as String)
          .toList();

      if (quoteIds.isEmpty) {
        setState(() {
          favoriteQuotes = [];
          isLoading = false;
        });
        return;
      }

      // Fetch the actual quote entries from 'entries' collection
      final entriesSnapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where(FieldPath.documentId, whereIn: quoteIds)
          .get();

      final quotes = entriesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'quote': data['quote'] ?? '',
          'author': data['author'] ?? '',
          'title': data['title'] ?? '',
        };
      }).toList();

      setState(() {
        favoriteQuotes = quotes;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching favorite quotes: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading favorites: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteQuotes.isEmpty
          ? const Center(
        child: Text(
          "You haven’t favorited any quotes yet.",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: favoriteQuotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final quote = favoriteQuotes[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (quote['title'] != null && quote['title'].toString().isNotEmpty)
                  Text(
                    quote['title'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '"${quote['quote']}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '- ${quote['author']}',
                    style: TextStyle(color: Colors.grey[400]),
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
