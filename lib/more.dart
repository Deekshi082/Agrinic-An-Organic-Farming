import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'seasonal_crop_screen.dart';
import 'weather_screen.dart';
import 'crop_category_screen.dart';
import 'market_price_screen.dart';
import 'admin_login_screen.dart';
import 'video_screen.dart';


class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo2.png', // Your logo image
              height: 32,
            ),
            SizedBox(width: 8),
            Text("Agrinic",style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 25),

            HomeCardButton(
              title: "Watch Organic Farming Videos",
              icon: Icons.video_library,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VideoScreen()), // You define this screen
                );
              },
            ),

            HomeCardButton(
              title: "Admin: Manage Market Prices",
              icon: Icons.admin_panel_settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminLoginScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class HomeCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HomeCardButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[700], size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
