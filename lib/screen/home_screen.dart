import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/home_controller.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';
import 'package:pickup_queue_system/utills/widget/custom_keyboard.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
          title: Obx(() => (controller.isLoading.value
              ? const Text("....")
              : Text(controller.currentOutlet.value?.fullName ?? "Outlet")))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentShift.value == null) {
          // Tidak ada shift terbuka
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'No Active Shift',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start a new shift to begin managing queues',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.offAllNamed(Routes.shift);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start New Shift'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final TextEditingController queueController = TextEditingController();
        final queues = controller.queueList;

        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Akhiri Shift"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await controller.closeShift();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: queueController,
                    readOnly: true, // supaya keyboard bawaan tidak muncul
                    onTap: () {
                      // Tampilkan custom keyboard saat textfield ditekan
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => CustomKeyboard(
                          onTextInput: (value) {
                            queueController.text += value;
                          },
                          onBackspace: () {
                            final text = queueController.text;
                            if (text.isNotEmpty) {
                              queueController.text =
                                  text.substring(0, text.length - 1);
                            }
                          },
                          onDone: () {
                            Navigator.pop(context); // Tutup keyboard
                          },
                        ),
                      );
                    },
                  )),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final input = queueController.text.trim();
                      if (input.isNotEmpty) {
                        await controller.addQueue(input);
                        queueController.clear();
                      }
                    },
                    child: const Text("Tambah"),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: queues.isEmpty
                  ? const Center(child: Text("Belum ada antrian"))
                  : ListView.builder(
                      itemCount: queues.length,
                      itemBuilder: (context, index) {
                        final queue = queues[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(queue.queueNumber),
                          subtitle: Text("Status: ${queue.status.description}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.campaign),
                                tooltip: "Panggil",
                                onPressed: () => controller.callQueue(queue),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                tooltip: "Layani",
                                onPressed: () => controller.serveQueue(queue),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next),
                                tooltip: "Lewati",
                                onPressed: () => controller.skipQueue(queue),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
