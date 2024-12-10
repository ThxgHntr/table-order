import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay parseTimeOfDay(String time) {
  final format = DateFormat.jm();
  final dateTime = format.parse(time);
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}
