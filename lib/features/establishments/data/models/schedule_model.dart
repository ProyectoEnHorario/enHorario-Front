import 'package:flutter/material.dart';

class DaySchedule {
  final int dayIndex; // 1 = Lunes, 7 = Domingo
  final String dayName;
  TimeOfDay openTime;
  TimeOfDay closeTime;
  bool isClosed;

  DaySchedule({
    required this.dayIndex,
    required this.dayName,
    this.openTime = const TimeOfDay(hour: 8, minute: 0),
    this.closeTime = const TimeOfDay(hour: 18, minute: 0),
    this.isClosed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayIndex': dayIndex,
      'openTime': '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}',
      'closeTime': '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}',
      'isClosed': isClosed,
    };
  }
}

class ScheduleModel {
  final List<DaySchedule> days;

  ScheduleModel({required this.days});

  factory ScheduleModel.defaultSchedule() {
    return ScheduleModel(days: [
      DaySchedule(dayIndex: 1, dayName: 'Lunes'),
      DaySchedule(dayIndex: 2, dayName: 'Martes'),
      DaySchedule(dayIndex: 3, dayName: 'Miércoles'),
      DaySchedule(dayIndex: 4, dayName: 'Jueves'),
      DaySchedule(dayIndex: 5, dayName: 'Viernes'),
      DaySchedule(dayIndex: 6, dayName: 'Sábado'),
      DaySchedule(dayIndex: 7, dayName: 'Domingo', isClosed: true),
    ]);
  }

  bool isCurrentlyOpen(DateTime now) {
    final day = days.firstWhere((d) => d.dayIndex == now.weekday);
    if (day.isClosed) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = day.openTime.hour * 60 + day.openTime.minute;
    final closeMinutes = day.closeTime.hour * 60 + day.closeTime.minute;

    return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'horarios': days.map((d) => d.toMap()).toList(),
    };
  }
}
