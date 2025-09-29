import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'crop_category_screen.dart';
import 'market_price_screen.dart';
import 'profile.dart';
import 'more.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SeasonalCropScreen(),
    CropCategoryScreen(),
    MarketPriceScreen(), // Replace with user MarketPriceScreen if needed
    ProfileScreen(),
    MoreScreen(), // Replace or remove if only 4 screens
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Crop Guide'),
    BottomNavigationBarItem(icon: Icon(Icons.price_change), label: 'Market'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF4CAF50),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title Screen'));
  }
}
