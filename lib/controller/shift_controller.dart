import 'package:get/get.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';

class ShiftController extends GetxController {
  var shiftList = <Shift>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchShifts();
    super.onInit();
  }

  Future<void> fetchShifts() async {
    isLoading.value = true;
    final shifts = await DatabaseHelper().getAllShifts();
    shiftList.assignAll(shifts);
    isLoading.value = false;
  }

  Future<void> closeActiveShift() async {
    final active =
        shiftList.firstWhereOrNull((s) => s.status == ShiftStatus.opened);
    if (active != null) {
      final updatedShift = active.copyWith(status: ShiftStatus.closed);
      await DatabaseHelper().updateShift(updatedShift);
      await fetchShifts(); // Refresh
    }
  }

  Future<void> createNewShift(int outletId) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final newShift = Shift(
      shiftDate: today,
      outletId: outletId,
      status: ShiftStatus.opened,
    );
    await DatabaseHelper().createShift(newShift);
    await fetchShifts(); // Refresh
  }
}
