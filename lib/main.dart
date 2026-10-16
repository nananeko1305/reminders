import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'app_services.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) => FlutterError.presentError(details);
    await _initFirebase();
    final services = await AppServices.create();
    runApp(AppRoot(services: services));
  }, (error, stack) {
    // Last-resort guard so an uncaught async error never silently kills the app.
    debugPrint('Uncaught error: $error\n$stack');
  });
}

/// Firebase only carries release pushes; reminders must work without it.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init failed, no release pushes: $e');
  }
}
