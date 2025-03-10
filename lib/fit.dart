import 'package:flutter/material.dart';

class FitnessApp extends StatefulWidget {
  const FitnessApp({Key? key}) : super(key: key);

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> {
  final TextEditingController durationController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  String result = "";

  void calculateCalories() {
    double duration = double.tryParse(durationController.text) ?? 0;
    double distance = double.tryParse(distanceController.text) ?? 0;
    double caloriesBurned = distance * duration; // Calories per km

    setState(() {
      result = "Calories Burned: ${caloriesBurned.toStringAsFixed(2)} kcal";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Tracker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter duration (minutes)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter distance (km)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateCalories,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
