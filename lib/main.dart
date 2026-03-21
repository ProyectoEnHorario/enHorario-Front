import 'package:enhorario/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    throw UnsupportedError(
      'Web no esta configurado para Firebase. Ejecuta flutterfire configure para generar firebase_options.dart.',
    );
  }
  await Firebase.initializeApp();
  runApp(const EnHorarioApp());
}
