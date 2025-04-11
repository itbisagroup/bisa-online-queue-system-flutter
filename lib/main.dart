
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  final isSubWindow = (args.isNotEmpty && args.first == "multi_window");
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (!isSubWindow) {
    runApp(const QueueApp());
    windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
      await windowManager.setTitle("BISA Online Queue System");
      await windowManager.show();
    });
  } else {
    runApp(const CustomerScreen());
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

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer Screen',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Screen'),
        ),
        body: const Center(
          child: Text('This is the customer screen'),
        ),
      ),
    );
  }
}
