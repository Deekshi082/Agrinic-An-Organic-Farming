import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }

  void logoutUser() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(child: Text("Cancel", style: TextStyle(color: Colors.green[900])), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text("Logout", style: TextStyle(color: Colors.redAccent)), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    }
  }

  void showEditDialog() {
    final nameController = TextEditingController(text: userData!['name']);
    final phoneController = TextEditingController(text: userData!['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFFF5FFF5),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[100],
              foregroundColor: Colors.green[900],
              elevation: 0,
            ),
            onPressed: () async {
              await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              });
              Navigator.pop(context);
              fetchUserData();
            },
            child: Text(
              "Save",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo2.png',
              height: 32,
            ),
            SizedBox(width: 8),
            Text("Profile", style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: showEditDialog,
            tooltip: "Edit Profile",
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : userData == null
          ? Center(child: Text("No user data found.", style: TextStyle(color: Colors.red)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green[100],
              backgroundImage: userData!['photoUrl'] != null
                  ? NetworkImage(userData!['photoUrl'])
                  : null,
              child: userData!['photoUrl'] == null
                  ? Icon(Icons.person, size: 50, color: Colors.green[700])
                  : null,
            ),
            SizedBox(height: 16),
            buildUserInfoTile("Name", userData!['name'], Icons.person),
            buildUserInfoTile("Email", user!.email ?? '', Icons.email),
            buildUserInfoTile("Phone", userData!['phone'], Icons.phone),
            Spacer(),
            ElevatedButton.icon(
              onPressed: logoutUser,
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoTile(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[900])),
        subtitle: Text(value, style: TextStyle(color: Colors.black87)),
      ),
    );
  }
}
