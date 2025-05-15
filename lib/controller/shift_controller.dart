import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pickup_queue_system/controller/printer_controller.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';

class ShiftController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final printer = Get.put(PrinterController());
  final RxList<Shift> shifts = <Shift>[].obs;
  final Rx<Shift?> selectedShift = Rx<Shift?>(null);
  final RxList<QueueModel> queues = <QueueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt outletId = 0.obs;
  // Pagination variables
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10; // Number of shifts per page

  // Calculate total pages
  int get totalPages => (shifts.length / itemsPerPage).ceil();

  @override
  void onInit() {
    super.onInit();
    loadOutletAndShifts();
  }

  Future<void> loadOutletAndShifts() async {
    isLoading.value = true;
    try {
      final outlet = await _databaseHelper.getFirstOutlet();
      if (outlet != null) {
        outletId.value = outlet.id!;
        await loadShifts();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectShift(Shift shift) async {
    selectedShift.value = shift;
    await loadQueuesForShift(shift.id!);
  }

  Future<void> loadQueuesForShift(int shiftId) async {
    isLoading.value = true;
    try {
      final queueMaps = await _databaseHelper.database.then((db) => db.query(
            'Queue',
            where: 'shift_id = ?',
            whereArgs: [shiftId],
            orderBy: 'createdAt ASC',
          ));

      queues
          .assignAll(queueMaps.map((map) => QueueModel.fromMap(map)).toList());
    } finally {
      isLoading.value = false;
    }
  }

  // Get paginated shifts
  List<Shift> get paginatedShifts {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return shifts.sublist(
      startIndex.clamp(0, shifts.length),
      endIndex.clamp(0, shifts.length),
    );
  }

  // Update when page changes
  void changePage(int page) {
    currentPage.value = page;
  }

  // Modify loadShifts to reset to page 1 when loading new data
  Future<void> loadShifts() async {
    isLoading.value = true;
    try {
      final shiftMaps = await _databaseHelper.database.then((db) => db.query(
            'Shift',
            where: 'outlet_id = ?',
            whereArgs: [outletId.value],
            orderBy: 'shift_date DESC',
          ));

      shifts.assignAll(shiftMaps.map((map) => Shift.fromMap(map)).toList());
      currentPage.value = 1; // Reset to first page when loading new data

      if (shifts.isNotEmpty && selectedShift.value == null) {
        selectShift(shifts.first);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> printShiftStatistics() async {
    if (selectedShift.value == null) return;

    try {
      // Get the outlet info
      final outlet = await _databaseHelper.getFirstOutlet();
      if (outlet == null) return;

      // Format dates
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final startShift =
          dateFormat.format(DateTime.parse(selectedShift.value!.shiftDate));
      final endShift =   dateFormat.format(DateTime.parse(selectedShift.value!.shiftEndDate));
  

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

      // Call the print function
      await printer.printEndDetailShift(
        outlet.fullName,
        startShift,
        endShift,
        totalQueues,
        waitingCount,
        callingCount,
        completedCount,
        unknownCount,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to print: ${e.toString()}');
    }
  }
}
