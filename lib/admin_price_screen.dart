import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPriceScreen extends StatefulWidget {
  @override
  _AdminPriceScreenState createState() => _AdminPriceScreenState();
}

class _AdminPriceScreenState extends State<AdminPriceScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final searchController = TextEditingController();

  String searchQuery = '';

  void addOrUpdateCropPrice({String? docId}) async {
    String name = nameController.text.trim().toLowerCase();
    double? price = double.tryParse(priceController.text.trim());
    String unit = unitController.text.trim();

    if (name.isEmpty || price == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("market_prices").doc(name).set({
      'name': name[0].toUpperCase() + name.substring(1),
      'price': price,
      'unit': unit,
      'last_updated': Timestamp.now(),
    });

    nameController.clear();
    priceController.clear();
    unitController.clear();
  }

  void loadCropData(DocumentSnapshot doc) {
    nameController.text = doc['name'];
    priceController.text = doc['price'].toString();
    unitController.text = doc['unit'];
  }

  void deleteCrop(String docId) {
    FirebaseFirestore.instance.collection('market_prices').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FFF4), // Match AdminLoginScreen background
      appBar: AppBar(
        title: Text(
          "Admin Crop Prices",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4CAF50), // Agrinic Green
        centerTitle: true,
        elevation: 3,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(nameController, 'Crop Name'),
            SizedBox(height: 10),
            _buildTextField(priceController, 'Price', keyboardType: TextInputType.number),
            SizedBox(height: 10),
            _buildTextField(unitController, 'Unit (e.g. kg)'),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addOrUpdateCropPrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Add / Update Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Divider(height: 30, thickness: 1),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Crop",
                labelStyle: TextStyle(color: Colors.green[800]),
                prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.green[700]),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.green.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('market_prices').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            "${doc['name']} - ₹${doc['price']} / ${doc['unit']}",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            "Updated: ${doc['last_updated'].toDate().toLocal()}",
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF1976D2)),
                                onPressed: () => loadCropData(doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Color(0xFFD32F2F)),
                                onPressed: () => deleteCrop(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[800]),
        prefixIcon: Icon(Icons.edit, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
