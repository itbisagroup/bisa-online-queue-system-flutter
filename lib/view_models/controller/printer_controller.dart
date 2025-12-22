import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:queue_system/models/end_shift.dart';
import 'package:queue_system/models/printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/models/shift.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/lang_printer.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterController extends GetxController {
  // Printer Type [bluetooth, usb, network]
  var defaultPrinterType = PrinterType.bluetooth.obs;
  final LogApp _logApp = LogApp();
  var isBle = false.obs;
  var reconnect = false.obs;
  var isLoading = false.obs;
  var isConnected = false.obs;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[].obs;
  StreamSubscription<PrinterDevice>? subscription;
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  StreamSubscription<USBStatus>? subscriptionUsbStatus;
  var currentStatus = BTStatus.none.obs;
  USBStatus currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  final ipAddress = ''.obs;
  final port = '9100'.obs;
  final ipController = TextEditingController();
  final portController = TextEditingController();
  var selectedPrinter = BluetoothPrinter().obs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Platform.isWindows) defaultPrinterType.value = PrinterType.usb;
    portController.text = port.value;
    await loadSettingStorage();
    await scan();

    // subscription to listen change status of bluetooth connection
    subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      if (kDebugMode) {
        print(' ----------------- status bt $status ------------------ ');
      }
      currentStatus.value = status;
      if (status == BTStatus.connected) {
        isConnected.value = true;
      }
      if (status == BTStatus.none) {
        isConnected.value = false;
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });

    // PrinterManager.instance.stateUSB is only supported on Android
    subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      if (kDebugMode) {
        print(' ----------------- status usb $status ------------------ ');
      }
      currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });
  }

  // @override
  // void dispose() {
  //   subscription?.cancel();
  //   subscriptionBtStatus?.cancel();
  //   subscriptionUsbStatus?.cancel();
  //   portController.dispose();
  //   ipController.dispose();
  //   super.dispose();
  // }

  Future<void> loadSettingStorage() async {
    isLoading.value = true;
    try {
      String? typePrinterStorage =
          await _secureStorage.read(key: 'typePrinter');
      if (typePrinterStorage != null) {
        switch (typePrinterStorage) {
          case 'PrinterType.usb':
            selectedPrinter.value.typePrinter = PrinterType.usb;
            defaultPrinterType.value = PrinterType.usb;
            break;
          case 'PrinterType.bluetooth':
            selectedPrinter.value.typePrinter = PrinterType.bluetooth;
            defaultPrinterType.value = PrinterType.bluetooth;
            break;
          case 'PrinterType.network':
            selectedPrinter.value.typePrinter = PrinterType.network;
            defaultPrinterType.value = PrinterType.network;
            break;
          default:
            selectedPrinter.value.typePrinter = PrinterType.bluetooth;
        }
      }
      ipController.text = (await _secureStorage.read(key: 'ipAddress')) ?? '';
      selectedPrinter.value.deviceName =
          (await _secureStorage.read(key: 'name')) ?? '';
      selectedPrinter.value.productId =
          (await _secureStorage.read(key: 'productId')) ?? '';
      selectedPrinter.value.vendorId =
          (await _secureStorage.read(key: 'vendorId')) ?? '';
      String? isConnectedStorage =
          await _secureStorage.read(key: 'isConnected');
      isConnected.value = (isConnectedStorage == 'true');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettingStorage() async {
    await _secureStorage.write(
        key: 'typePrinter',
        value: selectedPrinter.value.typePrinter.toString());
    await _secureStorage.write(
        key: 'ipAddress', value: selectedPrinter.value.address);
    await _secureStorage.write(
        key: 'isConnected', value: isConnected.value.toString());
    await _secureStorage.write(
        key: 'name', value: selectedPrinter.value.deviceName);
    await _secureStorage.write(
        key: 'productId', value: selectedPrinter.value.productId);
    await _secureStorage.write(
        key: 'vendorId', value: selectedPrinter.value.vendorId);
  }

  // method to scan devices according PrinterType
  Future<void> scan() async {
    devices.clear();
    subscription = printerManager
        .discovery(type: defaultPrinterType.value, isBle: isBle.value)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: isBle.value,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType.value,
      ));
    });
  }

  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    port.value = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: ipAddress.value,
      port: port.value,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void setIpAddress(String value) {
    ipAddress.value = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: ipAddress.value,
      port: port.value,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void selectDevice(BluetoothPrinter device) async {
    if ((device.address != selectedPrinter.value.address) ||
        (device.typePrinter == PrinterType.usb &&
            selectedPrinter.value.vendorId != device.vendorId)) {
      await PrinterManager.instance
          .disconnect(type: selectedPrinter.value.typePrinter);
    }
    selectedPrinter.value = device;
    await saveSettingStorage();
  }

  Future<void> printReceiveTest() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.hr();
    bytes += generator.text('SUMMARY',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('PRINTER TEST FOR QUEUE SYSTEM',
        styles: const PosStyles(align: PosAlign.center));
    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(printAt,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '=');
    bytes += generator.hr();

    printEscPos(bytes, generator);
  }

  Future<void> printQueue(String title, String qrCode, String queueNumber,
      String cancelCode, int callCount) async {
    List<int> bytes = [];
    final langPrint = await _secureStorage.read(key: 'lang_print');
    final showQr = await _secureStorage.read(key: 'show_qr');
    final bool shouldShowQr =
        showQr == 'true' || showQr == null; // default true jika null

    final printerLang = PrinterLang(langPrint ?? 'en');
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm80, profile);

    // Title Section
    bytes += generator.text(title.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    // Queue Number Section
    bytes += generator.text(
      printerLang.customMessage('queue_number'),
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.text(queueNumber,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size4,
          height: PosTextSize.size3,
        ),
        linesAfter: 1);

    // QR Code Section - Hanya tampilkan jika shouldShowQr = true
    if (shouldShowQr) {
      bytes += generator.text(
        printerLang.customMessage('scan_instruction'),
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
      bytes += generator.qrcode(
        qrCode,
        size: QRSize.size8,
        align: PosAlign.center,
      );
      // Cancel Code Section
      bytes += generator.text(
        printerLang.customMessage('cancel_instruction'),
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
      bytes += generator.text(cancelCode,
          styles:
              const PosStyles(align: PosAlign.center, width: PosTextSize.size2),
          linesAfter: 1);
    }

    // Footer Line
    bytes += generator.text(
      printerLang.customMessage(
        'note',
      ),
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.text(
      '${printerLang.customMessage('note_cancel', placeholders: {
            'callCount': callCount.toString()
          })} ${printerLang.customMessage(
        callCount > 1 ? 'plural_call' : 'singular_call',
      )}',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.text(
        printerLang.customMessage(
          'take_a_number',
        ),
        styles: const PosStyles(
          align: PosAlign.center,
        ),
        linesAfter: 1);

    bytes += generator.text(
      'BISA Online Queue System V.${VersionApp.version}',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    final printAt = langPrint == 'id'
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())
        : DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      '${printerLang.customMessage('printed_at')}: $printAt',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    // Print command
    printEscPos(bytes, generator);
  }

  Future<void> detailShift(String outlet, String startShift, String endShift,
      List<QueueData> queues, int totalCs, Map<String, int> statusCount) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    bytes +=
        generator.setStyles(const PosStyles().copyWith(align: PosAlign.center));
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text(outlet.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size3,
          height: PosTextSize.size2,
        ),
        linesAfter: 2);

    bytes += generator.row([
      PosColumn(text: 'start_shift'.tr, width: 5, styles: const PosStyles()),
      PosColumn(
          text: ': $startShift',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(text: 'end_shift_at'.tr, width: 5, styles: const PosStyles()),
      PosColumn(
          text: ': $endShift',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.emptyLines(1);

    bytes += generator.hr(
      ch: '-',
    );
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'No',
    //       width: 2,
    //       styles: const PosStyles(, align: PosAlign.center)),
    //   PosColumn(
    //       text: 'Queue',
    //       width: 3,
    //       styles: const PosStyles(, align: PosAlign.center)),
    //   PosColumn(
    //       text: 'Pax',
    //       width: 3,
    //       styles: const PosStyles(, align: PosAlign.center)),
    //   PosColumn(
    //       text: 'Status',
    //       width: 4,
    //       styles: const PosStyles(, align: PosAlign.center)),
    // ]);
    // bytes += generator.hr();
    // for (int i = 0; i < queues.length; i++) {
    //   var queue = queues[i];
    //   bytes += generator.row([
    //     PosColumn(
    //         text: (i + 1).toString(),
    //         width: 2,
    //         styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(
    //         text: queue.queueNumber,
    //         width: 3,
    //         styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(
    //         text: queue.queueQty.toString(),
    //         width: 3,
    //         styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(
    //         text: queue.status.label,
    //         width: 4,
    //         styles: const PosStyles(align: PosAlign.center)),
    //   ]);
    // }

    statusCount.forEach((status, count) {
      bytes += generator.row([
        PosColumn(text: status, width: 6, styles: const PosStyles()),
        PosColumn(
            text: count.toString(),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    });
    bytes += generator.row([
      PosColumn(
          text: 'Total ${'queue'.tr}', width: 6, styles: const PosStyles()),
      PosColumn(
          text: queues.length.toString(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Total Pax', width: 6, styles: const PosStyles()),
      PosColumn(
          text: totalCs.toString(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    bytes += generator.text(
      'BISA Online Queue System V.${VersionApp.version}',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      '${'printed_at'.tr}: $printAt',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    printEscPos(bytes, generator);
  }

  Future<void> printEndDetailShift(
    String outlet,
    String startShift,
    String endShift,
    ShiftDetails? shiftDetails,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    bytes +=
        generator.setStyles(const PosStyles().copyWith(align: PosAlign.center));
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text(
      outlet.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
      ),
      linesAfter: 2,
    );

    // Start & End Shift
    bytes += generator.row([
      PosColumn(text: 'start_shift'.tr, width: 5, styles: const PosStyles()),
      PosColumn(
        text: ': $startShift',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'end_shift_at'.tr, width: 5, styles: const PosStyles()),
      PosColumn(
        text: ': $endShift',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.emptyLines(1);

    // Queue data
    if (shiftDetails?.queues != null) {
      bytes += generator.row([
        PosColumn(text: 'queue_count'.tr, width: 5, styles: const PosStyles()),
        PosColumn(
          text: ': ${shiftDetails!.queues!.count} ${'queue'.tr}',
          width: 7,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Total ${'queue'.tr}', width: 5, styles: const PosStyles()),
        PosColumn(
          text: ': ${shiftDetails.queues!.total} Pax',
          width: 7,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.emptyLines(1);

    // Status section
    bytes += generator.text('shift_overview'.tr, styles: const PosStyles());
    for (var status in shiftDetails?.status ?? []) {
      // Baris 1: Status + Count
      bytes += generator.row([
        PosColumn(
          text: status.label ?? '',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${'count'.tr}: ${status.count}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      // Baris 2: Kosong (untuk label) + Total
      bytes += generator.row([
        PosColumn(
          text: '', // kolom kosong
          width: 7,
        ),
        PosColumn(
          text: 'Total: ${status.total}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '=', linesAfter: 1);

    bytes += generator.text(
      'BISA Online Queue System V.${VersionApp.version}',
      styles: const PosStyles(align: PosAlign.center),
    );

    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      '${'printed_at'.tr} $printAt',
      styles: const PosStyles(align: PosAlign.center),
    );

    printEscPos(bytes, generator);
  }

  Future<void> printEscPos(List<int> bytes, Generator generator) async {
    try {
      var bluetoothPrinter = selectedPrinter.value;
      switch (bluetoothPrinter.typePrinter) {
        case PrinterType.usb:
          bytes += generator.feed(2);
          bytes += generator.cut();
          await printerManager.connect(
              type: bluetoothPrinter.typePrinter,
              model: UsbPrinterInput(
                  name: bluetoothPrinter.deviceName,
                  productId: bluetoothPrinter.productId,
                  vendorId: bluetoothPrinter.vendorId));
          pendingTask = null;
          break;
        case PrinterType.bluetooth:
          bytes += generator.cut();
          await printerManager.connect(
              type: bluetoothPrinter.typePrinter,
              model: BluetoothPrinterInput(
                  name: bluetoothPrinter.deviceName,
                  address: bluetoothPrinter.address!,
                  isBle: bluetoothPrinter.isBle ?? false,
                  autoConnect: reconnect.value));
          pendingTask = null;
          if (Platform.isAndroid) pendingTask = bytes;
          break;
        case PrinterType.network:
          bytes += generator.feed(2);
          bytes += generator.cut();
          await printerManager.connect(
              type: bluetoothPrinter.typePrinter,
              model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
          break;
      }
      if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
          Platform.isAndroid) {
        if (currentStatus.value == BTStatus.connected) {
          printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
          pendingTask = null;
        }
      } else {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      }
    } catch (e) {
      AppDialog.showToastInfo(
        title: 'printer_error'.tr,
        desc: 'printer_error_desc'.tr,
        func: () async {
          Get.back();
          await _logApp.writeLog(" Printer is not selected ${e.toString()}");
        },
      );
    }
  }

  Future<void> connectDevice() async {
    isConnected.value = false;
    switch (selectedPrinter.value.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter.value.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter.value.deviceName,
                productId: selectedPrinter.value.productId,
                vendorId: selectedPrinter.value.vendorId));
        isConnected.value = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter.value.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter.value.deviceName,
                address: selectedPrinter.value.address!,
                isBle: selectedPrinter.value.isBle ?? false,
                autoConnect: reconnect.value));
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter.value.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter.value.address!));
        isConnected.value = true;
        break;
    }
    await saveSettingStorage();
  }
}
