import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';

import 'package:printing/printing.dart';
import 'package:queue_system/widget/app_text.dart';

class PrinterSettingView extends GetView<AdminController> {
  const PrinterSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          text: 'Print Preview',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        centerTitle: true,
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        dynamicLayout: true,
        build: (format) => controller.generatePdf(format),
      ),
    );
  }
}
