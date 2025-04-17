import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';

class HomeController extends GetxController {
  var filteredList = <QueueModel>[].obs;
  Rx<QueueStatus?> selectedStatus = Rx<QueueStatus?>(null);
  var searchQuery = ''.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Rx<Outlet?> outlet = Rx<Outlet?>(null);
  final Rx<Shift?> shift = Rx<Shift?>(null);
  final RxBool isLoading = false.obs;
  var isShiftOpened = false.obs;
  final RxList<QueueModel> queues = <QueueModel>[].obs;
  var queueInput = ''.obs;
  var descriptionInput = ''.obs;
  final RxInt totalQueues = 0.obs;
  final RxMap<QueueStatus, int> queueCounts = <QueueStatus, int>{
    QueueStatus.waiting: 0,
    QueueStatus.calling: 0,
    QueueStatus.completed: 0,
    QueueStatus.none: 0,
  }.obs;
  var activeField = ''.obs;
  final List<QueueStatus> statusOptions = QueueStatus.values;
  var totalFetchQueues = 0.obs;
  var selectedPageNumber = 1.obs;
  var totalData = 0.obs;
  final int limitPerPage = 20;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchOutlet();
    await checkOpenedShift();
    await fetchQueues();
  }

  void setActiveField(String field) {
    activeField.value = field;
  }

  void addCharacter(String char) {
    switch (activeField.value) {
      case 'queue':
        queueInput.value += char;
        break;
      case 'description':
        descriptionInput.value += char;
        break;
      case 'search':
        searchQuery.value += char;
        break;
    }
  }

  void backspace() {
    switch (activeField.value) {
      case 'queue':
        if (queueInput.isNotEmpty) {
          queueInput.value =
              queueInput.value.substring(0, queueInput.value.length - 1);
        }
        break;
      case 'description':
        if (descriptionInput.isNotEmpty) {
          descriptionInput.value = descriptionInput.value
              .substring(0, descriptionInput.value.length - 1);
        }
        break;
      case 'search':
        if (searchQuery.isNotEmpty) {
          searchQuery.value =
              searchQuery.value.substring(0, searchQuery.value.length - 1);
        }
        break;
    }
  }

  void done() {
    Get.snackbar(
      'Done',
      'Queue: ${queueInput.value}, Description: ${descriptionInput.value}, Search: ${searchQuery.value}',
    );
    activeField.value = '';
  }

  Future<void> openCustomerWindow() async {
    Size size = await DesktopWindow.getWindowSize();
    final x = size.width + 100;

    DesktopMultiWindow.createWindow(jsonEncode({'args1': 'Sub window'}))
        .then((value) async {
      value
        ..setFrame(Rect.fromLTWH(x, 0, 600, 600))
        ..setTitle("")
        ..show();
    });
  }

  Future<void> fetchOutlet() async {
    try {
      isLoading.value = true;
      outlet.value = await _databaseHelper.getFirstOutlet();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat outlet pertama: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkOpenedShift() async {
    isLoading.value = true;
    try {
      if (outlet.value == null) return;

      shift.value = await _databaseHelper.getActiveShift(outlet.value!.id!);
      isShiftOpened.value = shift.value != null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memeriksa shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewShift() async {
    if (outlet.value == null) {
      Get.snackbar('Error', 'Tidak ada outlet yang dipilih');
      return;
    }

    isLoading.value = true;
    try {
      final newShift = Shift(
        shiftDate: DateTime.now().toIso8601String(),
        outletId: outlet.value!.id!,
        status: ShiftStatus.opened.value,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final id = await _databaseHelper.createShift(newShift);
      shift.value = newShift.copyWith(id: id);
      isShiftOpened.value = true;
      Get.snackbar('Berhasil', 'Shift berhasil dibuka');
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Di dalam class HomeController
  Future<void> closeCurrentShift() async {
    if (shift.value == null) {
      Get.snackbar('Error', 'Tidak ada shift yang aktif');
      return;
    }

    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'Shift',
        {
          'status': ShiftStatus.closed.value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [shift.value!.id],
      );

      shift.value = null;
      queues.clear();
      isShiftOpened.value = false;
      Get.snackbar('Berhasil', 'Shift berhasil ditutup');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menutup shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewQueue() async {
    if (queueInput.value.isEmpty) {
      Get.snackbar('Error', 'Nomor antrian harus diisi');
      return;
    }
    // Validasi unik
    final isUnique = await _databaseHelper.isQueueNumberUnique(
      queueNumber: queueInput.value,
      shiftId: shift.value!.id!,
    );

    if (!isUnique) {
      Get.snackbar('Error', 'Nomor antrian sudah digunakan pada shift ini');
      return;
    }
    isLoading.value = true;
    try {
      final newQueue = QueueModel(
        queueNumber: queueInput.value,
        description: descriptionInput.value,
        status: QueueStatus.waiting.value,
        shiftId: shift.value!.id!,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _databaseHelper.createQueue(newQueue);
      await fetchQueues();
      // Reset form
      queueInput.value = '';
      descriptionInput.value = '';

      Get.snackbar('Berhasil', 'Antrian berhasil dibuat');
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat antrian: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQueues({int pageNumber = 1}) async {
    isLoading.value = true;
    selectedPageNumber.value = pageNumber;

    try {
      final offset = (pageNumber - 1) * limitPerPage;

      final result = await _databaseHelper.getQueuesByShift(
        shift.value!.id!,
        limit: limitPerPage,
        offset: offset,
        status: selectedStatus.value,
        search: searchQuery.value,
      );

      queues.assignAll(result);

      totalData.value = await _databaseHelper.getTotalQueues(shift.value!.id!);
      totalFetchQueues.value = (totalData.value / limitPerPage).ceil();

      await loadQueueStats();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat antrian: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadQueueStats() async {
    isLoading.value = true;
    try {
      totalQueues.value =
          await _databaseHelper.getTotalQueues(shift.value!.id!);
      final counts =
          await _databaseHelper.getQueueCountsByStatus(shift.value!.id!);
      queueCounts.value = counts;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat statistik antrian: $e');
    } finally {
      isLoading.value = false;
    }
  }


}
