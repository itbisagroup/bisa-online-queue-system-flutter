import 'dart:async';
import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cron/cron.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:queue_system/models/ads.dart';
import 'package:queue_system/models/branch.dart';
import 'package:queue_system/models/pax.dart';
import 'package:queue_system/repository/branch_repository.dart';
import 'package:queue_system/repository/sync_repository.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/view_models/controller/printer_controller.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/models/queue_item.dart';
import 'package:queue_system/utils/audio_player.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:queue_system/widget/app_text.dart';
import '../../repository/queue_repository.dart';

class AdminController extends GetxController {
  final _apiQueue = QueueRepository();
  final _apiBranch = BranchRepository();
  final LogApp _logApp = LogApp();
  final apiSync = SyncRepository();
  final _apiSync = SyncRepository();
  final storage = const FlutterSecureStorage();
  final ads = <Ads>[].obs;
  final branch = Branch().obs;

  final paxWithQueue = <PaxWithQueue>[].obs;
  final pax = <Pax>[].obs;
  final withhold = <Withhold>[].obs;
  final allQueue = <QueueList>[];
  final Map<String, Map<String, dynamic>> buttonCall = {};
  final Map<String, RxBool> buttonAdd = {};
  final Map<String, RxBool> updateStatus = {};
  final AudioPlayerWav audioPlayer = AudioPlayerWav();
  RxString error = ''.obs;
  final rxRequestStatus = Status.LOADING.obs;
  final TextEditingController textEditingController = TextEditingController();
  var isLoading = false.obs;
  var withHoldVisible = true.obs;
  var statusSynch = ''.obs;
  var lastSynch = ''.obs;
  var statusCron = true.obs;
  var lastCrone = ''.obs;
  var buttonRefreshDetail = false.obs;

  var statusRealtime = false.obs;
  var color = Colors.black.obs;
  var availableLanguages = <String>[].obs;
  var selectedPageNumber = 1.obs;
  var statusValueFilter = 0.obs;
  var pageTotal = 1.obs;
  var currentDay = 0.obs;
  Rx<DateTime> currentTime = DateTime.now().obs;
  var totalData = 0.obs;
  var loading = false.obs;

  final List<int> secondaryWindowIDs = [];
  final printer = Get.put(PrinterController());
  late Timer timerDialog;

  final _isDialogOpen = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    await queueListApi();
    final title = await storage.read(key: 'env_title');
    final label = await storage.read(key: 'env_label');
    final videoPath = await storage.read(key: 'env_path');
    if (title == null || label == null) {
      await storage.write(key: 'env_title', value: 'Nomor Antrian');
      await storage.write(
          key: 'env_label', value: 'Silahkan Konfirmasi ke Greeter');
    }
    if (videoPath == null) {
      await storage.write(
          key: 'env_path',
          value: 'd:/laragon/www/bisa-online-queue/public/assets/ads/');
    }

