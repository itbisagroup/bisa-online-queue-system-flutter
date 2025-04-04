import 'dart:async';
import 'dart:convert';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cron/cron.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:queue_system/data/response/file_downloader.dart';
import 'package:queue_system/models/ads.dart';
import 'package:queue_system/models/branch.dart';
import 'package:queue_system/models/pax.dart';
import 'package:queue_system/repository/branch_repository.dart';
import 'package:queue_system/repository/sync_repository.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/enum/queue_status.dart';
import 'package:queue_system/utils/enum/treshold.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/view_models/controller/printer_controller.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/models/queue_item.dart';
import 'package:queue_system/utils/audio_player.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:retry/retry.dart';
import '../../repository/queue_repository.dart';

class AdminController extends GetxController {
  final _apiQueue = QueueRepository();
  final _apiBranch = BranchRepository();
  final LogApp _logApp = LogApp();
  final Uri _url = Uri.parse(
      'https://helpdesk.bisagroup.co.id/troubleshoot/bisa-online-queue-system');
  final cron = Cron();
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
  var isEnglishApp = true.obs;
  var isEnglishPrinter = true.obs;
  var withHoldVisible = true.obs;
  var statusSynch = ''.obs;
  var lastSynch = ''.obs;
  var isCronRunning = false.obs;
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
    await branchData();

    final title = await storage.read(key: 'env_title');
    final label = await storage.read(key: 'env_label');
    final langApp = await storage.read(key: 'lang');
    final langPrinter = await storage.read(key: 'lang_print');
    final autoFullscreen = await storage.read(key: 'auto_fullscreen');
    final autoFullScreenTimer =
        await storage.read(key: 'auto_fullscreen_timer');
    final adsMuted = await storage.read(key: 'ads_muted');
    isEnglishApp.value = langApp == 'en' ? true : false;
    isEnglishPrinter.value = langPrinter == 'en' ? true : false;
    final videoPath = await storage.read(key: 'env_path');
    if (title == null) {
      await storage.write(key: 'env_title', value: 'Nomor Antrian');
    }
    if (label == null) {
      await storage.write(
          key: 'env_label', value: 'Silakan Konfirmasi ke Greeter');
    }
    if (videoPath == null) {
      await storage.write(
          key: 'env_path',
          value: 'd:/laragon/www/bisa-online-queue/public/assets/ads/');
    }

