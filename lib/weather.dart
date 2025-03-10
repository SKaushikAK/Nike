import 'package:flutter/material.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController tempController = TextEditingController();
  Color bgColor = Colors.white; // Default background color
  String weatherCondition = ""; // To display "Cool", "Normal", "Hot"

  void updateWeather() {
    double temp = double.tryParse(tempController.text) ?? 0;

    setState(() {
      if (temp <= 20) {
        bgColor = Colors.lightBlueAccent;
        weatherCondition = "Cool ❄️";
      } else if (temp > 20 && temp <= 35) {
        bgColor = Colors.greenAccent;
        weatherCondition = "Normal 🌤️";
      } else {
        bgColor = Colors.orangeAccent;
        weatherCondition = "Hot 🔥";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: tempController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Temperature (°C)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateWeather,
              child: const Text("Check Weather"),
            ),
            const SizedBox(height: 20),
            Text(
              weatherCondition,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
