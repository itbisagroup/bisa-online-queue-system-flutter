import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/models/queue_item.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/secure_storage.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../../repository/home_repository.dart';

class AdminController extends GetxController {
  final _api = HomeRepository();
  final branch = Branch().obs;
  final pax = <PaxWithQueue>[].obs;
  final ads = <Ads>[].obs;
  final queues = <Queue>[].obs;
  final allQueue = <QueueList>[];
  final Map<String, RxBool> buttonCall = {};
  final Map<String, RxBool> buttonAdd = {};
  final Map<String, RxBool> updateStatus = {};
  RxString error = ''.obs;
  final rxRequestStatus = Status.LOADING.obs;
  final TextEditingController textEditingController = TextEditingController();
  var currentDate = ''.obs;
  var currentTime = ''.obs;
  var isLoading = false.obs;
  var statusRealtime = false.obs;
  late final player = Player();
  late final controllerVideo = VideoController(player);
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
    queueListApi();
  }

  void setRxRequestStatus(Status _value) => rxRequestStatus.value = _value;
  void setError(String _value) => error.value = _value;

  Future<void> realtimeApi() async {
    final myChannel = Supabase.instance.client.channel('my_channel');

    myChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'status',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id_branch',
              value: branch.value.id!),
          callback: (PostgresChangePayload payload) async {
            final Map<String, dynamic> newRecord = payload.newRecord;
            final bool isActive = newRecord['isActive'];
            if (isActive) {
              statusRealtime.value = true;
              Timer(Duration(seconds: 60), () async {
                statusRealtime.value = false;
              });
              await player.setVolume(20.0);
              Timer(Duration(seconds: 8), () async {
                await player.setVolume(100.0);
              });
              updateQueueListApi();
            } else {
              statusRealtime.value = true;
              Timer(Duration(seconds: 60), () async {
                statusRealtime.value = false;
              });
              updateQueueListApi();
            }
          },
        )
        .subscribe();
  }

  Future<void> setRealtime() async {
    // Set isActive to true
    await Supabase.instance.client
        .from('status')
        .update({'isActive': true}).eq('id_branch', branch.value.id!);
  }

  Future<void> setRealtimeSoundVideo() async {
    // Set isActive to true
    await Supabase.instance.client
        .from('status')
        .update({'isActive': false}).eq('id_branch', branch.value.id!);
  }

  bool isButtonDisabled(String uuid) {
    if (!buttonCall.containsKey(uuid)) {
      buttonCall[uuid] = false.obs;
    }
    return buttonCall[uuid]!.value;
  }

  void disableButton(String uuid) {
    if (!buttonCall.containsKey(uuid)) {
      buttonCall[uuid] = false.obs;
    }
    buttonCall[uuid]!.value = true;
  }

  void enableButton(String uuid) {
    if (buttonCall.containsKey(uuid)) {
      buttonCall[uuid]!.value = false;
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

  bool isupdateStatusDisabled(String uuid) {
    if (!updateStatus.containsKey(uuid)) {
      updateStatus[uuid] = false.obs;
    }
    return updateStatus[uuid]!.value;
  }

  void disableUpdateStatus(String uuid) {
    if (!updateStatus.containsKey(uuid)) {
      updateStatus[uuid] = false.obs;
    }
    updateStatus[uuid]!.value = true;
  }

  void enableUpdateStatus(String uuid) {
    if (updateStatus.containsKey(uuid)) {
      updateStatus[uuid]!.value = false;
    }
  }

  void queueListApi() async {
    _api.getDetailQueue().then((value) async {
      branch.refresh();
      pax.clear();
      ads.clear();
      queues.clear();
      branch.value = Branch.fromJson(value);
      await realtimeApi();
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
      setRxRequestStatus(Status.ERROR);

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

  Future<void> custommerScreen() async {
    await downloadAds().then((value) {
      Get.toNamed(Routes.customer);
    }).onError((error, stackTrace) {
      AppDialog.showToastError(msg: 'Failed to download ads! $error');
      print(error);
    });
  }

  Future<void> downloadAds() async {
    try {
      AppDialog.showDialogLoading();
      final String? key = await SecureStorage().getKey();
      for (var ad in ads) {
        var videoDirectory = await getApplicationDocumentsDirectory();
        var path = "${videoDirectory.path}/assets/videos/";
        var filePathAndName = '$path/${ad.content}';
        File video = File(filePathAndName);

        // Check if the file already exists
        if (await video.exists()) {
          print('File already exists: ${ad.uuid}');
          continue;
        }

        final url =
            Uri.parse('${BaseApiServices.adsEndpoint}/${ad.uuid}/download');
        Map<String, String> requestExtraHeaders = {'Queue': key!};
        final response = await http
            .get(url, headers: requestExtraHeaders)
            .timeout(Duration(minutes: 1));
        if (response.statusCode == 200) {
          await Directory(path).create(recursive: true);
          await video.writeAsBytes(response.bodyBytes);
          print('Successfully downloaded ${ad.uuid}');
        } else {
          AppDialog.showToastError(msg: response.statusCode.toString());
          print('Failed to download ad with UUID: ${ad.uuid}');
        }
      }
    } catch (e) {
      Get.back();
      AppDialog.showToastError(msg: 'Failed to download ads!: $e');
      print(e.toString());
    } finally {
      Get.back();
    }
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
      AppDialog.showToastSuccess(msg: value['description']);
      enableAddButton(paxId);

      setRxRequestStatus(Status.COMPLETED);
      await setRealtimeSoundVideo();
    }).onError((error, stackTrace) async {
      setError(error.toString());
      enableAddButton(paxId);
      await setRealtime();
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
      AppDialog.showToastError(msg: 'Unable to print! Please print again.');
      print(error);
    });
  }

  void servedQueue(int queueId, String paxId) {
    disableUpdateStatus(paxId);
    _api.addStatusQueue(queueId, '4').then((value) async {
      final number = value['data']['queueNumber'];
      print('Served Queue Number: $number');
      await setRealtime();
      enableButton(paxId);
      enableUpdateStatus(paxId);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      setError(error.toString());
      enableUpdateStatus(paxId);
      AppDialog.showToastError(msg: 'Unable to update status served! $error');
      print(error);
    });
  }

  void voidQueue(int queueId, String paxId) {
    disableUpdateStatus(paxId);
    _api.addStatusQueue(queueId, '7').then((value) async {
      final number = value['data']['queueNumber'];
      print('void Queue Number: $number');
      await setRealtime();
      enableButton(paxId);
      enableUpdateStatus(paxId);
      AppDialog.showToastSuccess(msg: value['description']);
      setRxRequestStatus(Status.COMPLETED);
    }).onError((error, stackTrace) {
      enableUpdateStatus(paxId);
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
      await setRealtime();
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
      await setRealtime();
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
      final number = value['data']['queueNumber'];
      final numberCall = formatQueueNumber(number);
      callSpeakFunction(numberCall, queueCount);
      await setRealtime();
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
      await setRealtime();

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
    await flutterTts.setVolume(100);
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
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 15),
                pw.Image(
                  pw.MemoryImage(qrCodeBytes!.buffer.asUint8List()),
                  width: 100,
                  height: 100,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  ' A001',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Scan the QR code above to check your queue status.',
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Cancellation Code: ',
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'AAAA11',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ]),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Thank you for visiting!',
                  style: pw.TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  '*This alpha-version is not complete and may or may not change further',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
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
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 15),
                pw.Image(
                  pw.MemoryImage(qrCodeBytes!.buffer.asUint8List()),
                  width: 100,
                  height: 100,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  queueNumber,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Scan the QR code above to check your queue status.',
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Cancellation Code: ',
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        cancelCode,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ]),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Thank you for visiting!',
                  style: pw.TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  '*This alpha-version is not complete and may or may not change further',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
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
