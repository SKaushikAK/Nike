import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// environment:
//   sdk: ">2.12.0 <3.7.0"
//   # > 2.12.0 < 3.7.0 

// # Dependencies specify other packages that your package needs in order to work.
// # To automatically upgrade your package dependencies to the latest versions
// # consider running `flutter pub upgrade --major-versions`. Alternatively,
// # dependencies can be manually updated by changing the version numbers below to
// # the latest version available on pub.dev. To see which dependencies have newer
// # versions available, run `flutter pub outdated`.
// dependencies:
//   flutter:
//     sdk: flutter
//   screenshot: ^2.1.0
//   path_provider: ^2.0.15

//   # The following adds the Cupertino Icons font to your application.
//   # Use with the CupertinoIcons class for iOS style icons.
//   cupertino_icons: ^1.0.8
//   provider: ^6.1.2

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   nike:
//     git: "https://github.com/SKaushikAK/Nike.git"

// Shape Types
enum ShapeType { point, line, rectangle, circle }

// Shape Class
class Shape {
  final ShapeType type;
  Offset? start;
  Offset? end;
  Color color;
  double strokeWidth;

  Shape({
    required this.type,
    this.start,
    this.end,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  void draw(Canvas canvas, Paint paint) {
    paint.color = color;
    paint.strokeWidth = strokeWidth;

    switch (type) {
      case ShapeType.point:
        if (start != null) {
          canvas.drawCircle(start!, strokeWidth / 2, paint);
        }
        break;
      case ShapeType.line:
        if (start != null && end != null) {
          canvas.drawLine(start!, end!, paint);
        }
        break;
      case ShapeType.rectangle:
        if (start != null && end != null) {
          Rect rect = Rect.fromPoints(start!, end!);
          canvas.drawRect(rect, paint);
        }
        break;
      case ShapeType.circle:
        if (start != null && end != null) {
          double radius = (end! - start!).distance / 2;
          canvas.drawCircle(
              Offset((start!.dx + end!.dx) / 2, (start!.dy + end!.dy) / 2),
              radius,
              paint);
        }
        break;
    }
  }

  bool contains(Offset point) {
    if (start == null || end == null) return false;
    Rect rect = Rect.fromPoints(start!, end!);
    return rect.contains(point);
  }
}

// Main Application
void main() {
  runApp(const DrawingApp());
}

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DrawingCanvas(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Drawing Canvas Widget
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Shape> shapes = [];
  ShapeType selectedShapeType = ShapeType.line;
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  Shape? currentShape;
  bool isDragging = false;
  Offset? dragStart;
  ScreenshotController screenshotController = ScreenshotController();

  void startDrawing(Offset start) {
    currentShape = Shape(
      type: selectedShapeType,
      start: start,
      end: start,
      color: selectedColor,
      strokeWidth: strokeWidth,
    );
  }

  void updateDrawing(Offset end) {
    if (currentShape != null) {
      setState(() {
        currentShape!.end = end;
      });
    }
  }

  void endDrawing() {
    if (currentShape != null) {
      setState(() {
        shapes.add(currentShape!);
        currentShape = null;
      });
    }
  }

  void deleteShape(Offset point) {
    setState(() {
      shapes.removeWhere((shape) => shape.contains(point));
    });
  }

  void exportDrawing() async {
    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/drawing.png';

    screenshotController.capture().then((Uint8List? image) async {
      if (image != null) {
        final file = File(filePath);
        await file.writeAsBytes(image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drawing saved at $filePath')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Drawing App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() {
              shapes.clear();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: exportDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          buildToolbar(),
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: GestureDetector(
                onPanStart: (details) {
                  startDrawing(details.localPosition);
                },
                onPanUpdate: (details) {
                  updateDrawing(details.localPosition);
                },
                onPanEnd: (_) {
                  endDrawing();
                },
                onDoubleTapDown: (details) {
                  deleteShape(details.localPosition);
                },
                child: CustomPaint(
                  painter: ShapePainter(shapes, currentShape),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildToolbar() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildShapeSelector(),
          buildColorPicker(),
          buildStrokeWidthSlider(),
        ],
      ),
    );
  }

  Widget buildShapeSelector() {
    return DropdownButton<ShapeType>(
      value: selectedShapeType,
      items: const [
        DropdownMenuItem(
          value: ShapeType.point,
          child: Text('Point'),
        ),
        DropdownMenuItem(
          value: ShapeType.line,
          child: Text('Line'),
        ),
        DropdownMenuItem(
          value: ShapeType.rectangle,
          child: Text('Rectangle'),
        ),
        DropdownMenuItem(
          value: ShapeType.circle,
          child: Text('Circle'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedShapeType = value;
          });
        }
      },
    );
  }

  Widget buildColorPicker() {
    return Row(
      children: [
        buildColorButton(Colors.black),
        buildColorButton(Colors.red),
        buildColorButton(Colors.green),
        buildColorButton(Colors.blue),
      ],
    );
  }

  Widget buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(color: Colors.grey, width: 2.0)
              : null,
        ),
      ),
    );
  }

  Widget buildStrokeWidthSlider() {
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          const Icon(Icons.brush),
          Expanded(
            child: Slider(
              value: strokeWidth,
              min: 1.0,
              max: 10.0,
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Shape Painter Class
class ShapePainter extends CustomPainter {
  final List<Shape> shapes;
  final Shape? currentShape;

  ShapePainter(this.shapes, this.currentShape);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var shape in shapes) {
      shape.draw(canvas, paint);
    }
    currentShape?.draw(canvas, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
