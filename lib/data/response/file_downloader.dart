import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/widget/app_dialog.dart';

class FileDownloader {
  Future<void> downloadFiles(List<String?> ids, List<String?> names) async {
    // Pastikan ids dan names memiliki panjang yang sama
    if (ids.length != names.length) {
      await AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'ids_names_mismatch'.tr, // Pesan jika panjang daftar tidak cocok
        func: () {},
      );
      return;
    }

    const storage = FlutterSecureStorage();
    final key = await storage.read(key: 'key');
    final envPath = await storage.read(key: 'env_path');

    // Pastikan envPath tidak null
    if (envPath == null || envPath.isEmpty) {
      await AppDialog.showToastError(
        title: 'failed'.tr,
        desc: 'env_path_not_set'.tr,
        func: () {},
      );
      return;
    }

    String directoryPath = envPath;
    Directory directory = Directory(directoryPath);

    // Periksa apakah direktori tujuan ada
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Tambahkan headers untuk request HTTP
    Map<String, String> headers = {
      'User-Agent': 'Flutter File Downloader/1.0',
      'Accept': 'application/octet-stream',
      'Authorization': 'Bearer $key',
    };

    // Iterasi untuk mengunduh setiap file
    for (int i = 0; i < ids.length; i++) {
      String? id = ids[i];
      String? name = names[i];

      // Periksa jika id atau name null
      if (id == null || id.isEmpty || name == null || name.isEmpty) {
        await AppDialog.showToastInfo(
          title: 'info'.tr,
          desc: 'invalid_id_or_name'
              .tr, // Pesan jika id atau name null atau kosong
          func: () {},
        );
        continue; // Lanjutkan ke id berikutnya
      }

      String filePath = "$directoryPath\\$name";
      File file = File(filePath);

      // Periksa jika file sudah ada
      if (file.existsSync()) {
        await AppDialog.showToastInfo(
          title: 'info'.tr,
          desc: 'file_already_exists'.tr + filePath,
          func: () {},
        );
        continue; // Lanjutkan ke file berikutnya
      }

      try {
        AppDialog.showDialogLoading();
        // Mengunduh file dengan timeout
        final response = await http
            .get(
              Uri.parse('${BaseApiServices.adsEndpoint}/$id/downloads'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 15)); // Timeout 15 detik

        if (response.statusCode == 200) {
          Get.back();
          // Menulis data file
          await file.writeAsBytes(response.bodyBytes);
          await AppDialog.showToastSuccess(
            title: 'success'.tr,
            desc: 'video_downloaded'.tr + filePath,
            func: () async {},
          );
        } else {
          Get.back();
          await LogApp().writeLog(
              'Failed to download video: ${response.statusCode} ${response.body}');
          await AppDialog.showToastError(
            title: 'failed'.tr,
            desc: 'failed_download_video'.tr,
            func: () {},
          );
        }
      } on SocketException {
        Get.back();
        await AppDialog.showToastError(
          title: 'failed'.tr,
          desc: 'network_error'.tr,
          func: () {},
        );
      } on TimeoutException {
        Get.back();
        await AppDialog.showToastError(
          title: 'failed'.tr,
          desc: 'rto_title'.tr,
          func: () {},
        );
      } catch (e) {
        Get.back();
        await LogApp().writeLog(
            'Unknown error while downloading video: ${e.toString()}');
        await AppDialog.showToastError(
          title: 'failed'.tr,
          desc: 'failed_download_video'.tr,
          func: () {},
        );
      }
    }
  }
}
