import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  final String location;
  final String temperature;
  final String condition;

  const WeatherDetailScreen({
    required this.location,
    required this.temperature,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5), // Agrinic light background
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50), // Dark green app bar
        title: Text(
          "Weather Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            location,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32), // Darker green
            ),
          ),
          SizedBox(height: 10),
          Text(
            temperature,
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Color(0xFF388E3C), // Green shade
            ),
          ),
          Text(
            condition,
            style: TextStyle(fontSize: 20, color: Colors.grey[800]),
          ),
          SizedBox(height: 20),
          Divider(color: Colors.green[300]),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                final hour = DateTime.now().add(Duration(hours: index + 1));
                return ListTile(
                  leading: Icon(Icons.wb_sunny, color: Color(0xFF81C784)), // Light green sun
                  title: Text(
                    "${hour.hour}:00",
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: Text(
                    "${(20 + index * 2)}°C",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
