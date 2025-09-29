import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_detail_screen.dart';

class CropListScreen extends StatelessWidget {
  final String categoryId;   // document id in crop_categories (lowercase)
  final String categoryName; // display name

  CropListScreen({required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final categoryRef = FirebaseFirestore.instance.collection('crop_categories').doc(categoryId);

    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5), // light greenish background
      appBar: AppBar(
        title: Text(
          "$categoryName Crops",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF4CAF50), // Agrinic green
        elevation: 2,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: categoryRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List cropsList = data['crops']; // e.g. ["Tomato", "Carrot", ...]

          return ListView.builder(
            itemCount: cropsList.length,
            itemBuilder: (context, index) {
              final cropName = cropsList[index]; // capitalized name
              final cropDocId = cropName.toString().toLowerCase().replaceAll(' ', '_');

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('crops').doc(cropDocId).get(),
                builder: (context, cropSnapshot) {
                  if (cropSnapshot.hasError) return SizedBox();
                  if (!cropSnapshot.hasData) return SizedBox();

                  final cropData = cropSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage('assets/images/${cropData['imageName']}'),
                        backgroundColor: Colors.green[100],
                      ),
                      title: Text(
                        cropData['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CropDetailScreen(
                              cropName: cropData['name'],
                              steps: List<Map<String, dynamic>>.from(cropData['steps']),
                              imageName: cropData['imageName'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
