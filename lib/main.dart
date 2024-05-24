import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ofzthdnbmmyoqmclyhvk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9menRoZG5ibW15b3FtY2x5aHZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU5MzA0MjIsImV4cCI6MjAzMTUwNjQyMn0.0-Q59gfj4m8qk_OgvE6NOK4E6MNl54rSEEQa90-uyBY',
  );
  MediaKit.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: ".env");
  runApp(const QueueApp());
}

class QueueApp extends StatelessWidget {
  const QueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        title: 'Queue App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.maroon),
          useMaterial3: true,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.maroon,
            selectionColor: AppColors.maroon,
            selectionHandleColor: AppColors.maroon,
          ),
        ),
      );
    });
  }
}
