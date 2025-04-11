import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/shift_controller.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';

class ShiftScreen extends GetView<ShiftController> {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Shift')),
      body: Column(
        children: [
          Obx(() {
            final activeShift = controller.shiftList
                .firstWhereOrNull((s) => s.status == ShiftStatus.opened);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(activeShift == null ? Icons.add : Icons.lock),
                label: Text(activeShift == null
                    ? 'Buat Shift Baru'
                    : 'Tutup Shift Aktif'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      activeShift == null ? Colors.green : Colors.red,
                ),
                onPressed: () async {
                  if (activeShift == null) {
                    final outlet = await DatabaseHelper().getFirstOutlet();
                    if (outlet != null) {
                      await controller.createNewShift(outlet.id!);
                    } else {
                      Get.snackbar("Error", "Outlet belum tersedia.");
                    }
                  } else {
                    await controller.closeActiveShift();
                  }
                },
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.shiftList.isEmpty) {
                return const Center(child: Text('Belum ada shift'));
              }
              return ListView.builder(
                itemCount: controller.shiftList.length,
                itemBuilder: (context, index) {
                  final shift = controller.shiftList[index];
                  return ListTile(
                    title: Text("Tanggal: ${shift.shiftDate}"),
                    trailing: Text("Status: ${shift.status.label}"),
                    leading: const Icon(Icons.date_range),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
