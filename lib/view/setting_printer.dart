import 'dart:io';

import 'package:queue_system/view_models/controller/printer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterSettingView extends GetView<PrinterController> {
  const PrinterSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PrinterController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Setting'),
        centerTitle: true,
      ),
      body: Obx(
        () => Center(
          child: Container(
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.isConnected.value
                                ? null
                                : () {
                                    controller.connectDevice();
                                  },
                            child: const Text("Connect",
                                textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !controller.isConnected.value
                                ? null
                                : () async {
                                   await const FlutterSecureStorage()
                                        .delete(key: 'typePrinter');
                                    await const FlutterSecureStorage()
                                        .delete(key: 'ipAddress');
                                    await const FlutterSecureStorage()
                                        .delete(key: 'isConnected');
                                    await const FlutterSecureStorage()
                                        .delete(key: 'name');
                                    await const FlutterSecureStorage()
                                        .delete(key: 'productId');
                                    await const FlutterSecureStorage()
                                        .delete(key: 'vendorId');
                                    controller.printerManager.disconnect(
                                        type: controller
                                            .selectedPrinter.value.typePrinter);

                                    controller.isConnected.value = false;
                                    
                                  },
                            child: const Text("Disconnect",
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<PrinterType>(
                    value: controller.defaultPrinterType.value,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.print,
                        size: 24,
                      ),
                      labelText: "Type Printer Device",
                      labelStyle: TextStyle(fontSize: 18.0),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    items: <DropdownMenuItem<PrinterType>>[
                      if (Platform.isAndroid || Platform.isIOS)
                        const DropdownMenuItem(
                          value: PrinterType.bluetooth,
                          child: Text("Bluetooth"),
                        ),
                      if (Platform.isAndroid || Platform.isWindows)
                        const DropdownMenuItem(
                          value: PrinterType.usb,
                          child: Text("Windows"),
                        ),
                      const DropdownMenuItem(
                        value: PrinterType.network,
                        child: Text("Network"),
                      ),
                    ],
                    onChanged: (PrinterType? value) {
                      if (value != null) {
                        controller.defaultPrinterType.value = value;

                        controller.isBle.value = false;
                        controller.isConnected.value = false;
                        controller.scan();
                      }
                    },
                  ),
                  Visibility(
                    visible: controller.defaultPrinterType.value ==
                            PrinterType.bluetooth &&
                        Platform.isAndroid,
                    child: SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.only(bottom: 20.0, left: 20),
                      title: const Text(
                        "This device supports ble (low energy)",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 19.0),
                      ),
                      value: controller.isBle.value,
                      onChanged: (bool? value) {
                        controller.isBle.value = value ?? false;
                        controller.isConnected.value = false;

                        controller.scan();
                      },
                    ),
                  ),
                  Visibility(
                    visible: controller.defaultPrinterType.value ==
                            PrinterType.bluetooth &&
                        Platform.isAndroid,
                    child: SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.only(bottom: 20.0, left: 20),
                      title: const Text(
                        "reconnect",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 19.0),
                      ),
                      value: controller.reconnect.value,
                      onChanged: (bool? value) {
                        controller.reconnect.value = value ?? false;
                      },
                    ),
                  ),
                  Column(
                      children: controller.devices
                          .map(
                            (device) => ListTile(
                              title: Text('${device.deviceName}'),
                              subtitle: Platform.isAndroid &&
                                      controller.defaultPrinterType.value ==
                                          PrinterType.usb
                                  ? null
                                  : Visibility(
                                      visible: !Platform.isWindows,
                                      child: Text("${device.address}")),
                              onTap: () {
                                // do something
                                controller.selectDevice(device);
                              },
                              leading:
                                  ((device.typePrinter == PrinterType.usb &&
                                                  Platform.isWindows
                                              ? device.deviceName ==
                                                  controller.selectedPrinter
                                                      .value.deviceName
                                              : device.vendorId != null &&
                                                  controller.selectedPrinter
                                                          .value.vendorId ==
                                                      device.vendorId) ||
                                          (device.address != null &&
                                              controller.selectedPrinter.value
                                                      .address ==
                                                  device.address))
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null,
                              trailing: OutlinedButton(
                                onPressed: device.deviceName !=
                                        controller
                                            .selectedPrinter.value.deviceName
                                    ? null
                                    : () async {
                                        controller.printReceiveTest(context);
                                      },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 20),
                                  child: Text("Print test ticket",
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          )
                          .toList()),
                  Visibility(
                    visible: controller.defaultPrinterType.value ==
                            PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: controller.ipController,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(
                          label: Text("Ip Address"),
                          prefixIcon: Icon(Icons.wifi, size: 24),
                        ),
                        onChanged: controller.setIpAddress,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: controller.defaultPrinterType.value ==
                            PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: controller.portController,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(
                          label: Text("Port"),
                          prefixIcon: Icon(Icons.numbers, size: 24),
                        ),
                        onChanged: controller.setPort,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: controller.defaultPrinterType.value ==
                            PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: OutlinedButton(
                        onPressed: () async {
                          if (controller.ipController.text.isNotEmpty) {
                            controller
                                .setIpAddress(controller.ipController.text);
                          }
                          controller.printReceiveTest(context);
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                          child: Text("Print test ticket",
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