    if (autoFullScreenTimer == null) {
      await storage.write(key: 'auto_fullscreen_timer', value: '2');
    }
    if (adsMuted == null) {
      await storage.write(key: 'ads_muted', value: '1');
    }
    if (autoFullscreen == null) {
      await storage.write(key: 'auto_fullscreen', value: '1');
    }
    final shift = await const FlutterSecureStorage().read(key: 'shift_date');
    if (shift != null) {
      DateTime targetDate = DateTime.parse(shift);
      DateTime now = DateTime.now();

      if (now.year > targetDate.year ||
          (now.year == targetDate.year && now.month > targetDate.month) ||
          (now.year == targetDate.year &&
              now.month == targetDate.month &&
              now.day > targetDate.day)) {
        await dialogEndShift();
      }
    }
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (_isDialogOpen.value) {
        return false;
      }
      _isDialogOpen.value = true;
      final shouldClose = await showDialog<bool>(
        context: NavigationService.navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: AppText(
              text: 'quit_message'.tr,
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
                child: AppText(
                  text: 'yes'.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _isDialogOpen.value = false;
                  Navigator.of(context).pop(false);
                },
                child: AppText(
                  text: 'no'.tr,
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

  dialogEndShift() async {
    Future.delayed(const Duration(seconds: 5), () {
      AppDialog.showToastShiftEnd(
          title: "Info",
          desc: "forget_end_shift".tr,
          ok: () {
            Get.toNamed(Routes.shift);
          });
    });
  }

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setError(String value) => error.value = value;

  void runCronTask(bool cronRunning) {
    if (cronRunning) {
      isCronRunning.value = cronRunning;

      int errorCount = 0;

      cron.schedule(Schedule.parse('* * * * *'), () async {
        try {
          await apiSync.sendData();
          statusCron.value = true;
          lastCrone.value = DateFormat('HH:mm').format(DateTime.now());
          if (errorCount > 15) {
            await _logApp.writeLog(
                'Success, CRON is running after $errorCount failed attempts');

            errorCount = 0;
          }
          errorCount = 0;
        } catch (error) {
          errorCount++;
          statusCron.value = false;
          lastCrone.value = DateFormat('HH:mm').format(DateTime.now());

          if (errorCount % 5 == 0) {
            await apiSync
                .flushParameter()
                .then((value) {})
                .onError((error, stackTrace) async {});
          }
          if (errorCount % 20 == 0) {
            await _logApp.writeLog(
                '${error.toString()} CRON has failed $errorCount times');
          }
        }
      });
    }
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

  List<String?> clearQueueNumbers() {
    List<String?> notation =
        paxWithQueue.map((paxWithQueue) => paxWithQueue.pax?.notation).toList();

    List<String?> queue = paxWithQueue
        .map((paxWithQueue) => paxWithQueue.queue?.queueNumber)
        .toList();

    for (int i = 0; i < queue.length; i++) {
      if (queue[i] != null && queue[i] != "0000") {
        // Replace the number part of the queue with "000" while keeping the notation
        queue[i] = "${notation[i]}000";
      }
    }
    return queue;
  }

  List<String?> clearAllNextQueueNumbers() {
    List<String?> notation =
        paxWithQueue.map((paxWithQueue) => paxWithQueue.pax?.notation).toList();

    List<String?> queue = paxWithQueue
        .map((paxWithQueue) => paxWithQueue.queue?.nextQueue)
        .toList();

    for (int i = 0; i < queue.length; i++) {
      if (queue[i] != null && queue[i] != "0000") {
        queue[i] = "${notation[i]}000";
      }
    }
    return queue;
  }

  List<String> getAllWithholdQueueNumbers() {
    // Filter out entries with queueNumber "0000" and map to a list of queueNumbers
    return withhold
        .where((item) => item.queueNumber != "0000")
        .map((item) => item.queueNumber!)
        .toList();
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

  List<String?> getAllAdsid() {
    return ads.map((ad) => ad.id).toList();
  }

  Future<void> updateQueueSecondaryWindows() async {
    // Get all queue numbers
    List<String?> queueNumbers = getAllQueueNumbers();
    List<String?> queueNextNumbers = getAllNextQueueNumbers();
    List<String> withholdQueueNumbers = getAllWithholdQueueNumbers();
    String jsonDataList = jsonEncode(queueNumbers);
    String nextQueue = jsonEncode(queueNextNumbers);

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "updateQueue", jsonDataList);
      DesktopMultiWindow.invokeMethod(windowID, "nextQueue", nextQueue);
      DesktopMultiWindow.invokeMethod(
          windowID, "withholdQueue", jsonEncode(withholdQueueNumbers));
    }
  }

  Future<void> clearQueueSecondaryWindows() async {
    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "endShift", '1');
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
    await updateBranchData();

    if (secondaryWindowIDs.isNotEmpty) {
      await updateDataSecondaryWindows();
      await updateQueueSecondaryWindows();
    }
    _apiSync.getData().then((value) async {
      statusSynch.value = 'succeed_sync_data'.tr;
      lastSynch.value = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    }).onError((error, stackTrace) async {
      logCase(error.toString(),
          'Failed to synchronize data application from the live server API');
      statusSynch.value = '${'failed_sync_data'.tr} $error';
      lastSynch.value = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    });
  }

  Future<void> callSecondaryWindows(String number, int queueCount) async {
    // Get all queue numbers
    String numberTextView = jsonEncode(number);
    String callCount = jsonEncode(queueCount);
    List<String?> queueNextNumbers = getAllNextQueueNumbers();
    String nextQueue = jsonEncode(queueNextNumbers);
    List<String> withholdQueueNumbers = getAllWithholdQueueNumbers();

    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "callCount", callCount);
      DesktopMultiWindow.invokeMethod(windowID, "callQueue", numberTextView);
      DesktopMultiWindow.invokeMethod(windowID, "nextQueue", nextQueue);
      DesktopMultiWindow.invokeMethod(
          windowID, "withholdQueue", jsonEncode(withholdQueueNumbers));
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
    String lang = jsonEncode(isEnglishApp.value ? 'en' : 'id');
    for (var windowID in secondaryWindowIDs) {
      if (ads.isNotEmpty) {
        DesktopMultiWindow.invokeMethod(windowID, "updateAds", jsonAdsList);
      }
      DesktopMultiWindow.invokeMethod(windowID, "lang", lang);
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

  Future<void> updateBranchData() async {
    AppDialog.showDialogLoading();
    _apiBranch.getBranch().then((value) async {
      Get.back();
      branch.refresh();
      ads.clear();
      pax.clear();
      branch.value = Branch.fromJson(value);
      await updateQueueListApi();
      final List<dynamic> listPax = value['data']['pax'];
      pax.addAll(listPax.map((json) => Pax.fromJson(json)).toList());

      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());
    }).onError((error, stackTrace) async {
      setError(error.toString());
      logCase(error.toString(),
          'Failed reinitiate the application. Can not get branch data from the Local Server API');
      Get.back();
      setRxRequestStatus(Status.ERROR);
    });
  }

  Future<void> branchData() async {
    setRxRequestStatus(Status.LOADING);
    await Future.delayed(const Duration(seconds: 5));
    _apiBranch.getBranch().then((value) async {
      branch.refresh();
      ads.clear();
      pax.clear();
      await queueListApi();
      branch.value = Branch.fromJson(value);

      final List<dynamic> listPax = value['data']['pax'];
      pax.addAll(listPax.map((json) => Pax.fromJson(json)).toList());

      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      logCase(error.toString(),
          'Failed to open the application. Can not get branch data from the Local Server API');
      setRxRequestStatus(Status.ERROR);
    });
  }

  Future<void> queueListApi() async {
    _apiQueue.getDetailQueue().then((value) async {
      if (pax.isNotEmpty) {
        paxWithQueue.addAll(pax.map((json) {
          final queue = Queue.fromJson(value['data']['queue']['current']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));

          // Retrieve a list of Withhold entries for each pax
          final withholdEntries = Withhold.listFromJson(value['data']['queue']
                  ['withhold']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));

          // Add each pax's withhold entries to the global withhold list
          // Add non-"0000" queueNumbers to withhold list
          withhold.addAll(
              withholdEntries.where((item) => item.queueNumber != "0000"));

          return PaxWithQueue(
              pax: json, queue: queue, withhold: withholdEntries);
        }).toList());
      }
      runCronTask(true);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      logCase(error.toString(),
          'Failed to get current queue view from the local server API');
      setRxRequestStatus(Status.ERROR);
    });
  }

