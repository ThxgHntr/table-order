import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase has already been initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'table_order',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final settingsController = SettingsController(SettingsService());
    await settingsController.loadSettings();

    runApp(MyApp(settingsController: settingsController));
  } catch (e, stackTrace) {
    print('Error during Firebase initialization: $e');
    print(stackTrace);
  }
}
