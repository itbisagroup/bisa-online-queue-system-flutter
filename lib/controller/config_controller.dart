import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/home_controller.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:win32audio/win32audio.dart';
import 'package:http/http.dart' as http;

class ConfigController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Rx<Outlet?> outlet = Rx<Outlet?>(null);
  final homeController = Get.find<HomeController>();
  final RxBool isLoading = false.obs;
  final RxString tempLogoPath = ''.obs;

  // Temporary fields for editing
  final fullNameController = TextEditingController();
  final codeNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final urlController = TextEditingController();
  final secretKeyController = TextEditingController();

  // Audio Device Configuration (Simplified)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Rx<AudioDevice?> selectedDevice = Rx<AudioDevice?>(null);
  final RxList<AudioDevice> audioDevices = <AudioDevice>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchOutlet();
    await loadAudioDevices();
    await getCronConfig();
  }

  Future<void> fetchOutlet() async {
    try {
      isLoading.value = true;
      outlet.value = await _databaseHelper.getFirstOutlet();

      if (outlet.value != null) {
        tempLogoPath.value = outlet.value!.logo;
        fullNameController.text = outlet.value!.fullName;
        codeNameController.text = outlet.value!.codeName ?? '';
        addressController.text = outlet.value!.address ?? '';
        phoneNumberController.text = outlet.value!.phoneNumber ?? '';
      } else {
        // Initialize empty outlet if none exists
        outlet.value = Outlet(
          fullName: '',
          logo: '',
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load outlet: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      tempLogoPath.value = image.path;
    }
  }

  Future<void> saveOutlet() async {
    final fullName = fullNameController.text.trim();
    final logo = tempLogoPath.value.trim();
    final codeName = codeNameController.text.trim();
    final address = addressController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();

    if (fullName.isEmpty || logo.isEmpty) {
      Get.snackbar('Error', 'Full Name and Logo are required');
      return;
    }

    isLoading.value = true;

    try {
      final db = await _databaseHelper.database;

      // Perbarui data outlet dari input
      outlet.value = outlet.value!.copyWith(
        fullName: fullName,
        logo: logo,
        codeName: codeName,
        address: address,
        phoneNumber: phoneNumber,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await db.update(
        'Outlet',
        outlet.value!.toMap(),
        where: 'id = ?',
        whereArgs: [outlet.value!.id],
      );

      await fetchOutlet();
      await homeController.fetchOutlet();
      if (homeController.isCustomerScreenActive.value) {
        await homeController.updateOutletDataToSecondaryWindow();
      }

      Get.snackbar(
        'Success',
        'Outlet saved successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save outlet: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAudioDevices() async {
    try {
      isLoading.value = true;
      audioDevices.value =
          await Audio.enumDevices(AudioDeviceType.output) ?? [];

      // Load saved device ID
      final savedDeviceId =
          await _secureStorage.read(key: 'selected_audio_device');
      if (savedDeviceId != null) {
        selectedDevice.value = audioDevices
            .firstWhereOrNull((device) => device.id == savedDeviceId);
      }

      // If no saved device or not found, use system default
      if (selectedDevice.value == null && audioDevices.isNotEmpty) {
        selectedDevice.value =
            await Audio.getDefaultDevice(AudioDeviceType.output);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load audio devices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAudioDevice(AudioDevice device) async {
    try {
      isLoading.value = true;
      await Audio.setDefaultDevice(device.id);
      selectedDevice.value = device;
      await _secureStorage.write(
          key: 'selected_audio_device', value: device.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to select audio device: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCronConfig() async {
    isLoading.value = true;
    final url = await _secureStorage.read(key: 'cron_url');
    final secretKey = await _secureStorage.read(key: 'cron_secret_key');
    if (url != null) {
      urlController.text = url;
    }
    if (secretKey != null) {
      secretKeyController.text = secretKey;
    }
    isLoading.value = false;
  }

  Future<void> saveCronConfig() async {
    final url = urlController.text.trim();
    final secretKey = secretKeyController.text.trim();

    if (url.isEmpty || secretKey.isEmpty) {
      Get.snackbar('Error', 'URL and Secret Key are required');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': secretKey,
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      // Validasi hanya jika response memiliki pesan "Shifts must be an array"
      if (data is Map &&
          data['messages'] is Map &&
          data['messages']['shifts'] == 'Shifts must be an array') {
        await _secureStorage.write(key: 'cron_url', value: url);
        await _secureStorage.write(key: 'cron_secret_key', value: secretKey);

        Get.snackbar(
          'Success',
          'Cron configuration saved successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Validation failed: response is not as expected.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to test cron configuration: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    codeNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
