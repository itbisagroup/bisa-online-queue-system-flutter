import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:queue_system/models/end_shift.dart';
import 'package:queue_system/models/shift.dart';
import 'package:queue_system/repository/shift_repository.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/enum/queue_status.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';
import 'package:queue_system/widget/app_dialog.dart';

class ShiftController extends GetxController {
  var detailButton = false.obs;
  final adminController = Get.put(AdminController());
  final shiftDetailPrint = <QueueData>[].obs;
  final _apiShift = ShiftRepository();
  var selectedCard = ''.obs;
  var selectedPageNumber = 1.obs;
  var buttonNew = false.obs;
  var pageTotal = 1.obs;
  var empty = false.obs;
  var totalData = 0.obs;
  var isLoading = false.obs;
  var isLoadingDetail = false.obs;
  var isGetDetailError = false.obs;
  var buttonRefresh = false.obs;
  final allshift = <Shift>[].obs;
  var detailShift = DetailShift();

  @override
  Future<void> onInit() async {
    super.onInit();
    if (adminController.error.value == 'Forbidden') {
      buttonNew.value = true;
    }
    await shiftData(selectedPageNumber.value);
  }

  Future<void> shiftData(int pageNumber) async {
    isLoading(true);
    _apiShift.getAllShift(pageNumber).then((value) async {
      isLoading(false);
      allshift.clear();
      final List<dynamic> listQueue = value['data']['shifts'];
      if (listQueue.isEmpty) {
        empty(true);
      } else {
        allshift.addAll(listQueue.map((json) => Shift.fromJson(json)).toList());
        final firstId = allshift.first.id;

        selectedCard.value = firstId!;
        detailShiftData(firstId);
      }
      totalData.value = value['data']['pages']['totalData'];
      pageTotal.value = value['data']['pages']['totalPages'];
      buttonRefresh.value = false;
    }).onError((error, stackTrace) async {
      isLoading(false);
      buttonRefresh.value = true;
      adminController.logCase(error.toString(), 'Failed to get shift API');
    });
  }

