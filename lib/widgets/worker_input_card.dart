import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/worker.dart';
import '../utils/calculation.dart';

class WorkerInputCard extends StatefulWidget {
  final Worker worker;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onOvertimeMultiplierChanged;
  final VoidCallback onRemove;

  const WorkerInputCard({
    super.key,
    required this.worker,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onRateChanged,
    required this.onOvertimeMultiplierChanged,
    required this.onRemove,
  });

  @override
  State<WorkerInputCard> createState() => _WorkerInputCardState();
}

class _WorkerInputCardState extends State<WorkerInputCard> {
  late final TextEditingController _rateController;
  late final TextEditingController _multiplierController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rateController =
        TextEditingController(text: widget.worker.regularRate.toString());
    _multiplierController =
        TextEditingController(text: widget.worker.overtimeRate.toString());
  }

  @override
  void didUpdateWidget(covariant WorkerInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.worker.regularRate != widget.worker.regularRate) {
      _rateController.text = widget.worker.regularRate.toString();
    }
    if (oldWidget.worker.overtimeRate != widget.worker.overtimeRate) {
      _multiplierController.text = widget.worker.overtimeRate.toString();
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, bool isStartTime, TimeOfDay initial) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      if (isStartTime) {
        widget.onStartChanged(picked);
      } else {
        widget.onEndChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = calculateWage(
      start: widget.worker.startTime,
      end: widget.worker.endTime,
      regularRate: widget.worker.regularRate,
      overtimeMultiplier: widget.worker.overtimeRate,
    );
    final format = NumberFormat.simpleCurrency(name: 'PKR');

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
                Text(AppLocalizations.of(context)!.workerDetails,
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.removeWorkerTitle),
                        content:
                            Text(AppLocalizations.of(context)!.removeWorkerMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: Text(AppLocalizations.of(context)!.remove),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      widget.onRemove();
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
                    Text(AppLocalizations.of(context)!.startTime),
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, true, widget.worker.startTime),
                      child: Text(widget.worker.startTime.format(context)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.endTime),
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, false, widget.worker.endTime),
                      child: Text(widget.worker.endTime.format(context)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.regularRateLabel),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]{0,2}')),
                    ],
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return AppLocalizations.of(context)!
                            .positiveNumberError;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        widget.onRateChanged(parsed > 0 ? parsed : 0.01);
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _multiplierController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .overtimeMultiplierLabel),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]{0,2}')),
                    ],
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed < 1.0) {
                        return AppLocalizations.of(context)!
                            .minMultiplierError;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        widget.onOvertimeMultiplierChanged(
                            parsed >= 1.0 ? parsed : 1.0);
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context)!
                  .totalWage(format.format(breakdown.totalWage)),
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              AppLocalizations.of(context)!
                  .regularHours(breakdown.regularHours.toStringAsFixed(2)),
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              AppLocalizations.of(context)!
                  .overtimeHours(breakdown.overtimeHours.toStringAsFixed(2)),
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}


