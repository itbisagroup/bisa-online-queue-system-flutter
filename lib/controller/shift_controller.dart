import 'package:get/get.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';

class ShiftController extends GetxController {
  var shiftList = <Shift>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {

    super.onInit();
  }

 
}
