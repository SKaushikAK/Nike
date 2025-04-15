import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Ball App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimatedBallScreen(),
    );
  }
}

class AnimatedBallScreen extends StatefulWidget {
  @override
  _AnimatedBallScreenState createState() => _AnimatedBallScreenState();
}

class _AnimatedBallScreenState extends State<AnimatedBallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animationOffset;
  late Animation<Color?> _animationColor;
  late Animation<double> _animationScale;

  bool _isAnimating = true;
  double _animationSpeed = 1.0;
  Color _ballColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _updateAnimations();
  }

  void _updateAnimations() {
    _animationOffset =
        Tween<Offset>(begin: Offset(-1, 0), end: Offset(1, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _animationColor = ColorTween(begin: _ballColor, end: Colors.red).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _animationScale = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _toggleAnimation() {
    setState(() {
      if (_isAnimating) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
      _isAnimating = !_isAnimating;
    });
  }

  void _changeSpeed(double speed) {
    setState(() {
      _animationSpeed = speed;
      _controller.duration = Duration(seconds: (2 / _animationSpeed).round());
      _controller.repeat(reverse: true);
    });
  }

  void _changeColor(Color color) {
    setState(() {
      _ballColor = color;
      _updateAnimations();
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Ball App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: SlideTransition(
                  position: _animationOffset,
                  child: ScaleTransition(
                    scale: _animationScale,
                    child: AnimatedBuilder(
                      animation: _animationColor,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _animationColor.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleAnimation,
                  child: Text(_isAnimating ? 'Stop' : 'Start'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Speed'),
                Slider(
                  value: _animationSpeed,
                  min: 0.1,
                  max: 3.0,
                  divisions: 30,
                  label: _animationSpeed.toStringAsFixed(1),
                  onChanged: (value) {
                    _changeSpeed(value);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Color'),
                DropdownButton<Color>(
                  value: _ballColor,
                  onChanged: (Color? newValue) {
                    if (newValue != null) {
                      _changeColor(newValue);
                    }
                  },
                  items: <Color>[
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.purple
                  ].map<DropdownMenuItem<Color>>((Color value) {
                    return DropdownMenuItem<Color>(
                      value: value,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: value,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
