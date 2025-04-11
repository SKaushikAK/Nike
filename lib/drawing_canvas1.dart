import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

enum ShapeType { point, line, rectangle, circle }

class MyApp extends StatelessWidget {
  final GlobalKey<_DrawingCanvasState> canvasKey =
      GlobalKey<_DrawingCanvasState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: Text('Drawing App')),
        body: Column(
          children: [
            Expanded(child: DrawingCanvas(key: canvasKey)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        canvasKey.currentState?.updateShape(ShapeType.point),
                    child: Text("Point"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        canvasKey.currentState?.updateShape(ShapeType.line),
                    child: Text("Line"),
                  ),
                  ElevatedButton(
                    onPressed: () => canvasKey.currentState
                        ?.updateShape(ShapeType.rectangle),
                    child: Text("Rectangle"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        canvasKey.currentState?.updateShape(ShapeType.circle),
                    child: Text("Circle"),
                  ),
                  ElevatedButton(
                    onPressed: () => canvasKey.currentState?.clearCanvas(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: Text("Clear"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  DrawingCanvas({Key? key}) : super(key: key);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  ShapeType _currentShape = ShapeType.point;
  List<Offset> _points = [];
  List<DrawnShape> _shapes = [];

  void updateShape(ShapeType shape) {
    setState(() {
      _currentShape = shape;
    });
  }

  void clearCanvas() {
    setState(() {
      _shapes.clear();
      _points.clear();
    });
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      if (_currentShape == ShapeType.point) {
        _shapes.add(DrawnShape(_currentShape, [details.localPosition]));
      } else if (_points.length == 0 || _points.length == 1) {
        _points.add(details.localPosition);
        if ((_currentShape != ShapeType.point && _points.length == 2)) {
          _shapes.add(DrawnShape(_currentShape, List.from(_points)));
          _points.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: CustomPaint(
        painter: ShapePainter(_shapes),
        size: Size.infinite,
      ),
    );
  }
}

class DrawnShape {
  final ShapeType type;
  final List<Offset> points;

  DrawnShape(this.type, this.points);
}

class ShapePainter extends CustomPainter {
  final List<DrawnShape> shapes;

  ShapePainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (var shape in shapes) {
      switch (shape.type) {
        case ShapeType.point:
          canvas.drawCircle(
              shape.points[0], 3.0, paint..style = PaintingStyle.fill);
          break;
        case ShapeType.line:
          canvas.drawLine(shape.points[0], shape.points[1], paint);
          break;
        case ShapeType.rectangle:
          final rect = Rect.fromPoints(shape.points[0], shape.points[1]);
          canvas.drawRect(rect, paint);
          break;
        case ShapeType.circle:
          final center = (shape.points[0] + shape.points[1]) / 2;
          final radius = (shape.points[0] - shape.points[1]).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
