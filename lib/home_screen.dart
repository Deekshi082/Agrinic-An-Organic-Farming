import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'crop_detail_screen.dart';
import 'weather_detail_screen.dart'; // Added this import for navigation
import 'package:firebase_auth/firebase_auth.dart';

class SeasonalCropScreen extends StatefulWidget {
  @override
  _SeasonalCropScreenState createState() => _SeasonalCropScreenState();
}

class _SeasonalCropScreenState extends State<SeasonalCropScreen> {
  final String currentMonth = DateFormat('MMMM').format(DateTime.now()).toLowerCase();

  String location = "Loading...";
  String temperature = "--°C";
  String condition = "Loading...";
  String gifPath = "assets/animation/sunny.gif";
  final String apiKey = "add your API key";

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  void updateGif(String weatherDesc) {
    final condition = weatherDesc.toLowerCase();
    if (condition.contains("rain") && condition.contains("night")) {
      gifPath = "assets/animation/rainy_night.gif";
    } else if (condition.contains("storm") && condition.contains("day")) {
      gifPath = "assets/animation/storm_showers_day.gif";
    } else if (condition.contains("storm")) {
      gifPath = "assets/animation/storm.gif";
    } else if (condition.contains("thunder")) {
      gifPath = "assets/animation/thunder.gif";
    } else if (condition.contains("sunny")) {
      gifPath = "assets/animation/sunny.gif";
    } else if (condition.contains("cloud") && condition.contains("night")) {
      gifPath = "assets/animation/cloudy_night.gif";
    } else if (condition.contains("partly") && condition.contains("shower")) {
      gifPath = "assets/animation/partly_shower.gif";
    } else if (condition.contains("partly") && condition.contains("cloud")) {
      gifPath = "assets/animation/partly_cloudy.gif";
    } else if (condition.contains("overcast") || condition.contains("cloud")) {
      gifPath = "assets/animation/partly_cloudy.gif";
    } else if (condition.contains("mist")) {
      gifPath = "assets/animation/mist.gif";
    } else if (condition.contains("fog")) {
      gifPath = "assets/animation/foggy.gif";
    } else if (condition.contains("wind")) {
      gifPath = "assets/animation/windy.gif";
    } else if (condition.contains("night")) {
      gifPath = "assets/animation/night.gif";
    } else {
      gifPath = "assets/animation/sunny.gif";
    }
  }

  Future<void> getWeather() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          location = "Permission denied";
          temperature = "--";
          condition = "Cannot access location";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['name'];
        final temp = data['main']['temp'].toString();
        final weather = data['weather'][0]['description'];

        updateGif(weather);

        setState(() {
          location = city;
          temperature = "$temp°C";
          condition = weather[0].toUpperCase() + weather.substring(1);
        });
      } else {
        setState(() {
          location = "Unknown";
          temperature = "--";
          condition = "Failed to fetch";
        });
      }
    } catch (e) {
      setState(() {
        location = "Error";
        temperature = "--";
        condition = "Failed to get weather data";
      });
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropRef = FirebaseFirestore.instance.collection('seasonal_crops').doc(currentMonth);

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
            Text("Agrinic", style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: cropRef.get(),
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: getWeather,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox();
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text(
                            "Hello ...",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          );
                        }

                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        final name = userData['name'] ?? 'User';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Hello, $name ",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeatherDetailScreen(
                              location: location,
                              temperature: temperature,
                              condition: condition,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.green[50],
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.green[700]),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            location,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green[900]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      temperature,
                                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green[900]),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.cloud_outlined, color: Colors.green[700]),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            condition,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.green[800]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Image.asset(
                                    gifPath,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      Center(child: CircularProgressIndicator())
                    else if (!snapshot.hasData || !snapshot.data!.exists)
                      Center(child: Text("No crop suggestions found for this month."))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: (snapshot.data!.get('crops') as List<dynamic>).length,
                        itemBuilder: (context, index) {
                          final crops = (snapshot.data!.get('crops') as List<dynamic>).cast<Map<String, dynamic>>();
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
                              margin: EdgeInsets.symmetric(vertical: 8),
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
                                            color: Colors.green[900],
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
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