    runCronTask();
    timerDialogEndShift();
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (_isDialogOpen.value) {
        return false;
      }
      _isDialogOpen.value = true;
      final shouldClose = await showDialog<bool>(
        context: NavigationService.navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: const AppText(
              text: 'Do you really want to quit?',
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  _isDialogOpen.value = false;

                  if (secondaryWindowIDs.isNotEmpty) {
                    await closeSecondaryWindow();
                  }
                  Navigator.of(context).pop(true);
                },
                child: const AppText(
                  text: 'Yes',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _isDialogOpen.value = false;
                  Navigator.of(context).pop(false);
                },
                child: const AppText(
                  text: 'No',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        },
      );
      _isDialogOpen.value = false;
      return shouldClose ?? false;
    });
  }

  timerDialogEndShift() async {
    final String? shiftDate = await storage.read(key: 'shift_date');
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime.value);

    if (shiftDate != formattedDate && shiftDate != null) {
      Future.delayed(const Duration(seconds: 5), () {
        AppDialog.showToastShiftEnd(
            title: "Info",
            desc:
                "Don't forget to end the shift. Would you like to end it now?",
            ok: () {
              Get.toNamed(Routes.shift);
            });
      });
    }
  }

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setError(String value) => error.value = value;

  void runCronTask() {
    var cron = Cron();
    bool? previousStatus;
    int errorCount = 0;

    cron.schedule(Schedule.parse('* * * * *'), () async {
      try {
        await apiSync.sendData();
        statusCron.value = true;
        lastCrone.value = DateFormat('hh:mm').format(DateTime.now());

        if (previousStatus != true) {
          _logApp.sendSlackLog(branch.value.fullName!, "cron running");
        }

        previousStatus = true;
        errorCount = 0;
      } catch (error) {
        errorCount++;
        statusCron.value = false;
        lastCrone.value = DateFormat('hh:mm').format(DateTime.now());

        if (previousStatus != false) {
          await _logApp.writeLog("Failed cron ${error.toString()}");
          _logApp.sendSlackLog(
              branch.value.fullName!, "Failed cron ${error.toString()}");
        }
        if (errorCount >= 5) {
          await apiSync.flushParameter().then((value) {
            _logApp.sendSlackLog(branch.value.fullName!,
                "Flush parameter cron ${value.toString()}");
          }).onError((error, stackTrace) async {
            await _logApp
                .writeLog("Failed flush parameter cron ${error.toString()}");
            _logApp.sendSlackLog(branch.value.fullName!,
                "Failed flush parameter cron ${error.toString()}");
          });
          errorCount = 0;
        }

        previousStatus = false;
      }
    });
  }

  Future<void> openSecondaryWindow() async {
    Size size = await DesktopWindow.getWindowSize();
    final x = size.width + 100;

    DesktopMultiWindow.createWindow(jsonEncode({'args1': 'Sub window'}))
        .then((value) async {
      secondaryWindowIDs.add(value.windowId);
      value
        ..setFrame(Rect.fromLTWH(x, 0, 600, 600))
        ..setTitle("")
        ..show();
    });
    Timer(const Duration(seconds: 2), () {
      updateQueueSecondaryWindows();
      updateDataSecondaryWindows();
      doFullscreen();
    });
  }

  Future<void> closeSecondaryWindow() async {
    for (var element in secondaryWindowIDs) {
      await WindowController.fromWindowId(element).close();
    }
    secondaryWindowIDs.clear();
  }

  List<String?> getAllQueueNumbers() {
    List<String?> notation =
        paxWithQueue.map((paxWithQueue) => paxWithQueue.pax?.notation).toList();

    List<String?> queue = paxWithQueue
        .map((paxWithQueue) => paxWithQueue.queue?.queueNumber)
        .toList();

    for (int i = 0; i < queue.length; i++) {
      if (queue[i] == "0000") {
        queue[i] = "${notation[i]}000";
      }
    }
    return queue;
  }

  List<String?> getAllNextQueueNumbers() {
    List<String?> notation =
        paxWithQueue.map((paxWithQueue) => paxWithQueue.pax?.notation).toList();

    List<String?> queue = paxWithQueue
        .map((paxWithQueue) => paxWithQueue.queue?.nextQueue)
        .toList();

    for (int i = 0; i < queue.length; i++) {
      if (queue[i] == "0000") {
        queue[i] = "${notation[i]}000";
      }
    }

    return queue;
  }

  List<String?> getAllAdsNumbers() {
    return ads.map((ad) => ad.content).toList();
  }

  Future<void> updateQueueSecondaryWindows() async {
    // Get all queue numbers
    List<String?> queueNumbers = getAllQueueNumbers();
    List<String?> queueNextNumbers = getAllNextQueueNumbers();
    String jsonDataList = jsonEncode(queueNumbers);
    String nextQueue = jsonEncode(queueNextNumbers);

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "updateQueue", jsonDataList);
      DesktopMultiWindow.invokeMethod(windowID, "nextQueue", nextQueue);
    }
  }

  Future<void> updateCallText() async {
    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(
          windowID, "updateCallText", 'jsonDataList');
    }
  }

  Future<void> updatePathVideo() async {
    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(
          windowID, "updatePathVideo", 'jsonDataList');
    }
  }

  Future<void> doFullscreen() async {
    String doFullscreen = jsonEncode(branch.value.playAds);

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "doFullscreen", doFullscreen);
    }
  }

  void sync() async {
    statusSynch.value = 'Syncing...';
    lastSynch.value = '';
    await branchData();
    await updateQueueListApi();

    if (secondaryWindowIDs.isNotEmpty) {
      await updateDataSecondaryWindows();
      await updateQueueSecondaryWindows();
    }
    _apiSync.getData().then((value) async {
      statusSynch.value = 'Synced';
      lastSynch.value = DateFormat('dd/MM/yyyy hh:mm').format(DateTime.now());
    }).onError((error, stackTrace) async {
      await _logApp.writeLog(" Failed syncing ${error.toString()}");
      statusSynch.value = 'Failed[$error]';
      lastSynch.value = DateFormat('dd/MM/yyyy hh:mm').format(DateTime.now());
    });
  }

  Future<void> callSecondaryWindows(String number, int queueCount) async {
    // Get all queue numbers
    String numberTextView = jsonEncode(number);
    String callCount = jsonEncode(queueCount);
    List<String?> queueNextNumbers = getAllNextQueueNumbers();
    String nextQueue = jsonEncode(queueNextNumbers);

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "callCount", callCount);
      DesktopMultiWindow.invokeMethod(windowID, "callQueue", numberTextView);
      DesktopMultiWindow.invokeMethod(windowID, "nextQueue", nextQueue);
    }
  }

  Future<void> updateNextQueue() async {
    List<String?> queueNextNumbers = getAllNextQueueNumbers();
    String nextQueue = jsonEncode(queueNextNumbers);

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "nextQueue", nextQueue);
    }
  }

  Future<void> updateDataSecondaryWindows() async {
    // Get all queue numbers
    List<String?> ads = getAllAdsNumbers();
    String jsonAdsList = jsonEncode(ads);
    String fullName = jsonEncode(branch.value.fullName);
    String logo = jsonEncode(branch.value.brand!.logo);
    String playAds = jsonEncode(branch.value.playAds);
    String maxCall = jsonEncode(branch.value.callCount);
    String callRepeat = jsonEncode(branch.value.callRepeat);
    String brand = jsonEncode(branch.value.brand!.fullName!);
    String address = jsonEncode(branch.value.address);
    String city = jsonEncode(branch.value.city);
    String province = jsonEncode(branch.value.province);
    for (var windowID in secondaryWindowIDs) {
      if (ads.isNotEmpty) {
        DesktopMultiWindow.invokeMethod(windowID, "updateAds", jsonAdsList);
      }

      DesktopMultiWindow.invokeMethod(windowID, "updateFullname", fullName);
      DesktopMultiWindow.invokeMethod(windowID, "callRepeat", callRepeat);
      DesktopMultiWindow.invokeMethod(windowID, "updateLogo", logo);
      DesktopMultiWindow.invokeMethod(windowID, "updatePlayAds", playAds);
      DesktopMultiWindow.invokeMethod(windowID, "updateBrand", brand);
      DesktopMultiWindow.invokeMethod(windowID, "maxCallQueue", maxCall);
      DesktopMultiWindow.invokeMethod(windowID, "address", address);
      DesktopMultiWindow.invokeMethod(windowID, "city", city);
      DesktopMultiWindow.invokeMethod(windowID, "province", province);
    }
  }

  bool isButtonDisabled(String id) {
    if (!buttonCall.containsKey(id)) {
      buttonCall[id] = {
        'isDisabled': false.obs,
        'controllerCountDown': CountDownController()
      };
    }
    return buttonCall[id]!['isDisabled'].value;
  }

  void disableButton(String id) {
    if (!buttonCall.containsKey(id)) {
      buttonCall[id] = {
        'isDisabled': false.obs,
        'controllerCountDown': CountDownController()
      };
    }
    buttonCall[id]!['isDisabled'].value = true;
  }

  void enableButton(String id) {
    if (buttonCall.containsKey(id)) {
      buttonCall[id]!['isDisabled'].value = false;
    }
  }

  CountDownController getController(String id) {
    if (!buttonCall.containsKey(id)) {
      buttonCall[id] = {
        'isDisabled': false.obs,
        'controllerCountDown': CountDownController()
      };
    }
    return buttonCall[id]!['controllerCountDown'];
  }

  bool isButtonAddDisabled(String id) {
    if (!buttonAdd.containsKey(id)) {
      buttonAdd[id] = false.obs;
    }
    return buttonAdd[id]!.value;
  }

  void disableAddButton(String id) {
    if (!buttonAdd.containsKey(id)) {
      buttonAdd[id] = false.obs;
    }
    buttonAdd[id]!.value = true;
  }

  void enableAddButton(String id) {
    if (buttonAdd.containsKey(id)) {
      buttonAdd[id]!.value = false;
    }
  }

  bool isupdateStatusDisabled(String id) {
    if (!updateStatus.containsKey(id)) {
      updateStatus[id] = false.obs;
    }
    return updateStatus[id]!.value;
  }

  Future<void> disableUpdateStatus(String id) async {
    if (!updateStatus.containsKey(id)) {
      updateStatus[id] = false.obs;
    }
    updateStatus[id]!.value = true;
  }

  Future<void> enableUpdateStatus(String id) async {
    if (updateStatus.containsKey(id)) {
      updateStatus[id]!.value = false;
    }
  }

  Future<void> branchData() async {
    _apiBranch.getBranch().then((value) async {
      branch.refresh();
      ads.clear();
      pax.clear();
      branch.value = Branch.fromJson(value);

      final List<dynamic> listPax = value['data']['pax'];
      pax.addAll(listPax.map((json) => Pax.fromJson(json)).toList());

      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());
    }).onError((error, stackTrace) async {
      setError(error.toString());
      await _logApp.writeLog(" Failed get branch API ${error.toString()}");
      setRxRequestStatus(Status.ERROR);
    });
  }

  Future<void> queueListApi() async {
    await branchData();
    _apiQueue.getDetailQueue().then((value) async {
      if (pax.isNotEmpty) {
        paxWithQueue.addAll(pax.map((json) {
          // Mencari current queue untuk pax tertentu
          final queue = Queue.fromJson(value['data']['queue']['current']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));
          final withhold = Withhold.fromJson(value['data']['queue']['withhold']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));

          return PaxWithQueue(pax: json, queue: queue, withhold: withhold);
        }).toList());
      }

      withhold.addAll(paxWithQueue
          .map((paxWithQueue) => paxWithQueue.withhold!)
          .where((item) => item.queueNumber != "0000")
          .toList());

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      await _logApp.writeLog(" Failed get queue view API ${error.toString()}");
      setRxRequestStatus(Status.ERROR);
    });
  }

  Future<void> updateQueueListApi() async {
    AppDialog.showDialogLoading();
    _apiQueue.getDetailQueue().then((value) {
      paxWithQueue.clear();
      withhold.clear();

      if (pax.isNotEmpty) {
        paxWithQueue.addAll(pax.map((json) {
          final queue = Queue.fromJson(value['data']['queue']['current']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));
          final withhold = Withhold.fromJson(value['data']['queue']['withhold']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));

          return PaxWithQueue(pax: json, queue: queue, withhold: withhold);
        }).toList());
      }

      withhold.addAll(paxWithQueue
          .map((paxWithQueue) => paxWithQueue.withhold!)
          .where((item) => item.queueNumber != "0000")
          .toList());

      Get.back();
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setRxRequestStatus(Status.ERROR);
      setError(error.toString());
      Get.back();
      await _logApp.writeLog(" Failed get queue view API ${error.toString()}");
    });
  }

  Future<void> apiQueueDetailList() async {
    isLoading(true);
    _apiQueue
        .getAllQueue(
            selectedPageNumber.value, statusValueFilter.value.toString())
        .then((value) {
      isLoading(false);
      allQueue.clear();
      final List<dynamic> listQueue = value['data']['queues'];

      allQueue
          .addAll(listQueue.map((json) => QueueList.fromJson(json)).toList());
      totalData.value = value['data']['pages']['totalData'];
      pageTotal.value = value['data']['pages']['totalPages'];
      buttonRefreshDetail.value = false;
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      isLoading(false);
      if (error.toString() == 'Request Time Out') {
        buttonRefreshDetail.value = true;
        allQueue.clear();
      }
      setError(error.toString());
      await _logApp.writeLog(" Failed get queue index API ${error.toString()}");
    });
  }

  void apiQueueDetailSearch(String search) {
    isLoading(true);
    _apiQueue.searchAllQueue(search).then((value) {
      isLoading(false);
      allQueue.clear();
      final List<dynamic> listQueue = value['data']['queues'];
      allQueue
          .addAll(listQueue.map((json) => QueueList.fromJson(json)).toList());
      totalData.value = value['data']['pages']['totalData'];
      pageTotal.value = value['data']['pages']['totalPages'];
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      isLoading(false);
      setError(error.toString());
      await _logApp
          .writeLog(" Failed search queue index API ${error.toString()}");
    });
  }

  Color statusColors(int value) {
    if (value == 2) {
      return const Color.fromARGB(255, 2, 85, 4);
    } else if (value == 3) {
      return Colors.orange;
    } else if (value == 4) {
      return AppColors.confirm;
    } else if (value >= 5) {
      return AppColors.red;
    } else {
      return AppColors.blackCalm;
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
    if (dateString == '') {
      return '';
    }
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy hh:mm').format(dateTime);
  }

  Future<void> newQueue(String paxId, String paxQuantity) async {
    disableAddButton(paxId);

    _apiQueue.addNewQueue(paxId, paxQuantity).then((value) async {
      final queueId = value['data']['queue']['queueCode'];
      String queueNumber = value['data']['queue']['queueNumber'];
      doFullscreen();

      await AppDialog.showToastSuccess(
        title: queueNumber,
        desc: 'Queue $queueNumber created succesfuly',
        func: () async {
          await updateQueueListApi();
          await updateNextQueue();
          await printQueue(queueId);
          enableAddButton(paxId);
        },
      );

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      enableAddButton(paxId);
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable to create queue. Please try again',
        func: () async {
          await _logApp
              .writeLog(" Failed create queue API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed create queue API ${error.toString()}");
        },
      );
    });
  }

  Future<void> printQueue(
    String queueId,
  ) async {
    _apiQueue.printQueue(queueId).then((value) async {
      final number = value['data']['queue']['queueNumber'];
      final cancelCode = value['data']['queue']['cancelCode'];
      final qrData = value['data']['queue']['queueCode'];
      await printer.printQueue(
          branch.value.fullName!, qrData, number, cancelCode);

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable to print queue. Please try again',
        func: () async {
          Get.back();
          await _logApp.writeLog(" Failed print queue API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed print queue API ${error.toString()}");
        },
      );
    });
  }

  Future<void> servedQueue(
    String queueId,
    String paxId,
  ) async {
    disableUpdateStatus(paxId);
    _apiQueue.addStatusQueue(queueId, '4').then((value) async {
      final number = value['data']['queue']['queueNumber'];
      doFullscreen();
      await AppDialog.showToastSuccess(
        title: number,
        desc: 'Status successfully updated to served',
        func: () async {
          enableButton(paxId);
          await enableUpdateStatus(paxId);
          await updateQueueListApi();
        },
      );

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      enableUpdateStatus(paxId);
      AppDialog.showToastError(
          title: 'Failed!',
          desc: 'Unable update status served!. Please try again',
          func: () async {
            await _logApp.writeLog(
                " Failed to update status served queue view API ${error.toString()}");
            await _logApp.sendSlackLog(branch.value.fullName!,
                "Failed to update status served queue ${error.toString()}");
          });
    });
  }

  Future<void> voidQueue(
    String queueId,
    String paxId,
  ) async {
    disableUpdateStatus(paxId);
    _apiQueue.addStatusQueue(queueId, '7').then((value) async {
      final number = value['data']['queue']['queueNumber'];
      if (kDebugMode) {
        print('void Queue Number: $number');
      }
      doFullscreen();
      await AppDialog.showToastSuccess(
        title: number,
        desc: 'Status successfully updated to void',
        func: () async {
          await updateQueueListApi();
        },
      );

      enableButton(paxId);
      await enableUpdateStatus(paxId);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      enableUpdateStatus(paxId);
      setError(error.toString());
      AppDialog.showToastError(
          title: 'Failed!',
          desc: 'Unable update status void!. Please try again',
          func: () async {
            await _logApp.writeLog(
                " Failed to update status void queue view API ${error.toString()}");
            await _logApp.sendSlackLog(branch.value.fullName!,
                "Failed to update status void queue view API ${error.toString()}");
          });
    });
  }

  Future<void> servedQueueWithhold(
    String queueId,
  ) async {
    AppDialog.showDialogLoading();
    _apiQueue.addStatusQueue(queueId, '4').then((value) async {
      Get.back();
      doFullscreen();
      final number = value['data']['queue']['queueNumber'];
      await AppDialog.showToastSuccess(
        title: number,
        desc: 'Status successfully updated to served',
        func: () async {
          await updateQueueListApi();
        },
      );
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable update status served!. Please try again',
        func: () async {
          await _logApp.writeLog(
              " Failed to update status served queue Withold API ${error.toString()}");
        },
      );
    });
  }

  Future<void> voidQueueWithhold(
    String queueId,
  ) async {
    AppDialog.showDialogLoading();
    _apiQueue.addStatusQueue(queueId, '7').then((value) async {
      Get.back();
      doFullscreen();
      final number = value['data']['queue']['queueNumber'];
      if (kDebugMode) {
        print('void Queue Number: $number');
      }
      await AppDialog.showToastSuccess(
          title: number,
          desc: 'Status successfully updated to void',
          func: () async {
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      Get.back();
      setError(error.toString());
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable update status void!. Please try again',
        func: () async {
          await _logApp.writeLog(
              " Failed to update status void queue withhold API ${error.toString()}");
        },
      );
    });
  }

  Future<void> updateQtyQueue(
    String queueId,
    String qty,
  ) async {
    AppDialog.showDialogLoading();
    _apiQueue.updateQty(queueId, qty).then((value) async {
      Get.back();
      final number = value['data']['queue']['queueNumber'];
      await AppDialog.showToastSuccess(
          title: number,
          desc: 'Quantity successfully updated to $qty',
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable update quantity!. Please try again',
        func: () async {
          await _logApp
              .writeLog(" Failed to update qty queue API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed to update qty queue API ${error.toString()}");
        },
      );
    });
  }

  Future<void> servedQueueDetail(
    String queueId,
  ) async {
    AppDialog.showDialogLoading();
    _apiQueue.addStatusQueue(queueId, '4').then((value) async {
      Get.back();
      doFullscreen();
      final number = value['data']['queue']['queueNumber'];
      await AppDialog.showToastSuccess(
          title: number,
          desc: 'Status successfully updated to served',
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable update status served!. Please try again',
        func: () async {
          await _logApp.writeLog(
              " Failed to update status served queue detail API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed to update status served queue detail API ${error.toString()}");
        },
      );
    });
  }

  Future<void> voidQueueDetail(
    String queueId,
  ) async {
    AppDialog.showDialogLoading();
    _apiQueue.addStatusQueue(queueId, '7').then((value) async {
      Get.back();
      doFullscreen();
      final number = value['data']['queue']['queueNumber'];
      if (kDebugMode) {
        print('void Queue Number: $number');
      }
      await AppDialog.showToastSuccess(
          title: number,
          desc: 'Status successfully updated to void',
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      Get.back();
      setError(error.toString());
      AppDialog.showToastError(
        title: 'Failed!',
        desc: 'Unable update status void!. Please try again',
        func: () async {
          await _logApp.writeLog(
              " Failed to update status void queue detail API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed to update status void queue detail API  ${error.toString()}");
        },
      );
    });
  }

  Future<void> callQueue(
    String paxId,
    int queueCount,
  ) async {
    disableButton(paxId);
    _apiQueue.callQueue(paxId).then((value) async {
      getController(paxId).start();
      final queueNumberCall = value['data']['queue']['queueNumber'];
      final queuecallCount = value['data']['queue']['callCount'];
      final number = separateNumbers(queueNumberCall);
      final letters = separateLetters(queueNumberCall);

      if (queuecallCount != branch.value.callCount) {
        Timer(Duration(seconds: branch.value.callDelay!), () {
          enableButton(paxId);
        });
      } else {
        getController(paxId).reset();
        enableButton(paxId);
      }

      if (secondaryWindowIDs.isEmpty) {
        AppDialog.showToastSuccess(
            title: queueNumberCall,
            desc: 'Queue $queueNumberCall called succesfuly',
            func: () async {
              await updateQueueListApi();
            });
        await callSpeakFunction(letters, number, queueCount);

        setRxRequestStatus(Status.COMPLETED);
      } else {
        await callSecondaryWindows(queueNumberCall, queueCount);
        doFullscreen();
        await AppDialog.showToastSuccess(
          title: queueNumberCall,
          desc: 'Queue $queueNumberCall called succesfuly',
          func: () async {
            await updateQueueListApi();
          },
        );
        setRxRequestStatus(Status.COMPLETED);
      }
    }).onError((error, stackTrace) {
      enableButton(paxId);
      setError(error.toString());
      AppDialog.showToastError(
        title: 'Failed!',
        desc:
            'Unable to call or maybe the queue is already canceled  \n[$error]',
        func: () async {
          await updateQueueListApi();

          await _logApp
              .writeLog(" Failed to call queue detail API ${error.toString()}");
          await _logApp.sendSlackLog(branch.value.fullName!,
              "Failed to call queue detail API ${error.toString()}");
        },
      );
    });
  }

  Future<void> callSpeakFunction(
      String letters, String number, int queueCount) async {
    int repeatCount = branch.value.callRepeat! + 1;
    for (int i = 1; i <= repeatCount; i++) {
      await speak(letters, number, queueCount);
      await Future.delayed(const Duration(seconds: 13));
    }
  }

  Future<void> speak(String letters, String number, int queueCount) async {
    int digitCount = getDigitCount(number);
    if (digitCount < 3) {
      if (queueCount == (branch.value.callCount! - 1)) {
        await audioPlayer.playPlaylist([
          'assets/sounds/attention.wav',
          'assets/sounds/lastcall.wav',
          'assets/sounds/alphabet/$letters.wav',
          'assets/sounds/number/$number.wav',
          'assets/sounds/already.wav',
        ]);
      } else {
        await audioPlayer.playPlaylist([
          'assets/sounds/attention.wav',
          'assets/sounds/calling.wav',
          'assets/sounds/alphabet/$letters.wav',
          'assets/sounds/number/$number.wav',
          'assets/sounds/already.wav',
        ]);
      }
    } else if (digitCount == 3) {
      int firstDigit = getFirstDigit(int.parse(number));
      int secondDigit = getSecondDigit(int.parse(number));
      int thirdDigit = getThirdDigit(int.parse(number));
      if (queueCount == (branch.value.callCount! - 1)) {
        await audioPlayer.playPlaylist([
          'assets/sounds/attention.wav',
          'assets/sounds/lastcall.wav',
          'assets/sounds/number/$firstDigit.wav',
          'assets/sounds/number/$secondDigit.wav',
          'assets/sounds/number/$thirdDigit.wav',
          'assets/sounds/already.wav',
        ]);
      } else {
        await audioPlayer.playPlaylist([
          'assets/sounds/attention.wav',
          'assets/sounds/calling.wav',
          'assets/sounds/number/$firstDigit.wav',
          'assets/sounds/number/$secondDigit.wav',
          'assets/sounds/number/$thirdDigit.wav',
          'assets/sounds/already.wav',
        ]);
      }
    } else {
      AppDialog.showToastError(
          title: 'To much number!',
          desc: 'The number is too long to call!',
          func: () async {
            await _logApp.writeLog(
                " Failed to update status served queue detail API ${error.toString()}");
          });
    }
  }

  void onItemSelected(
    String? value,
    String queueId,
    String paxId,
  ) {
    if (value == 'served') {
      AppDialog.confirmationMsg(
        title: "Served Queue",
        message: "Are you sure you want to update the status to 'Served'?",
        function: () async {
          await servedQueue(queueId, paxId);
          Get.back();
        },
        aksiText: "Ok",
      );
    } else if (value == 'void') {
      AppDialog.confirmationMsg(
        title: "Void Queue",
        message: "Are you sure you want to update the status to 'Void'?",
        function: () async {
          await voidQueue(queueId, paxId);
          Get.back();
        },
        aksiText: "Ok",
      );
    }
  }

  void onItemWitWithholdSelected(
    String? value,
    String queueId,
  ) {
    if (value == 'served') {
      AppDialog.confirmationMsg(
        title: "Served Queue",
        message: "Are you sure you want to update the status to 'Served'?",
        function: () async {
          Get.back();
          await servedQueueWithhold(queueId);
        },
        aksiText: "Ok",
      );
    } else if (value == 'void') {
      AppDialog.confirmationMsg(
        title: "Void Queue",
        message: "Are you sure you want to update the status to 'Void'?",
        function: () async {
          Get.back();
          await voidQueueWithhold(queueId);
        },
        aksiText: "Ok",
      );
    }
  }

  String formatQueueNumber(String number) {
    String firstCharacter = number.substring(0, 1);
    String numberSide = number.substring(1);
    int numberParse = int.parse(numberSide);
    return '$firstCharacter ' '${numberParse.toString()}';
  }

  String separateLetters(String input) {
    return input.replaceAll(RegExp(r'\d+'), '');
  }

  String separateNumbers(String input) {
    String numbers = input.replaceAll(RegExp(r'[A-Za-z]+'), '');
    return int.parse(numbers).toString();
  }

  int getFirstDigit(int value) {
    return value ~/ 100;
  }

  int getSecondDigit(int value) {
    return (value ~/ 10) % 10;
  }

  int getThirdDigit(int value) {
    return value % 10;
  }

  int getDigitCount(String value) {
    return value.length;
  }

  void changeVisibleWithold() {
    withHoldVisible.value = !withHoldVisible.value;
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration diff = DateTime.now().difference(dateTime);

    int days = diff.inDays;
    int hours = diff.inHours % 24;
    int minutes = diff.inMinutes % 60;

    String daysStr = days > 0 ? '$days d ' : '';
    String hoursStr = hours > 0 ? '$hours h ' : '';
    String minutesStr = minutes > 0 ? '$minutes m' : '';

    return '$daysStr$hoursStr$minutesStr'.trim();
  }
}
