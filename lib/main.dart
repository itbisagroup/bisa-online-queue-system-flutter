
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';
import 'package:pickup_queue_system/screen/customer_screen.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  final isSubWindow = (args.isNotEmpty && args.first == "multi_window");
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (!isSubWindow) {
    runApp(const QueueApp());
    windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
      await windowManager.setTitle("BISA Pickup Queue System");
      await windowManager.show();
    });
  } else {
    runApp(const CustomerWindow());
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
    return GetMaterialApp(
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        title: 'Queue App',
       
      );
  }
}

class CustomerWindow extends StatelessWidget {
  const CustomerWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer Screen',
      home: CustomerScreen(),
    );
  }
}