  Future<void> newShift() async {
    isLoading(true);

    _apiShift.addNewShift().then((value) async {
      isLoading(false);
      adminController.error.value = '';
      const FlutterSecureStorage storage = FlutterSecureStorage();
      await AppDialog.showToastSuccess(
        title: 'success'.tr,
        desc: 'new_shift_desc'.tr,
        func: () async {
          DateTime now = DateTime.now();
          String dateDay = DateFormat('yyyy-MM-dd').format(now);
          final shift = await storage.read(key: 'shift_date');
          if (shift != null) {
            await storage.delete(key: 'shift_date');
          }
          await storage.write(key: 'shift_date', value: dateDay);
          await adminController.updateQueueListApi();
          await adminController.updateQueueSecondaryWindows();
          Get.back();
        },
      );
    }).onError((error, stackTrace) async {
      isLoading(false);
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_create_shift'.tr,
        func: () async {
          adminController.logCase(
              error.toString(), 'Failed to create new shift API');
        },
      );
    });
  }

  void endShiftDialog() {
    AppDialog.confirmationMsg(
      title: "end_shift".tr,
      message: "sure_end_shift".tr,
      function: () async {
        await endShift();
        final shift =
            await const FlutterSecureStorage().read(key: 'shift_date');
        if (shift != null) {
          await const FlutterSecureStorage().delete(key: 'shift_date');
        }

        Get.back();
      },
      aksiText: "Ok",
    );
  }

  void newShiftDialog() {
    AppDialog.confirmationMsg(
      title: "new_shift".tr,
      message: "sure_new_shift".tr,
      function: () async {
        await newShift();
        Get.back();
      },
      aksiText: "Ok",
    );
  }

  String formatDateTime(String dateTimeString) {
    // Parsing the input string to a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Formatting the DateTime object to the desired format
    DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    String formattedDate = formatter.format(dateTime);

    return formattedDate;
  }

  Future<void> getDetailShiftEnd(String id) async {
    try {
      final value = await _apiShift.getDetailShift(id);
      shiftDetailPrint.clear();
      final List<dynamic> listQueue = value['data']['shift']['queueData'];
      final String shiftStart = value['data']['shift']['startedAt']['date'];
      final String shiftEnd = value['data']['shift']['endedAt']['date'];
      shiftDetailPrint
          .addAll(listQueue.map((json) => QueueData.fromJson(json)).toList());

      Map<String, int> statusCount = {
        QueueStatus.calling.label: 0,
        QueueStatus.waiting.label: 0,
        QueueStatus.lastCall.label: 0,
        QueueStatus.served.label: 0,
        QueueStatus.voided.label: 0,
        QueueStatus.cancelled.label: 0,
        QueueStatus.expired.label: 0,
      };

      int totalQtyCustomer = 0;

      for (var queueData in shiftDetailPrint) {
        // Menghitung totalQty
        totalQtyCustomer += queueData.queueQty;

        // Menghitung jumlah masing-masing status
        if (statusCount.containsKey(queueData.status.label)) {
          statusCount[queueData.status.label] =
              statusCount[queueData.status.label]! + 1;
        }
      }

      await adminController.printer.detailShift(
        adminController.branch.value.fullName!,
        formatDateTime(shiftStart),
        formatDateTime(shiftEnd),
        shiftDetailPrint,
        totalQtyCustomer,
        statusCount,
      );
    } catch (error) {
      adminController.logCase(
          error.toString(), 'Failed to get Detail Shift End API');
    }
  }

  Future<void> endShift() async {
    isLoading(true);
    _apiShift.endShift().then((value) async {
      isLoading(false);

      await AppDialog.showToastSuccess(
        title: 'success'.tr,
        desc: 'success_end_shift'.tr,
        func: () async {
          Get.back();

          if (value['data']['shift']['shiftData'] != null) {
            ShiftDetails data =
                ShiftDetails.fromJson(value['data']['shift']['shiftData']);
            await adminController.printer.printEndDetailShift(
              value['data']['shift']['branch']['fullName'],
              formatDateTime(value['data']['shift']['startedAt']['date']),
              formatDateTime(value['data']['shift']['endedAt']['date']),
              data,
            );
          }
          await adminController.clearQueueSecondaryWindows();
          await adminController.updateQueueListApi();
          await const FlutterSecureStorage().delete(key: 'shift_date');
          adminController.doFullscreen();
        },
      );
    }).onError((error, stackTrace) async {
      isLoading(false);
      // Default message
      String errorMessage = 'failed_end_shift'.tr;

      // Check if error contains a specific value
      if (error.toString().contains('shift_id')) {
        errorMessage = 'failed_active_queue_end_shift'.tr;
      }
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: errorMessage,
        func: () async {
          adminController.logCase(error.toString(), 'Failed to end shift API');
        },
      );
    });
  }

  Color statusColors(int value) {
    if (value == 1) {
      return QueueStatus.waiting.color;
    } else if (value == 2) {
      return QueueStatus.calling.color;
    } else if (value == 3) {
      return QueueStatus.lastCall.color;
    } else if (value == 4) {
      return QueueStatus.served.color;
    } else if (value == 7) {
      return QueueStatus.voided.color;
    } else if (value == 8) {
      return QueueStatus.cancelled.color;
    } else if (value == 9) {
      return QueueStatus.expired.color;
    } else {
      return AppColors.black;
    }
  }

  IconData statusIcons(int value) {
    if (value == 2) {
      return Icons.volume_up;
    } else if (value == 3) {
      return Icons.volume_off;
    } else if (value == 4) {
      return Icons.check;
    } else if (value >= 5) {
      return Icons.cancel;
    } else {
      return Icons.nature_people_outlined;
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String formatUnixTimestamp(String timestamp) {
    if (timestamp == '') {
      return '-';
    }
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(timestamp) * 1000,
            isUtc: true)
        .toLocal();

    // Format the DateTime object
    DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    String formatted = formatter.format(dateTime);

    return formatted;
  }

  Future<void> detailShiftData(String id) async {
    isLoadingDetail(true);
    _apiShift.getDetailShift(id).then((value) {
      isLoadingDetail(false);
      isGetDetailError(false);
      DetailShift data = DetailShift.fromJson(value['data']['shift']);
      detailShift = data;
    }).onError(
      (error, stackTrace) async {
        isLoadingDetail(false);
        isGetDetailError(true);
        adminController.logCase(
            error.toString(), 'Failed to detail get shift API');
      },
    );
  }
}
