import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'models/worker.dart';
import 'widgets/worker_input_card.dart';
import 'utils/calculation.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) => Text(AppLocalizations.of(context)!.appTitle),
          ),
        ),
        body: const WageCalculator(),
      ),
    );
  }
}

// Worker model moved to models/worker.dart

class _WageCalculatorState extends State<WageCalculator> {
  List<Worker> workers = [
    Worker(
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 18, minute: 0),
    )
  ];

  void _rebuild() => setState(() {});

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
                final worker = workers[index];
                return WorkerInputCard(
                  key: ValueKey(worker.id),
                  worker: worker,
                  onStartChanged: (t) {
                    worker.startTime = t;
                    _rebuild();
                  },
                  onEndChanged: (t) {
                    worker.endTime = t;
                    _rebuild();
                  },
                  onRateChanged: (r) {
                    worker.regularRate = r;
                    _rebuild();
                  },
                  onOvertimeMultiplierChanged: (m) {
                    worker.overtimeRate = m;
                    _rebuild();
                  },
                  onRemove: () => _removeWorker(index),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: _addWorker,
              child: Text(AppLocalizations.of(context)!.addWorker),
            ),
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
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Remove worker?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      onRemove();
                    }
                  },
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
                  const InputDecoration(labelText: 'Regular Rate (PKR/hr)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: worker.regularRate.toString(),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  // Enforce positive regular rate
                  worker.regularRate = parsed > 0 ? parsed : 0.01;
                  onCalculate();
                }
              },
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Overtime Multiplier (×)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: worker.overtimeRate.toString(),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  // Enforce minimum multiplier of 1.0
                  worker.overtimeRate = parsed >= 1.0 ? parsed : 1.0;
                  onCalculate();
                }
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onCalculate,
              child: const Text('Calculate Wage'),
            ),
            const SizedBox(height: 16.0),
            Builder(
              builder: (context) {
                final currencyFormatter = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
                return Text(
                  'Total Wage: ${currencyFormatter.format(worker.totalWage)}',
                  style: const TextStyle(fontSize: 20.0),
                );
              },
            ),
            const SizedBox(height: 8.0),
            Text(
              'Regular Hours: ${worker.regularHours.toStringAsFixed(2)} hrs',
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              'Overtime Hours: ${worker.overtimeHours.toStringAsFixed(2)} hrs',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
