import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/model/printer_model.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterController extends GetxController {
  // Printer Type [bluetooth, usb, network]
  var defaultPrinterType = PrinterType.bluetooth.obs;
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

  Future<void> printEndDetailShift(
    String outlet,
    String startShift,
    String endShift,
    int totalQueues,
    int waitingCount,
    int callingCount,
    int completedCount,
    int unknownCount,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    // Set printer configuration
    bytes +=
        generator.setStyles(const PosStyles().copyWith(align: PosAlign.center));
    bytes += generator.setGlobalCodeTable('CP1252');

    // Print header
    bytes += generator.text(outlet.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
        linesAfter: 2);

    // Print shift information
    bytes += generator.row([
      PosColumn(text: 'Start Shift', width: 5, styles: const PosStyles()),
      PosColumn(
        text: ': $startShift',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'End Shift', width: 5, styles: const PosStyles()),
      PosColumn(
        text: ': $endShift',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.emptyLines(1);

    // Print queue summary
    bytes += generator.row([
      PosColumn(text: 'Total Antrean', width: 5, styles: const PosStyles()),
      PosColumn(
        text: ': $totalQueues',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.emptyLines(1);

    // Print status breakdown
    bytes += generator.text('PEMERINCIAN STATUS ANTREAN',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.row([
      PosColumn(text: QueueStatus.waiting.description, width: 4, styles: const PosStyles()),
      PosColumn(
        text: ': $waitingCount',
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: QueueStatus.calling.description, width: 4, styles: const PosStyles()),
      PosColumn(
        text: ': $callingCount',
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: QueueStatus.completed.description, width: 4, styles: const PosStyles()),
      PosColumn(
        text: ': $completedCount',
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: QueueStatus.none.description, width: 4, styles: const PosStyles()),
      PosColumn(
        text: ': $unknownCount',
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    // Print footer with timestamp
    final printAt = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      'Dicetak Pada: $printAt',
      styles: const PosStyles(align: PosAlign.center),
    );

    // Execute printing
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
        if (currentStatus.value == BTStatus.connected) {
          printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
          pendingTask = null;
        }
      } else {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal print detail shift',
        'Printer belum terhubung',
        snackPosition: SnackPosition.TOP,
        backgroundColor:AppColors.grey,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
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
