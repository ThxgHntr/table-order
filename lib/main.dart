import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:table_order/src/services/firebase_notification_services.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Kiểm tra nếu đang chạy trên mobile (Android/iOS) hoặc web
    if (foundation.kIsWeb) {
      // Khởi tạo Firebase cho web
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Khởi tạo Firebase cho mobile
      await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FirebaseNotificationServices().initNotification();
    FirebaseNotificationServices().requestPermission();

    final settingsController = SettingsController(SettingsService());
    await settingsController.loadSettings();

    runApp(MyApp(settingsController: settingsController));
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error during Firebase initialization: $e');
      print(stackTrace);
    }
  }
}
