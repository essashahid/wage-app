import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class WageCalculator extends StatefulWidget {
  const WageCalculator({Key? key}) : super(key: key);

  @override
  _WageCalculatorState createState() => _WageCalculatorState();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wage Calculator'),
        ),
        body: const WageCalculator(),
      ),
    );
  }
}

class Worker {
  TimeOfDay startTime;
  TimeOfDay endTime;
  double regularRate;
  double regularHours; // Changed to double
  double overtimeHours; // Changed to double
  double overtimeRate;
  double totalWage;

  Worker({
    required this.startTime,
    required this.endTime,
    this.regularRate = 125.0,
    this.regularHours = 0.0, // Changed to double
    this.overtimeHours = 0.0, // Changed to double
    this.overtimeRate = 1.5,
    this.totalWage = 0.0,
  });
}

class _WageCalculatorState extends State<WageCalculator> {
  List<Worker> workers = [
    Worker(
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 18, minute: 0),
    )
  ];

  void _calculateHours(int index) {
    final worker = workers[index];
    final start = worker.startTime;
    final end = worker.endTime;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final totalMinutes = endMinutes - startMinutes;

    // Calculate regular hours (up to 8 hours) and overtime hours (any time beyond 8 hours)
    if (totalMinutes <= 480) {
      // 8 hours or less
      worker.regularHours = totalMinutes / 60.0;
      worker.overtimeHours = 0;
    } else {
      // More than 8 hours
      worker.regularHours = 8.0;
      worker.overtimeHours = (totalMinutes - 480) / 60.0;
    }

    // Calculate the total wage
    setState(() {
      worker.totalWage = (worker.regularRate * worker.regularHours) +
          (worker.regularRate * worker.overtimeRate * worker.overtimeHours);
    });
  }

  void _addWorker() {
    setState(() {
      workers.add(Worker(
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 18, minute: 0),
      ));
    });
  }

  void _removeWorker(int index) {
    setState(() {
      workers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return WorkerInputCard(
                  worker: workers[index],
                  onCalculate: () => _calculateHours(index),
                  onRemove: () => _removeWorker(index),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addWorker,
            child: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }
}

class WorkerInputCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onCalculate;
  final VoidCallback onRemove;

  const WorkerInputCard({
    Key? key,
    required this.worker,
    required this.onCalculate,
    required this.onRemove,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? worker.startTime : worker.endTime,
    );
    if (picked != null) {
      if (isStartTime) {
        worker.startTime = picked;
      } else {
        worker.endTime = picked;
      }
      onCalculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Worker Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Time'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(
                          '${worker.startTime.format(context)}'), // Display the selected start time
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Time'),
                    ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(
                          '${worker.endTime.format(context)}'), // Display the selected end time
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Regular Rate (PKR)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: worker.regularRate.toString(),
              onChanged: (value) {
                worker.regularRate = double.parse(value);
              },
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Overtime Rate Multiplier'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: worker.overtimeRate.toString(),
              onChanged: (value) {
                worker.overtimeRate = double.parse(value);
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onCalculate,
              child: const Text('Calculate Wage'),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total Wage: ${worker.totalWage.toStringAsFixed(2)} PKR',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Regular Hours: ${worker.regularHours} hrs',
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              'Overtime Hours: ${worker.overtimeHours} hrs',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
