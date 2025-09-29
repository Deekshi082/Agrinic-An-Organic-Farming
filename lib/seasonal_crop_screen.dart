import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'crop_detail_screen.dart'; // Make sure this file has CropDetailScreen class

class SeasonalCropScreen extends StatelessWidget {
  final String currentMonth = DateFormat('MMMM').format(DateTime.now()).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final cropRef = FirebaseFirestore.instance.collection('seasonal_crops').doc(currentMonth);

    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      appBar: AppBar(
        title: Text("Agrinic"),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: cropRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No crop suggestions found for this month."));
          }

          final crops = (snapshot.data!.get('crops') as List<dynamic>).cast<Map<String, dynamic>>();

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final cropId = crop['name'].toLowerCase();

              return GestureDetector(
                onTap: () async {
                  try {
                    final guideSnapshot = await FirebaseFirestore.instance
                        .collection('crops')
                        .doc(cropId)
                        .get();

                    if (guideSnapshot.exists) {
                      final steps = List<Map<String, dynamic>>.from(guideSnapshot.get('steps'));
                      final imageName = guideSnapshot.get('imageName');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CropDetailScreen(
                            cropName: crop['name'],
                            steps: steps,
                            imageName: imageName,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Guide not found for ${crop['name']}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Card(
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.asset(
                          'assets/images/${crop['image']}',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            SizedBox(height: 6),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('crop_stats')
                                  .doc(cropId)
                                  .snapshots(),
                              builder: (context, statSnap) {
                                if (statSnap.hasData && statSnap.data!.exists) {
                                  final data = statSnap.data!;
                                  int total = data['total_attempts'] ?? 0;
                                  int success = data['successful_attempts'] ?? 0;
                                  double rate = (total > 0) ? (success / total) * 100 : 0;
                                  return Text(
                                    "Success Rate: ${rate.toStringAsFixed(1)}%",
                                    style: TextStyle(color: Colors.green[700]),
                                  );
                                } else {
                                  return Text(
                                    "Success Rate: N/A",
                                    style: TextStyle(color: Colors.grey[600]),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            Text(crop['description']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
