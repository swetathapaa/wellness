import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuotesDetailScreen extends StatefulWidget {
  final String title; // This should exactly match the 'category' field in Firestore
  final String type;  // "Quotes" or "HealthTips"

  const QuotesDetailScreen({
    Key? key,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  State<QuotesDetailScreen> createState() => _QuotesDetailScreenState();
}

class _QuotesDetailScreenState extends State<QuotesDetailScreen> {
  List<Map<String, dynamic>> quotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuotesByCategory();
  }

  Future<void> fetchQuotesByCategory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('entries')
          .where('type', isEqualTo: widget.type)
          .where('category', isEqualTo: widget.title)
          .get();

      final data = snapshot.docs.map((doc) {
        return {
          'quote': doc['quote'] ?? '',
          'author': doc['author'] ?? '',
        };
      }).toList();

      setState(() {
        quotes = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching ${widget.type} quotes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quotes.isEmpty
          ? Center(
        child: Text(
          'No ${widget.type} found in "${widget.title}".',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
          textAlign: TextAlign.center,
        ),
      )
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index]['quote'];
          final author = quotes[index]['author'];

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20.w, vertical: 80.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 40.h),
                Text('"$quote"',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.white)),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('- $author',
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.grey[400])),
                ),
                const Spacer(),
                Center(
                  child: Icon(Icons.keyboard_arrow_up,
                      size: 40.sp, color: Colors.white),
                ),
                Center(
                  child: Text('Swipe up for more',
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.grey[400])),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
