import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/models/queue_item.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_dialog.dart';

import '../../repository/home_repository.dart';

class AdminController extends GetxController {
  final _api = HomeRepository();
  final branch = Branch().obs;
  final pax = <PaxWithQueue>[].obs;
  final ads = <Ads>[].obs;
  final queues = <Queue>[].obs;
  final allQueue = <QueueList>[];
  final Map<String, RxBool> buttonStatus = {};
  final Map<String, RxBool> buttonAdd = {};

  RxString error = ''.obs;
  final rxRequestStatus = Status.LOADING.obs;
  var currentDate = ''.obs;
  var currentTime = ''.obs;
  var isLoading = false.obs;
  var color = Colors.black.obs;
  var isMenuOpen = false.obs;
  final FlutterTts flutterTts = FlutterTts();
  var availableLanguages = <String>[].obs;
  var selectedPageNumber = 1.obs;
  var pageTotal = 1.obs;
  var loading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    startApiCall();
    apiQueueDetailList(selectedPageNumber.value);
  }

  void setRxRequestStatus(Status _value) => rxRequestStatus.value = _value;
  void setError(String _value) => error.value = _value;

  bool isButtonDisabled(String uuid) {
    if (!buttonStatus.containsKey(uuid)) {
      buttonStatus[uuid] = false.obs;
    }
    return buttonStatus[uuid]!.value;
  }

  void disableButton(String uuid) {
    if (!buttonStatus.containsKey(uuid)) {
      buttonStatus[uuid] = false.obs;
    }
    buttonStatus[uuid]!.value = true;
  }

  void enableButton(String uuid) {
    if (buttonStatus.containsKey(uuid)) {
      buttonStatus[uuid]!.value = false;
    }
  }

  bool isButtonAddDisabled(String uuid) {
    if (!buttonAdd.containsKey(uuid)) {
      buttonAdd[uuid] = false.obs;
    }
    return buttonAdd[uuid]!.value;
  }

  void disableAddButton(String uuid) {
    if (!buttonAdd.containsKey(uuid)) {
      buttonAdd[uuid] = false.obs;
    }
    buttonAdd[uuid]!.value = true;
  }

  void enableAddButton(String uuid) {
    if (buttonAdd.containsKey(uuid)) {
      buttonAdd[uuid]!.value = false;
    }
  }

  void startApiCall() {
    queueListApi();
    Timer.periodic(Duration(hours: 60), (Timer timer) {
      updateQueueListApi();
    });
  }

  void queueListApi() {
    _api.getDetailQueue().then((value) {
      branch.refresh();
      pax.clear();
      ads.clear();
      queues.clear();
      branch.value = Branch.fromJson(value);

      // Periksa jika data 'pax' tidak null
      if (value['data']['pax'] != null) {
        final List<dynamic> listPax = value['data']['pax'];
        pax.addAll(listPax.map((json) {
          final paxData = Pax.fromJson(json);
          // Mencari current queue untuk pax tertentu
          final queue = Queue.fromJson(value['data']['queue']['current']
              .firstWhere((element) => element.keys.first == paxData.uuid,
                  orElse: () => {}));
          return PaxWithQueue(pax: paxData, queue: queue);
        }).toList());
      }

      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());

      final List<dynamic>? listQueue = value['data']['queue']['current'];
      if (listQueue != null) {
        queues.addAll(listQueue.map((json) => Queue.fromJson(json)).toList());
      }
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      print(error);
      setRxRequestStatus(Status.ERROR);
    });
  }

  void updateQueueListApi() {
    _api.getDetailQueue().then((value) {
      branch.refresh();
      pax.clear();
      ads.clear();
      queues.clear();
      branch.value = Branch.fromJson(value);

      // Periksa jika data 'pax' tidak null
      if (value['data']['pax'] != null) {
        final List<dynamic> listPax = value['data']['pax'];
        pax.addAll(listPax.map((json) {
          final paxData = Pax.fromJson(json);
          // Mencari current queue untuk pax tertentu
          final queue = Queue.fromJson(value['data']['queue']['current']
              .firstWhere((element) => element.keys.first == paxData.uuid,
                  orElse: () => {}));
          return PaxWithQueue(pax: paxData, queue: queue);
        }).toList());
      }

      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());

      final List<dynamic>? listQueue = value['data']['queue']['current'];
      if (listQueue != null) {
        queues.addAll(listQueue.map((json) => Queue.fromJson(json)).toList());
      }
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      print(error);
    });
  }

  void apiQueueDetailList(int pageNumber) {
    isLoading(true);
    _api.getAllQueue(pageNumber).then((value) {
      isLoading(false);
      allQueue.clear();
      for (var item in value['data']['queues']) {
        allQueue.add(QueueList.fromJson(item));
      }
      pageTotal.value = value['data']['pages']['totalPages'];
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      isLoading(false);
      setError(error.toString());
      print(error.toString());
    });
  }

  void apiQueueDetailSearch(String search) {
    isLoading(true);
    _api.searchAllQueue(search).then((value) {
      isLoading(false);
      allQueue.clear();
      for (var item in value['data']['queues']) {
        allQueue.add(QueueList.fromJson(item));
      }
      pageTotal.value = value['data']['pages']['totalPages'];
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      isLoading(false);
      setError(error.toString());
      print(error.toString());
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

  String formatDynamicDate(dynamic date) {
    // Jika tanggal null, kembalikan pesan yang sesuai
    if (date == null || date['date'] == null) {
      return '';
    }

    // Parsing string tanggal menjadi objek DateTime
    DateTime parsedDate = DateTime.parse(date['date']);

    // Format tanggal sesuai yang diinginkan
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);

    return formattedDate;
  }

  String formatDate(DateTime dateTime) {
    // Membuat formatter untuk format yang diinginkan
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    // Menggunakan formatter untuk memformat tanggal dan waktu
    return formatter.format(dateTime);
  }

  Future<void> clearDirectory() async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final directory = Directory('${documentDirectory.path}/assets/videos/');
      if (await directory.exists()) {
        // Get all entities (files and subdirectories)
        final entities = directory.listSync(recursive: true);

        // Iterate in reverse order to avoid issues with deleting parent directories
        for (var entity in entities.reversed) {
          if (entity is File) {
            await entity.delete();
            print('Deleted file: ${entity.path}'); // Optional for logging
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
            print('Deleted directory: ${entity.path}');
          }
        }
      } else {
        print(
            'Directory does not exist: ${documentDirectory.path}/assets/videos/');
      }
    } catch (e) {
      print('Error deleting directory: $e');
    }
  }

  void newQueue(String paxId) {
    disableAddButton(paxId);
    _api.addNewQueue(paxId).then((value) async {
      final queueId = value['data']['queueId'];
      printQueue(queueId.toString());
      updateQueueListApi();
      apiQueueDetailList(selectedPageNumber.value);
      AppDialog.showToastSuccess(msg: value['description']);
      enableAddButton(paxId);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      enableAddButton(paxId);
      AppDialog.showToastError(msg: 'Unable to add Queue! $error');
      print(error);
    });
  }

  void printQueue(String queueId) {
    _api.printQueue(queueId).then((value) async {
      final number = value['data']['queueNumber'];
      final cancelCode = value['data']['cancelCode'];
      final qrData = value['data']['qrCode'];
      await printQr(number, cancelCode, qrData);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      AppDialog.showToastError(msg: 'Unable to print Queue! $error');
      print(error);
    });
  }

  void servedQueue(int queueId, String paxId) {
    _api.addStatusQueue(queueId, '4').then((value) async {
      final number = value['data']['queueNumber'];
      print('Served Queue Number: $number');
      updateQueueListApi();
      enableButton(paxId);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      AppDialog.showToastError(msg: 'Unable to update status served! $error');
      print(error);
    });
  }

  void voidQueue(int queueId, String paxId) {
    _api.addStatusQueue(queueId, '7').then((value) async {
      final number = value['data']['queueNumber'];
      print('void Queue Number: $number');
      updateQueueListApi();
      enableButton(paxId);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      AppDialog.showToastError(
          msg: 'Unable to update status void Queue! $error');
      print(error);
    });
  }

  void servedQueueDetail(int queueId) {
    _api.addStatusQueue(queueId, '4').then((value) async {
      final number = value['data']['queueNumber'];
      print('Served Queue Number: $number');
      updateQueueListApi();
      apiQueueDetailList(selectedPageNumber.value);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      AppDialog.showToastError(msg: 'Unable to update status served! $error');
      print(error);
    });
  }

  void voidQueueDetail(int queueId) {
    _api.addStatusQueue(queueId, '7').then((value) async {
      final number = value['data']['queueNumber'];
      print('void Queue Number: $number');
      updateQueueListApi();
      apiQueueDetailList(selectedPageNumber.value);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      AppDialog.showToastError(
          msg: 'Unable to update status void Queue! $error');
      print(error);
    });
  }

  void callQueue(String paxId, int queueCount) {
    disableButton(paxId);
    _api.callQueue(paxId).then((value) async {
      setRxRequestStatus(Status.LOADING);
      final number = value['data']['queueNumber'];
      final numberCall = formatQueueNumber(number);
      callSpeakFunction(numberCall, queueCount);
      updateQueueListApi();
      disableButton(paxId);
      Timer(Duration(seconds: branch.value.callDelay!), () {
        enableButton(paxId);
      });

      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      enableButton(paxId);
      setError(error.toString());
      AppDialog.showToastError(msg: 'Unable to calling Queue! $error');
      print(error);
    });
  }

  void resetQueue() {
    AppDialog.showDialogLoading();
    _api.reset().then((value) async {
      AppDialog.showToastSuccess(msg: 'Queue reset successfully.');
      updateQueueListApi();

      Get.offAllNamed(Routes.home);
    }).onError((error, stackTrace) {
      Get.back();
      AppDialog.showToastError(msg: 'Unable to reset! $error');
      print(error);
    });
  }

  void callSpeakFunction(String text, int queueCount) async {
    for (int i = 1; i <= branch.value.callRepeat!; i++) {
      await speak(text, queueCount);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> speak(String text, int queueCount) async {
    List<dynamic> languages = await flutterTts.getLanguages;
    if (languages.contains('id-ID')) {
      await flutterTts.setLanguage('id-ID');
    } else {
      await flutterTts.setLanguage('en-US');
    }
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    final audio = AudioPlayer();
    await audio.play(AssetSource('sounds/attention.mp3'));
    await audio.onPlayerComplete.first;
    if (languages.contains('id-ID')) {
      if (queueCount == (branch.value.callCount! - 1)) {
        final textSpeak = 'Panggilan Terakhir! Antrian Nomor! $text !';
        await flutterTts.speak(textSpeak);
      } else {
        final textSpeak = 'Antrian Nomor! $text!';
        await flutterTts.speak(textSpeak);
      }
    } else {
      if (queueCount == branch.value.callCount! - 1) {
        final textSpeak = 'Last Call! Queue Number! $text !';
        await flutterTts.speak(textSpeak);
      } else {
        final textSpeak = 'Queue Number! $text!';
        await flutterTts.speak(textSpeak);
      }
    }
  }

  void onItemSelected(String? value, int queueId, String paxId) {
    if (value == 'served') {
      servedQueue(queueId, paxId);
    } else if (value == 'void') {
      voidQueue(queueId, paxId);
    }
  }

  String formatQueueNumber(String number) {
    String firstCharacter = number.substring(0, 1);
    String numberSide = number.substring(1);
    int numberParse = int.parse(numberSide);
    return '$firstCharacter ' '${numberParse.toString()}';
  }

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.poppinsBold();
    final qrCodeImage = await QrPainter(
      data: 'google.com',
      version: QrVersions.auto,
      gapless: false,
    ).toImage(100);
    final qrCodeBytes =
        await qrCodeImage.toByteData(format: ImageByteFormat.png);
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  branch.value.fullName!,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  ' A001',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Image(
                  pw.MemoryImage(qrCodeBytes!.buffer.asUint8List()),
                  width: 100,
                  height: 100,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Scan the QR code above to check your queue status.',
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Cancellation Code: AAAA11',
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Thank you for visiting!',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> printQr(
    String queueNumber,
    String cancelCode,
    String qrData,
  ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.poppinsBold();
    final qrCodeImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImage(100);
    final qrCodeBytes =
        await qrCodeImage.toByteData(format: ImageByteFormat.png);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        orientation: pw.PageOrientation.portrait,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  branch.value.fullName!,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 16),
                pw.Image(
                  pw.MemoryImage(qrCodeBytes!.buffer.asUint8List()),
                  width: 100,
                  height: 100,
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  ' $queueNumber',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Scan the QR code above to check your queue status.',
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Cancellation Code: $cancelCode',
                  style: pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Thank you for visiting!',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This alpha-version is not complete and may or may not change further',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
