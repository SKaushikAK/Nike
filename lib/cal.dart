import 'package:flutter/material.dart';

class Cal extends StatefulWidget {
  const Cal({Key? key}) : super(key: key);

  @override
  State<Cal> createState() => _CalState();
}

class _CalState extends State<Cal> {
  final TextEditingController num1Controller = TextEditingController();
  final TextEditingController num2Controller = TextEditingController();

  String selectedOperation = "Add"; // Default operation
  final List<String> operations = ["Add", "Subtract", "Multiply", "Divide"];
  String result = ""; // To store result

  void calculateResult() {
    double num1 = double.tryParse(num1Controller.text) ?? 0;
    double num2 = double.tryParse(num2Controller.text) ?? 0;
    double res = 0;

    switch (selectedOperation) {
      case "Add":
        res = num1 + num2;
        break;
      case "Subtract":
        res = num1 - num2;
        break;
      case "Multiply":
        res = num1 * num2;
        break;
      case "Divide":
        res = num2 != 0 ? num1 / num2 : double.infinity; // Avoid division by zero
        break;
    }

    setState(() {
      result = "Result: $res";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter first number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter second number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedOperation,
              items: operations.map((String operation) {
                return DropdownMenuItem<String>(
                  value: operation,
                  child: Text(operation),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOperation = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Operation",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateResult,
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
