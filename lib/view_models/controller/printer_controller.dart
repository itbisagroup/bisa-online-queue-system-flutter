import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:queue_system/models/printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/models/shift.dart';
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

  Future<void> printReceiveTest(
    BuildContext context,
  ) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('Printer Queue System',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TEST PRINT SUCCESS',
        styles: const PosStyles(align: PosAlign.center));

    printEscPos(bytes, generator);
  }

  Future<void> printQueue(String title, String qrCode, String queueNumber,
      String cancelCode) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    // Title Section
    bytes += generator.text(title,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size3,
          height: PosTextSize.size2,
        ),
        linesAfter: 2);

    // Queue Number Section
    bytes += generator.text(
      'Queue Number',
      styles: const PosStyles(
        align: PosAlign.center,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(queueNumber,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size4,
          height: PosTextSize.size3,
        ),
        linesAfter: 1);

    // QR Code Section
    bytes += generator.text(
      'Scan the QR Code below to update your queue.',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.qrcode(
      qrCode,
      size: QRSize.size8,
      align: PosAlign.center,
    );

    // Separator Line
    bytes += generator.emptyLines(1);

    // Cancel Code Section
    bytes += generator.text(
      'To cancel your queue, use the code below:',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.text(cancelCode,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size3,
        ),
        linesAfter: 1);

    // Footer Line

    bytes += generator.text('Thank you for your patience!',
        styles: const PosStyles(
          align: PosAlign.center,
      
        ),
        linesAfter: 2);

    bytes += generator.text(
      'BISA Online Queue System V.0.2.1 (alpha-test)',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      'Printed at: $printAt',
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
    bytes += generator.text(outlet,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size3,
          height: PosTextSize.size2,
        ),
        linesAfter: 2);

    bytes += generator.row([
      PosColumn(text: 'Start Shift', width: 5, styles: const PosStyles()),
      PosColumn(
          text: ': $startShift',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End Shift', width: 5, styles: const PosStyles()),
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
      PosColumn(text: 'Total Queues', width: 6, styles: const PosStyles()),
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
      'BISA Online Queue System V.0.2.1 (alpha-test)',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
     bytes += generator.text(
      'Printed at: $printAt',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
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
        default:
      }
      if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
          Platform.isAndroid) {
        if (currentStatus == BTStatus.connected) {
          printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
          pendingTask = null;
        }
      } else {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      }
    } catch (e) {
      AppDialog.showToastInfo(
        title: 'Printer Error!',
        desc:
            'Printer is not selected. Please select printer first in setting menu',
        func: () async {
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
      default:
    }
    await saveSettingStorage();
  }
}
