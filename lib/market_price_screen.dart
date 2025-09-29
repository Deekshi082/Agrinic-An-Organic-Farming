import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'crop_detail_screen.dart';

class MarketPriceScreen extends StatefulWidget {
  @override
  _MarketPriceScreenState createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final marketRef = FirebaseFirestore.instance.collection('market_prices');
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50), // Agrinic green
        elevation: 4,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search crops...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        )
            : Row(
          children: [
            Image.asset(
              'assets/images/logo2.png',
              height: 32,
            ),
            SizedBox(width: 8),
            Text(
              "Market Prices",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: marketRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('❌ Error loading data.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final crops = snapshot.data!.docs.where((doc) {
            final name = (doc['name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

          if (crops.isEmpty) {
            return Center(
              child: Text(
                "No market prices found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final name = crop['name'] ?? 'Unknown';
              final price = crop['price'] ?? 'N/A';
              final unit = crop['unit'] ?? '';
              final timestamp = crop['last_updated'];
              final lastUpdated = (timestamp != null && timestamp is Timestamp)
                  ? DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp.toDate())
                  : 'N/A';
              final cropId = crop['name'].toLowerCase();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFB2DFDB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.eco_outlined, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Price: ₹$price per $unit\n",
                          style: TextStyle(color: Color(0xFF388E3C)),
                        ),
                        TextSpan(
                          text: "Last Updated: $lastUpdated",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
