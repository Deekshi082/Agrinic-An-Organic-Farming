import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_list_screen.dart';

class CropCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categoriesRef = FirebaseFirestore.instance.collection('crop_categories');

    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5), // Light greenish background for freshness
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50), // Agrinic green
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo2.png', // Your logo image
              height: 32,
            ),
            SizedBox(width: 8),
            Text(
              "Organic Crop Category",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['name']; // e.g., "Vegetables"
              final docId = category.id; // e.g., vegetables (lowercase id)

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    categoryName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green[800],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CropListScreen(
                          categoryId: docId,
                          categoryName: categoryName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
