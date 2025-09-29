import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String location = "Loading...";
  String temperature = "--°C";
  String condition = "Loading...";
  String gifPath = "assets/animation/sunny.gif"; // Default fallback

  final String apiKey = "6a94b67394dd064f535ddbf2fb36c277"; // Replace if needed

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
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          location = "Permission denied";
          temperature = "--";
          condition = "Cannot access location";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

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
    return Scaffold(
      appBar:
      AppBar(title: Text("☁ Weather Info"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              gifPath,
              height: 180,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text("📍 Location: $location", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("🌡 Temperature: $temperature",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("☁ Condition: $condition", style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: getWeather,
              child: Text("🔄 Refresh"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
