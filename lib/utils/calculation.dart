import 'package:flutter/material.dart';

class WageBreakdown {
  final double regularHours;
  final double overtimeHours;
  final double totalWage;

  const WageBreakdown({
    required this.regularHours,
    required this.overtimeHours,
    required this.totalWage,
  });
}

int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

WageBreakdown calculateWage({
  required TimeOfDay start,
  required TimeOfDay end,
  required double regularRate,
  required double overtimeMultiplier,
}) {
  final startMinutes = _toMinutes(start);
  int endMinutes = _toMinutes(end);

  if (endMinutes <= startMinutes) {
    endMinutes += 24 * 60;
  }

  final totalMinutes = (endMinutes - startMinutes).clamp(0, 24 * 60);

  double regularHours;
  double overtimeHours;
  if (totalMinutes <= 480) {
    regularHours = totalMinutes / 60.0;
    overtimeHours = 0;
  } else {
    regularHours = 8.0;
    overtimeHours = (totalMinutes - 480) / 60.0;
  }

  final totalWage = (regularRate * regularHours) +
      (regularRate * overtimeMultiplier * overtimeHours);

  return WageBreakdown(
    regularHours: regularHours,
    overtimeHours: overtimeHours,
    totalWage: totalWage,
  );
}


