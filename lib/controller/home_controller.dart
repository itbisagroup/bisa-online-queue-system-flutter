import 'package:get/get.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';

class HomeController extends GetxController {
  final Rx<Shift?> currentShift = Rx<Shift?>(null);
  final Rx<Outlet?> currentOutlet = Rx<Outlet?>(null);
  final RxBool isLoading = true.obs;
  final RxList<QueueModel> queueList = <QueueModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;

    // Get current outlet
    currentOutlet.value = await DatabaseHelper().getFirstOutlet();

    // Get current shift
    currentShift.value = await DatabaseHelper().getFirstOpenedShift();

    // Load queue if shift available
    if (currentShift.value != null) {
      await loadQueues();
    }

    isLoading.value = false;
  }

  Future<void> loadQueues() async {
    if (currentShift.value != null) {
      final queues = await DatabaseHelper().getQueuesByShiftId(currentShift.value!.id!);
      queueList.assignAll(queues); // Refresh list
    }
  }

  // Future<void> createNewShift() async {
  //   final now = DateTime.now();
  //   final newShift = Shift(
  //     shiftDate: now.toIso8601String(),
  //     outletId: currentOutlet.value!.id!, // gunakan outlet yang aktif
  //     status: ShiftStatus.opened,
  //   );
  //   await DatabaseHelper().createShift(newShift);
  //   await initializeData(); // reload outlet, shift, and queue
  // }

  Future<void> addQueue(String queueNumber) async {
    if (currentShift.value == null) return;

    final newQueue = QueueModel(
      queueNumber: queueNumber,
      shiftId: currentShift.value!.id!,
      status: QueueStatus.waiting,
      callCount: 0,
    );

    await DatabaseHelper().createQueue(newQueue);
    await loadQueues(); // reload data setelah menambah queue
  }

  Future<void> callQueue(QueueModel queue) async {
    final updatedQueue = queue.copyWith(
      status: QueueStatus.calling,
      callCount: queue.callCount + 1,
      latestCall: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper().updateQueue(updatedQueue);
    await loadQueues();
  }

  Future<void> serveQueue(QueueModel queue) async {
    final updatedQueue = queue.copyWith(status: QueueStatus.completed);
    await DatabaseHelper().updateQueue(updatedQueue);
    await loadQueues();
  }

  Future<void> skipQueue(QueueModel queue) async {
    final updatedQueue = queue.copyWith(status: QueueStatus.none);
    await DatabaseHelper().updateQueue(updatedQueue);
    await loadQueues();
  }

  Future<void> closeShift() async {
    if (currentShift.value != null) {
      final closedShift = currentShift.value!.copyWith(status: ShiftStatus.closed);
      await DatabaseHelper().updateShift(closedShift);
      currentShift.value = null;
      queueList.clear();
    }
  }
}
