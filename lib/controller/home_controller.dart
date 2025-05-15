import 'dart:async';
import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:intl/intl.dart';
import 'package:pickup_queue_system/controller/printer_controller.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/helper_note_model.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';
import 'package:pickup_queue_system/utills/audio_player.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  var filteredList = <QueueModel>[].obs;
  Rx<QueueStatus?> selectedStatus = Rx<QueueStatus?>(null);
  var searchQuery = ''.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Rx<Outlet?> outlet = Rx<Outlet?>(null);
  final Rx<Shift?> shift = Rx<Shift?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCustomerScreenActive = false.obs;
  final RxSet<int> callingQueueIds = <int>{}.obs;
  var isShiftOpened = false.obs;
  final RxList<QueueModel> queues = <QueueModel>[].obs;
  var queueInput = ''.obs;
  final cron = Cron();
  var descriptionInput = ''.obs;
  final queueUpdateController = TextEditingController();
  final descriptionUpdateController = TextEditingController();
  final newHelpperNoteController = TextEditingController();
  final RxList<HelperNote> helperNotes = <HelperNote>[].obs;
  final RxString selectedNote = ''.obs;
  final RxInt totalQueues = 0.obs;
  final AudioPlayerWav audioPlayer = AudioPlayerWav();
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
  final int limitPerPage = 15;
  final printer = Get.put(PrinterController());
  // Add these for sync functionality
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = 'Idle'.obs;
  final RxString lastSyncTime = 'Never'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchOutlet();
    await checkOpenedShift();
    if (isShiftOpened.value) {
      await fetchQueues();
      loadHelperNotes();
    }

    await _initSyncCron();
  }

  @override
  void onClose() {
    cron.close();
    super.onClose();
  }

  Future<void> _initSyncCron() async {
    final secret = await _secureStorage.read(key: 'cron_secret_key');
    if (secret != null) {
      cron.schedule(Schedule.parse('* * * * *'), () async {
        await syncUnsyncedQueues();
        print('Syncing unsynced queues...');
      });
    }
  }

  Future<void> syncUnsyncedQueues() async {
    if (isSyncing.value) return;

    isSyncing.value = true;
    syncStatus.value = 'Syncing...';

    try {
      final url = await _secureStorage.read(key: 'cron_url');
      final secretKey = await _secureStorage.read(key: 'cron_secret_key');

      if (url == null || secretKey == null) {
        throw Exception('Sync configuration incomplete');
      }

      // Get both shifts and queues that need syncing
      final shifts = await _databaseHelper.getShiftsWithUnsyncedQueues();
      final List<Map<String, dynamic>> payloadShifts = [];
      final List<int> shiftsToMarkAsSynced = [];
      final List<int> queuesToMarkAsSynced = [];

      for (final shift in shifts) {
        final queues =
            await _databaseHelper.getUnsyncedQueuesByShift(shift.id!);

        payloadShifts.add({
          'id': shift.id,
          'shift_date': shift.shiftDate,
          'status': shift.status,
          'end_at': shift.shiftEndDate,
          'queues': queues
              .map((queue) => {
                    'id': queue.id,
                    'queueNumber': queue.queueNumber,
                    if (queue.description != null)
                      'description': queue.description,
                    'status': queue.status,
                    'callCount': queue.callCount,
                  })
              .toList(),
        });

        // Collect IDs to mark as synced
        shiftsToMarkAsSynced.add(shift.id!);
        queuesToMarkAsSynced.addAll(queues.map((q) => q.id!));
      }

      if (payloadShifts.isNotEmpty) {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': secretKey,
          },
          body: jsonEncode({'shifts': payloadShifts}),
        );

        if (response.statusCode == 201) {
          // Mark both shifts and queues as synced
          await _databaseHelper.markQueuesAsSynced(queuesToMarkAsSynced);
          await _databaseHelper.markShiftsAsSynced(shiftsToMarkAsSynced);

          syncStatus.value = 'Sync successful';
          lastSyncTime.value = DateTime.now().toString();
        } else {
          throw Exception(
              'API returned ${response.statusCode} ${response.body}');
        }
      } else {
        syncStatus.value = 'Nothing to sync';
      }
    } catch (e) {
      syncStatus.value = 'Sync failed: ${e.toString()}';
      print('Sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  // Add this method to manually trigger sync
  Future<void> manualSync() async {
    await syncUnsyncedQueues();
    Get.snackbar(
      'Sync Status',
      syncStatus.value,
      snackPosition: SnackPosition.BOTTOM,
    );
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
      case 'queueUpdate':
        queueUpdateController.text += char;
        queueUpdateController.selection = TextSelection.fromPosition(
          TextPosition(offset: queueUpdateController.text.length),
        );
        break;
      case 'descriptionUpdate':
        descriptionUpdateController.text += char;
        descriptionUpdateController.selection = TextSelection.fromPosition(
          TextPosition(offset: descriptionUpdateController.text.length),
        );
        break;
      case 'newHelpperNote':
        newHelpperNoteController.text += char;
        newHelpperNoteController.selection = TextSelection.fromPosition(
          TextPosition(offset: newHelpperNoteController.text.length),
        );
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
      case 'queueUpdate':
        if (queueUpdateController.text.isNotEmpty) {
          queueUpdateController.text = queueUpdateController.text
              .substring(0, queueUpdateController.text.length - 1);
          queueUpdateController.selection = TextSelection.fromPosition(
            TextPosition(offset: queueUpdateController.text.length),
          );
        }
        break;
      case 'descriptionUpdate':
        if (descriptionUpdateController.text.isNotEmpty) {
          descriptionUpdateController.text = descriptionUpdateController.text
              .substring(0, descriptionUpdateController.text.length - 1);
          descriptionUpdateController.selection = TextSelection.fromPosition(
            TextPosition(offset: descriptionUpdateController.text.length),
          );
        }
        break;
      case 'newHelpperNote':
        if (newHelpperNoteController.text.isNotEmpty) {
          newHelpperNoteController.text = newHelpperNoteController.text
              .substring(0, newHelpperNoteController.text.length - 1);
          newHelpperNoteController.selection = TextSelection.fromPosition(
            TextPosition(offset: newHelpperNoteController.text.length),
          );
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
    isCustomerScreenActive.value = true;
    Timer(const Duration(seconds: 2), () async {
      await updateQueueDataToSecondaryWindow(null);
      await updateOutletDataToSecondaryWindow();
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
      Get.snackbar(
        'Error',
        'Tidak ada outlet yang dipilih',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    // Confirmation Dialog
    final confirm = await Get.defaultDialog(
      title: 'Buka Shift Baru',
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleText: 'Apakah Anda yakin ingin membuka shift baru?',
      textConfirm: 'Buka Shift',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      cancelTextColor: Colors.blue,
      radius: 10,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final newShift = Shift(
        shiftDate: DateTime.now().toIso8601String(),
        shiftEndDate: '',
        outletId: outlet.value!.id!,
        status: ShiftStatus.opened.value,
        isSynch: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final id = await _databaseHelper.createShift(newShift);
      shift.value = newShift.copyWith(id: id);
      isShiftOpened.value = true;

      // Optional: Success Snackbar
      Get.snackbar(
        'Berhasil',
        'Shift berhasil dibuka',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka shift: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeCurrentShift() async {
    if (shift.value == null) {
      Get.snackbar(
        'Error',
        'Tidak ada shift yang aktif',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    // Confirmation Dialog
    final confirm = await Get.defaultDialog(
      title: 'Konfirmasi',
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleText: 'Apakah Anda yakin ingin menutup shift saat ini?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      cancelTextColor: Colors.blue,
      radius: 10,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'Shift',
        {
          'shift_end_date': DateTime.now().toIso8601String(),
          'status': ShiftStatus.closed.value,
          'is_synch': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [shift.value!.id],
      );

      int waitingCount = queueCounts[QueueStatus.waiting] ?? 0;
      int callingCount = queueCounts[QueueStatus.calling] ?? 0;
      int completedCount = queueCounts[QueueStatus.completed] ?? 0;
      int unknownCount = queueCounts[QueueStatus.none] ?? 0;
      String shiftDate = DateFormat('dd/MM/yyyy HH:mm')
          .format(DateTime.parse(shift.value!.shiftDate).toLocal());
      String shiftEndDate =
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().toLocal());

      await printer.printEndDetailShift(
          outlet.value!.fullName,
          shiftDate,
          shiftEndDate,
          totalQueues.value,
          waitingCount,
          callingCount,
          completedCount,
          unknownCount);
      shift.value = null;
      queues.clear();
      isShiftOpened.value = false;
      queueCounts.value = <QueueStatus, int>{
        QueueStatus.waiting: 0,
        QueueStatus.calling: 0,
        QueueStatus.completed: 0,
        QueueStatus.none: 0,
      };
      totalQueues.value = 0;

      Get.snackbar(
        'Sukses',
        'Shift berhasil ditutup',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menutup shift: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewQueue() async {
    if (queueInput.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor antrian harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Validasi unik
    final isUnique = await _databaseHelper.isQueueNumberUnique(
      queueNumber: queueInput.value,
      shiftId: shift.value!.id!,
    );

    if (!isUnique) {
      Get.snackbar(
        'Error',
        'Nomor antrian sudah digunakan pada shift ini',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isLoading.value = true;
    try {
      final newQueue = QueueModel(
        queueNumber: queueInput.value,
        description: descriptionInput.value,
        status: QueueStatus.waiting.value,
        shiftId: shift.value!.id!,
        isSynch: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _databaseHelper.createQueue(newQueue);
      await fetchQueues();
      await updateQueueDataToSecondaryWindow(null);
      // Reset form
      queueInput.value = '';
      descriptionInput.value = '';

      // Success Snackbar
      Get.snackbar(
        'Berhasil',
        'Antrian berhasil dibuat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      );
    } catch (e) {
      // Error Snackbar
      Get.snackbar(
        'Error',
        'Gagal membuat antrian: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        shouldIconPulse: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeQueueStatus({
    required int queueId,
    required QueueStatus newStatus,
  }) async {
    // Show confirmation dialog first
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Konfirmasi Perubahan Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        content: Text(
          'Anda yakin ingin mengubah status antrian ke "${newStatus.description}"?',
          style: const TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Ya, Ubah Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    // If user cancels, return immediately
    if (confirm != true) return;

    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;

      Map<String, Object?> updateData = {
        'status': newStatus.value,
        'is_synch': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update ke database
      await db.update(
        'Queue',
        updateData,
        where: 'id = ?',
        whereArgs: [queueId],
      );

      // Refresh antrian
      await fetchQueues();

      // Feedback sukses
      Get.snackbar(
        'Berhasil',
        'Status antrian berhasil diubah ke ${newStatus.description}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        shouldIconPulse: true,
      );
    } catch (e) {
      // Feedback error
      Get.snackbar(
        'Gagal Mengubah Status',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> callQueue(
      {required int queueId, required String queueNumber}) async {
    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;

      // Get current queue data
      final current = await db.query(
        'Queue',
        columns: ['call_count'],
        where: 'id = ?',
        whereArgs: [queueId],
      );

      final currentCallCount =
          current.isNotEmpty ? (current.first['call_count'] as int? ?? 0) : 0;

      // Update queue status to "calling"
      await db.update(
        'Queue',
        {
          'status': QueueStatus.calling.value,
          'latest_call': DateTime.now().toIso8601String(),
          'call_count': currentCallCount + 1,
          'is_synch': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [queueId],
      );

      // Refresh queues list
      await fetchQueues();

      await updateQueueDataToSecondaryWindow(queueNumber);
      await speak(queueNumber);
      // Success feedback with sound effect
      Get.snackbar(
        'Berhasil',
        'Antrian berhasil dipanggil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.volume_up, color: Colors.white),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      );
    } catch (e) {
      // Error feedback
      Get.snackbar(
        'Gagal Memanggil Antrian',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> speak(String queueNumber) async {
    final List<String> playlist = [];

    // first sound calling
    playlist.add('assets/sounds/attention.wav');
    playlist.add('assets/sounds/first.wav');

    // loop through each character in the queue number
    for (var char in queueNumber.toUpperCase().split('')) {
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        playlist.add('assets/sounds/alphabet/$char.wav');
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        playlist.add('assets/sounds/number/$char.wav');
      }
    }

    // last sound calling
    playlist.add('assets/sounds/last.wav');

    await audioPlayer.playPlaylist(playlist);
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

  Future<void> updateQueueDetails({
    required int queueId,
    required String newQueueNumber,
    required String newDescription,
  }) async {
    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;

      // Check if new queue number is unique (excluding current queue)
      final isUnique = await db.rawQuery('''
      SELECT COUNT(*) as count FROM Queue 
      WHERE queue_number = ? 
      AND shift_id = ? 
      AND id != ?
    ''', [newQueueNumber, shift.value!.id, queueId]);

      if ((isUnique.first['count'] as int) > 0) {
        throw Exception('Nomor antrian sudah digunakan pada shift ini');
      }

      // Update queue in database
      await db.update(
        'Queue',
        {
          'queue_number': newQueueNumber,
          'description': newDescription,
          'is_synch': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [queueId],
      );

      // Refresh queues list
      await fetchQueues();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQueueDataToSecondaryWindow(
      String? currentCallingQueue) async {
    if (!isCustomerScreenActive.value) return;
    List<String?> listCallingQueue = queues
        .where((queue) => queue.status == QueueStatus.calling.value)
        .map((queue) => queue.queueNumber)
        .toList();
    String queueCalling = jsonEncode(listCallingQueue);

    List<String> listWaitingQueue = queues
        .where((queue) => queue.status == QueueStatus.waiting.value)
        .map((queue) => queue.queueNumber)
        .toList();
    String queueWaiting = jsonEncode(listWaitingQueue);

    if (currentCallingQueue != null) {
      DesktopMultiWindow.invokeMethod(
          1, "currentCallingQueue", currentCallingQueue);
    }

    DesktopMultiWindow.invokeMethod(1, "queueCalling", queueCalling);
    DesktopMultiWindow.invokeMethod(1, "queueWaiting", queueWaiting);
  }

  Future<void> updateOutletDataToSecondaryWindow() async {
    if (!isCustomerScreenActive.value) return;

    DesktopMultiWindow.invokeMethod(
        1, "outletFullName", outlet.value!.fullName);
    DesktopMultiWindow.invokeMethod(1, "outletLogo", outlet.value!.logo);
  }

  Future<void> loadHelperNotes() async {
    final notes = await DatabaseHelper().getAllHelperNotes();
    helperNotes.assignAll(notes);
  }

  void selectNote(String note) {
    final currentText = descriptionUpdateController.text;
    descriptionUpdateController.text = '$currentText $note'.trim();
    selectedNote.value = note;
  }

  Future<void> addNewNote(String note) async {
    if (note.isEmpty) return;

    final newNote = HelperNote(name: note);
    await DatabaseHelper().insertHelperNote(newNote);
    await loadHelperNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper().deleteHelperNote(id);
    await loadHelperNotes();
  }
}
