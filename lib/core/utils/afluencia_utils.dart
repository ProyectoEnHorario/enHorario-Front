import 'package:flutter/material.dart';

class AfluenciaUtils {
  static String getLabel({required bool isOpen, required int? waitMinutes}) {
    if (!isOpen) return 'Cerrado';
    if (waitMinutes == null) return 'Afluencia desconocida';
    if (waitMinutes <= 5) return 'Afluencia baja';
    if (waitMinutes <= 15) return 'Afluencia media';
    return 'Afluencia alta';
  }

  static Color getColor({required bool isOpen, required int? waitMinutes}) {
    if (!isOpen) return Colors.blueGrey;
    if (waitMinutes == null) return Colors.amber;
    if (waitMinutes <= 5) return Colors.green;
    if (waitMinutes <= 15) return Colors.orange;
    return Colors.red;
  }
}