  void logCase(String error, String message) async {
    String? branchKey = await storage.read(key: 'key');
    if (branchKey != null) {
      branchKey = branchKey.substring(0, branchKey.indexOf(':'));
    }

    // Retry function for sending Telegram logs
    Future<void> sendTelegramLogWithRetry(
        String logMessage, String label) async {
      const r = RetryOptions(maxAttempts: 3); // Retry up to 3 times
      await r.retry(
        () => _logApp.sendTelegramLog(logMessage, label),
      );
    }

    switch (error) {
      case 'No Internet':
        await sendTelegramLogWithRetry(
            '$branchKey : SERVER NOT ACTIVE. $message',
            ThresholdError.emergency.label);
        await _logApp.writeLog('$branchKey: ["Server Not Active"] :$message');
        if (kDebugMode) {
          print('$branchKey :["Server Not Active"] :$message');
        }
        break;

      case 'Request Timed Out':
        await sendTelegramLogWithRetry(
            '$branchKey : $error, $message', ThresholdError.warning.label);
        await _logApp.writeLog('$branchKey :[$error]$message');
        if (kDebugMode) {
          print('$branchKey :[$error] $message');
        }
        break;

      case 'Internal Server Error':
        await sendTelegramLogWithRetry(
            '$branchKey : $error, $message', ThresholdError.emergency.label);
        await _logApp.writeLog('$branchKey:[$error] $message');
        if (kDebugMode) {
          print('$branchKey :[$error] $message');
        }
        break;

      case 'Unauthorized':
        await sendTelegramLogWithRetry(
            '$branchKey : $error, $message', ThresholdError.critical.label);
        await _logApp.writeLog('$branchKey:[$error] $message');
        if (kDebugMode) {
          print('$branchKey :[$error] $message');
        }
        break;

      case 'Forbidden':
        await _logApp.writeLog('$branchKey:[$error] $message');
        break;

      case 'Bad Gateway':
        await sendTelegramLogWithRetry(
            '$branchKey : $error, $message', ThresholdError.warning.label);
        await _logApp.writeLog('$branchKey:[$error] $message');
        if (kDebugMode) {
          print('$branchKey :[$error] $message');
        }
        break;

      case 'Too Many Requests':
        await sendTelegramLogWithRetry(
            '$branchKey : Too Many Requests, $message',
            ThresholdError.warning.label);
        await _logApp.writeLog('$branchKey:[$error] $message');
        if (kDebugMode) {
          print('$branchKey [$error] $message');
        }
        break;

      case 'Success':
        await sendTelegramLogWithRetry(
            '$branchKey : $message', ThresholdError.info.label);
        await _logApp.writeLog('$branchKey $message');
        if (kDebugMode) {
          print('$branchKey: [$error] $message');
        }
        break;

      case '500':
        await sendTelegramLogWithRetry(
            '$branchKey : $message', ThresholdError.emergency.label);
        await _logApp.writeLog('$branchKey $message');
        if (kDebugMode) {
          print('$branchKey: [$error] $message');
        }
        break;

      default:
        await _logApp.writeLog('$branchKey$error $message');
        if (kDebugMode) {
          print('$branchKey: [$error] $message');
        }
    }
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

          // Retrieve a list of Withhold entries for each pax
          final withholdEntries = Withhold.listFromJson(value['data']['queue']
                  ['withhold']
              .firstWhere((element) => element.keys.first == json.id,
                  orElse: () => {}));

          // Add non-"0000" queueNumbers to withhold list
          withhold.addAll(
              withholdEntries.where((item) => item.queueNumber != "0000"));

          return PaxWithQueue(
              pax: json, queue: queue, withhold: withholdEntries);
        }).toList());
      }
      Get.back();
      isCronRunning.value ? runCronTask(false) : runCronTask(true);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setRxRequestStatus(Status.ERROR);
      setError(error.toString());
      Get.back();
      logCase(error.toString(),
          'Failed to reinitiate get current data queue view from the local server API');
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
      logCase(error.toString(),
          'Failed to get all queue data from the local server API');
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
      logCase(error.toString(),
          'Failed to search=$search queue index API from the local server API');
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

  String statusLabel(int value) {
    if (value == 1) {
      return QueueStatus.waiting.label;
    } else if (value == 2) {
      return QueueStatus.calling.label;
    } else if (value == 3) {
      return QueueStatus.lastCall.label;
    } else if (value == 4) {
      return QueueStatus.served.label;
    } else if (value == 7) {
      return QueueStatus.voided.label;
    } else if (value == 8) {
      return QueueStatus.cancelled.label;
    } else if (value == 9) {
      return QueueStatus.expired.label;
    } else {
      return '';
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
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> newQueue(String paxId, String paxQuantity) async {
    disableAddButton(paxId);

    _apiQueue.addNewQueue(paxId, paxQuantity).then((value) async {
      final queueId = value['data']['queue']['queueCode'];
      String queueNumber = value['data']['queue']['queueNumber'];
      doFullscreen();
      await AppDialog.showToastSuccess(
        title: queueNumber,
        desc: '${'queue'.tr} $queueNumber ${'success_create'.tr} ',
        func: () async {
          await updateQueueListApi();
          // await updateNextQueue();
          await printQueue(queueId);
          enableAddButton(paxId);
        },
      );

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      enableAddButton(paxId);
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'unable_to_create_queue'.tr,
        func: () {
          logCase(error.toString(),
              'Failed to create new queue to the local server API');
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
      final queueCall = value['data']['queue']['branch']['callCount'];

      if (printer.ipController.text.isNotEmpty) {
        printer.setIpAddress(printer.ipController.text);
      }
      await printer.printQueue(
          branch.value.fullName!, qrData, number, cancelCode, queueCall);

      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) async {
      setError(error.toString());
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'unable_to_print_queue'.tr,
        func: () async {
          Get.back();
          logCase(error.toString(),
              'Failed to print queue');
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
        desc: 'update_serve'.tr,
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
          title: 'failed'.tr,
          desc: 'failed_serve'.tr,
          func: () async {
            logCase(error.toString(),
                ' Failed to update status served queue to the local server API');
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
      doFullscreen();
      await AppDialog.showToastSuccess(
        title: number,
        desc: 'update_void'.tr,
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
          title: 'failed'.tr,
          desc: 'failed_void'.tr,
          func: () async {
            logCase(error.toString(),
                ' Failed to update status void queue to the local server API');
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
        desc: 'update_serve'.tr,
        func: () async {
          await updateQueueListApi();
        },
      );
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_serve'.tr,
        func: () async {
          logCase(error.toString(),
              ' Failed to update status served queue to the local server API');
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
          desc: 'update_void'.tr,
          func: () async {
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      Get.back();
      setError(error.toString());
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_void'.tr,
        func: () async {
          logCase(error.toString(),
              ' Failed to update status void queue to the local server API');
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
          desc: '${'update_qty'.tr} $qty',
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_qty'.tr,
        func: () async {
          logCase(error.toString(),
              ' Failed to update quantity queue to the local server API');
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
          desc: 'update_serve'.tr,
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      setError(error.toString());
      Get.back();
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_serve'.tr,
        func: () async {
          logCase(error.toString(),
              ' Failed to update status served queue to the local server API');
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
          desc: 'update_void'.tr,
          func: () async {
            await apiQueueDetailList();
            await updateQueueListApi();
          });
    }).onError((error, stackTrace) {
      Get.back();
      setError(error.toString());
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'failed_void'.tr,
        func: () async {
          logCase(error.toString(),
              ' Failed to update status served queue to the local server API');
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
            desc: '${'queue'.tr} $queueNumberCall ${'called'.tr}',
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
          desc: '${'queue'.tr} $queueNumberCall ${'called'.tr}',
          func: () async {
            await updateQueueListApi();
          },
        );
        setRxRequestStatus(Status.COMPLETED);
      }
    }).onError((error, stackTrace) {
      enableButton(paxId);
      setError(error.toString());
      String cleanedMessage = error.toString().replaceAll(RegExp(r'[{}]'), '');
      List<String> keyValue = cleanedMessage.split(': ');
      String message = keyValue[1];
      if (error.toString().contains('no_queue'.tr)) {
        message = 'canceled_queue'.tr;
      } else {
        message = 'failed_call'.tr;
      }
      AppDialog.showToastError(
        title: 'failed'.tr,
        desc: message,
        func: () async {
          if (error.toString().contains('no queue')) {
            await updateQueueListApi();
          }
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
          'assets/sounds/alphabet/$letters.wav',
          'assets/sounds/number/$firstDigit.wav',
          'assets/sounds/number/$secondDigit.wav',
          'assets/sounds/number/$thirdDigit.wav',
          'assets/sounds/already.wav',
        ]);
      } else {
        await audioPlayer.playPlaylist([
          'assets/sounds/attention.wav',
          'assets/sounds/calling.wav',
          'assets/sounds/alphabet/$letters.wav',
          'assets/sounds/number/$firstDigit.wav',
          'assets/sounds/number/$secondDigit.wav',
          'assets/sounds/number/$thirdDigit.wav',
          'assets/sounds/already.wav',
        ]);
      }
    } else {
      AppDialog.showToastError(
          title: 'too_much_number'.tr,
          desc: 'too_much_number_desc'.tr,
          func: () async {
            logCase('-', ' The number is too long to call ($number)');
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
        title: "${'served'.tr} ${'queue'.tr}",
        message: "sure_to_serve".tr,
        function: () async {
          await servedQueue(queueId, paxId);
          Get.back();
        },
        aksiText: "Ok",
      );
    } else if (value == 'void') {
      AppDialog.confirmationMsg(
        title: "${'void'.tr} ${'queue'.tr}",
        message: "sure_to_void".tr,
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
        title: "${'served'.tr} ${'queue'.tr}",
        message: "sure_to_serve".tr,
        function: () async {
          Get.back();
          await servedQueueWithhold(queueId);
        },
        aksiText: "Ok",
      );
    } else if (value == 'void') {
      AppDialog.confirmationMsg(
        title: "${'void'.tr} ${'queue'.tr}",
        message: "sure_to_void".tr,
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

    String daysStr = days > 0 ? '$days ${'d'} ' : '';
    String hoursStr = hours > 0 ? '$hours ${'h'} ' : '';
    String minutesStr = minutes > 0 ? '$minutes ${'m'} ' : '';

    return '$daysStr$hoursStr$minutesStr'.trim();
  }

  Future<void> launchUrlDoc() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void lang() async {
    isEnglishApp.value = !isEnglishApp.value;
    await storage.write(key: 'lang', value: isEnglishApp.value ? 'en' : 'id');
    Get.updateLocale(Locale(isEnglishApp.value ? 'en' : 'id'));
    String jsonDataList = jsonEncode(isEnglishApp.value ? 'en' : 'id');
    for (var windowID in secondaryWindowIDs) {
      DesktopMultiWindow.invokeMethod(windowID, "lang", jsonDataList);
    }
  }

  void langPrinter() async {
    isEnglishPrinter.value = !isEnglishPrinter.value;
    await storage.write(
        key: 'lang_print', value: isEnglishPrinter.value ? 'en' : 'id');
  }

  void download() async {
    FileDownloader downloader = FileDownloader();
    List<String?> id = getAllAdsid();
    List<String?> ads = getAllAdsNumbers();
    await downloader.downloadFiles(id, ads);
  }
}
