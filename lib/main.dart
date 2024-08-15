import 'dart:async';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/data/network/base_api_services.dart';

import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view/customer_view.dart';
import 'package:sizer/sizer.dart';
import 'package:slack_logger/slack_logger.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  final isSubWindow = (args.isNotEmpty && args.first == "multi_window");
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final httpLocal = await const FlutterSecureStorage().read(key: 'base_url');
  if (httpLocal != null) {
    await BaseApiServices.initializeBaseUrl();
  }
  if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  if (!isSubWindow) {
    runApp(const QueueApp());
    windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
      await windowManager.setTitle("BISA Online Queue System");
      await windowManager.show();
    });
  } else {
    runApp(const SecondaryWindow());

    windowManager.waitUntilReadyToShow(const WindowOptions(fullScreen: true),
        () async {
      await windowManager.show();
    });
  }
}

class QueueApp extends StatelessWidget {
  const QueueApp({super.key});

  @override
  Widget build(BuildContext context) {
     SlackLogger(webhookUrl: SlackInit.url,);
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        navigatorKey: NavigationService.navigatorKey,
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
