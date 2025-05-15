import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pickup_queue_system/controller/shift_controller.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/widget/app_text.dart';

class ShiftScreen extends GetView<ShiftController> {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ShiftController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // Shift List Section
            Expanded(
              flex: 2,
              child: _buildShiftList(),
            ),
            const Divider(height: 1, thickness: 2),
            // Queue List Section
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Queue List
                  Expanded(
                    child: _buildQueueList(),
                  ),
                  const Divider(height: 1),
                  _buildQueueStatistics(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShiftList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Semua Shift',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.shifts.isEmpty) {
              return const Center(child: Text('Tidak ada data shift'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.paginatedShifts.length,
                    itemBuilder: (context, index) {
                      final shift = controller.paginatedShifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: controller.selectedShift.value?.id == shift.id
                            ? Colors.blue[50]
                            : null,
                        child: ListTile(
                          title: Text(
                            'Shift:  ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(shift.shiftDate).toLocal())}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: AppText(
                            text:
                                'Status: ${ShiftStatus.fromValue(shift.status).description}',
                            color: ShiftStatus.fromValue(shift.status).color,
                            fontSize: 14,
                          ),
                          trailing: Icon(
                            shift.status == ShiftStatus.opened.value
                                ? Icons.lock_open
                                : Icons.lock_outline,
                            color: shift.status == ShiftStatus.opened.value
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onTap: () => controller.selectShift(shift),
                        ),
                      );
                    },
                  ),
                ),

                // Pagination Controls
                if (controller.shifts.length > controller.itemsPerPage)
                  NumberPagination(
                    onPageChanged: (int pageNumber) {
                      controller.changePage(pageNumber);
                    },
                    totalPages: controller.totalPages,
                    currentPage: controller.currentPage.value,
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildQueueStatistics() {
    return Obx(() {
      final queues = controller.queues;
      if (queues.isEmpty) {
        return const SizedBox();
      }

      // Calculate statistics
      final totalQueues = queues.length;
      final waitingCount =
          queues.where((q) => q.status == QueueStatus.waiting.value).length;
      final callingCount =
          queues.where((q) => q.status == QueueStatus.calling.value).length;
      final completedCount =
          queues.where((q) => q.status == QueueStatus.completed.value).length;
      final unknownCount =
          queues.where((q) => q.status == QueueStatus.none.value).length;

      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatisticItem(
                'Total', totalQueues, Icons.people, AppColors.maroon),
            _buildStatisticItem(QueueStatus.waiting.description, waitingCount,
                Icons.access_time, QueueStatus.waiting.color),
            _buildStatisticItem(QueueStatus.calling.description, callingCount,
                Icons.volume_up, QueueStatus.calling.color),
            _buildStatisticItem(
                QueueStatus.completed.description,
                completedCount,
                Icons.check_circle,
                QueueStatus.completed.color),
            _buildStatisticItem(QueueStatus.none.description, unknownCount,
                Icons.help_outline, QueueStatus.none.color),
          ],
        ),
      );
    });
  }

  Widget _buildStatisticItem(
      String title, int count, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            final selectedShift = controller.selectedShift.value;
            if (selectedShift == null) {
              return const Text(
                'Pilih shift untuk melihat detail antrean',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedShift.shiftEndDate != '' &&
                          selectedShift.shiftEndDate.isNotEmpty
                      ? 'Antrean Pada Shift: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(selectedShift.shiftDate).toLocal())} - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(selectedShift.shiftEndDate).toLocal())}'
                      : 'Antrean Pada Shift: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(selectedShift.shiftDate).toLocal())}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: controller.printShiftStatistics,
                  tooltip: 'Print Statistics',
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            if (controller.queues.isEmpty) {
              return const Center(child: Text('Tidak ada data antrean'));
            }

            return ListView.builder(
              itemCount: controller.queues.length,
              itemBuilder: (context, index) {
                final queue = controller.queues[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood,
                        color: AppColors.maroon, size: 40),
                    title: AppText(
                      text: queue.queueNumber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text:
                              'Status: ${QueueStatus.fromValue(queue.status).description}',
                        ),
                        if (queue.latestCall != null)
                          Text(
                            'Terakhir Dipanggil:${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(queue.latestCall!).toLocal())}',
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
