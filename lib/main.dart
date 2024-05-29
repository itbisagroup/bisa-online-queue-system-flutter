import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view/customer_view.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:sizer/sizer.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main(List<String> args) async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: ".env");
  runApp(MainApp(args));
}

class MainApp extends StatelessWidget {
  final List<String> args;
  const MainApp(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return args.isNotEmpty && args.first == "multi_window"
        ? SecondaryWindow(windowID: int.parse(args[1]))
        : const QueueApp(windowID: 0);
  }
}

class QueueApp extends StatelessWidget {
  final int windowID;
  const QueueApp({super.key, required this.windowID});

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

