import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(SmartCookingTimerApp());
}

class SmartCookingTimerApp extends StatelessWidget {
  const SmartCookingTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cooking Timer',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: TimerHomePage(),
    );
  }
}

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  _TimerHomePageState createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  final List<TimerTask> _tasks = [];
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  void _addTask() {
    final label = _labelController.text.trim();
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (label.isNotEmpty && minutes > 0) {
      final task = TimerTask(
        label: label,
        duration: Duration(minutes: minutes),
        onComplete: () => _showCompletionMessage(label),
      );
      setState(() {
        _tasks.add(task);
      });
      _labelController.clear();
      _minutesController.clear();
    }
  }

  void _showCompletionMessage(String taskName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ \"$taskName\" is done!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeTask(TimerTask task) {
    setState(() {
      task.dispose();
      _tasks.remove(task);
    });
  }

  @override
  void dispose() {
    for (var task in _tasks) {
      task.dispose();
    }
    _labelController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Cooking Timer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _labelController,
                    decoration: InputDecoration(labelText: 'Task Label'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Minutes'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                return TimerCard(
                  task: _tasks[index],
                  onDelete: () => _removeTask(_tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========== TIMER TASK CLASS ==========
class TimerTask {
  final String label;
  final Duration duration;
  Duration remaining;
  bool isRunning = false;
  final VoidCallback onComplete;
  Timer? _timer;

  final _controller = StreamController<Duration>.broadcast();
  Stream<Duration> get stream => _controller.stream;

  TimerTask({
    required this.label,
    required this.duration,
    required this.onComplete,
  }) : remaining = duration;

  void start() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remaining.inSeconds <= 1) {
        reset();
        _controller.add(remaining);
        onComplete();
        return;
      }
      remaining -= Duration(seconds: 1);
      _controller.add(remaining);
    });
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    remaining = duration;
    _controller.add(remaining);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

// ========== UI CARD ==========
class TimerCard extends StatefulWidget {
  final TimerTask task;
  final VoidCallback onDelete;

  const TimerCard({super.key, required this.task, required this.onDelete});

  @override
  _TimerCardState createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  @override
  void initState() {
    super.initState();
    widget.task.stream.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 -
        (widget.task.remaining.inSeconds /
            widget.task.duration.inSeconds.clamp(1, double.infinity));

    String formatDuration(Duration d) {
      return "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: progress),
          duration: Duration(milliseconds: 500),
          builder: (context, value, _) => Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
              Text(formatDuration(widget.task.remaining),
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        title: Text(widget.task.label),
        subtitle: Row(
          children: [
            IconButton(
              icon:
                  Icon(widget.task.isRunning ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  widget.task.isRunning
                      ? widget.task.pause()
                      : widget.task.start();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () {
                setState(() {
                  widget.task.reset();
                });
              },
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
