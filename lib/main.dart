import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final settingsController = SettingsController(SettingsService());
    await settingsController.loadSettings();

    runApp(MyApp(settingsController: settingsController));
  } catch (e, stackTrace) {
    print('Error during Firebase initialization: $e');
    print(stackTrace);
  }
}