import 'package:flutter/material.dart';

class Worker {
  // Stable unique identifier for list keys
  final String id;

  TimeOfDay startTime;
  TimeOfDay endTime;
  double regularRate;
  double overtimeRate;

  Worker({
    String? id,
    required this.startTime,
    required this.endTime,
    this.regularRate = 125.0,
    this.overtimeRate = 1.5,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}


