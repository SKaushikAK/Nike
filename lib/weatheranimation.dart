import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Animation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _weatherCondition = 'sunny';
  double _iconSize = 100.0;
  Duration _duration = Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Animation App'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Animated weather icon container
          AnimatedContainer(
            duration: _duration,
            curve: Curves.easeInOut,
            width: _iconSize,
            height: _iconSize,
            child: AnimatedSwitcher(
              duration: _duration,
              child: _getWeatherIcon(_weatherCondition),
            ),
          ),
          SizedBox(height: 40),

          // Weather buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildWeatherButton('Sunny', Icons.wb_sunny, 'sunny'),
              SizedBox(width: 20),
              _buildWeatherButton('Cloudy', Icons.cloud, 'cloudy'),
              SizedBox(width: 20),
              _buildWeatherButton('Rainy', Icons.beach_access, 'rainy'),
              SizedBox(width: 20),
              _buildWeatherButton('Snowy', Icons.ac_unit, 'snowy'),
            ],
          ),
        ],
      ),
    );
  }

  // Function to return the respective weather icon
  Widget _getWeatherIcon(String condition) {
    switch (condition) {
      case 'sunny':
        return Icon(
          Icons.wb_sunny,
          key: ValueKey('sunny'),
          size: _iconSize,
          color: Colors.yellow,
        );
      case 'cloudy':
        return Icon(
          Icons.cloud,
          key: ValueKey('cloudy'),
          size: _iconSize,
          color: Colors.grey,
        );
      case 'rainy':
        return Icon(
          Icons.beach_access,
          key: ValueKey('rainy'),
          size: _iconSize,
          color: Colors.blue,
        );
      case 'snowy':
        return Icon(
          Icons.ac_unit,
          key: ValueKey('snowy'),
          size: _iconSize,
          color: Colors.lightBlue,
        );
      default:
        return Icon(
          Icons.help_outline,
          key: ValueKey('default'),
          size: _iconSize,
        );
    }
  }

  // Function to build each weather button
  Widget _buildWeatherButton(String label, IconData icon, String condition) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _weatherCondition = condition;
          _iconSize = 150.0; // Increase size on button press
          _duration = Duration(seconds: 1); // Duration for animation
        });

        // After animation, reduce the icon size for a visual effect
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _iconSize = 100.0; // Reset size
          });
        });
      },
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
