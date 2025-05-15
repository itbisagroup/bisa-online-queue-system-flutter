import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/config_controller.dart';

class ConfigScreen extends GetView<ConfigController> {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ConfigController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildOutletConfigSection(),
                    _buildAudioConfigSection(),
                    _buildCronConfigSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOutletConfigSection() {
    return _buildSectionCard(
      title: 'Outlet Configuration',
      child: Column(
        children: [
          _buildLogoField(),
          const SizedBox(height: 20),
          _buildFullNameField(),
          const SizedBox(height: 20),
          _buildCodeNameField(),
          const SizedBox(height: 20),
          _buildAddressField(),
          const SizedBox(height: 20),
          _buildPhoneNumberField(),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildCronConfigSection() {
    return _buildSectionCard(
      title: 'Cron Configuration',
      child: Column(
        children: [
          _buildUrlLiveNameField(),
          const SizedBox(height: 20),
          _buildSecretKeyNameField(),
          const SizedBox(height: 30),
          _buildCronSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAudioConfigSection() {
    return _buildSectionCard(
      title: 'Audio Configuration',
      child: Column(
        children: [
          const Text(
            'Select Output Device',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (controller.selectedDevice.value != null)
            Text(
              'Current: ${controller.selectedDevice.value!.name}',
              style: const TextStyle(fontSize: 16),
            ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: controller.audioDevices.length,
              itemBuilder: (context, index) {
                final device = controller.audioDevices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(device.name),
                    trailing: Icon(
                      Icons.check_circle,
                      color: controller.selectedDevice.value?.id == device.id
                          ? Colors.green
                          : Colors.transparent,
                    ),
                    onTap: () => controller.selectAudioDevice(device),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Set max width
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoField() {
    return Column(
      children: [
        if (controller.tempLogoPath.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(controller.tempLogoPath.value),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        else if (controller.outlet.value?.logo.isNotEmpty ?? false)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(controller.outlet.value!.logo),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: controller.pickImage,
          child: const Text('Select Logo'),
        ),
        if (controller.tempLogoPath.isEmpty &&
            (controller.outlet.value?.logo.isEmpty ?? true))
          const Text(
            'Logo is required',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: controller.fullNameController,
      decoration: const InputDecoration(
        labelText: 'Full Name*',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildUrlLiveNameField() {
    return TextFormField(
      controller: controller.urlController,
      decoration: const InputDecoration(
        labelText: 'URL Live Name*',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSecretKeyNameField() {
    return TextFormField(
      controller: controller.secretKeyController,
      obscureText: true,
      decoration: const InputDecoration(
        
        labelText: 'Secret Key*',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCodeNameField() {
    return TextFormField(
      controller: controller.codeNameController,
      decoration: const InputDecoration(
        labelText: 'Code Name',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: controller.addressController,
      decoration: const InputDecoration(
        labelText: 'Address',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: controller.phoneNumberController,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
        ),
        onPressed: controller.isLoading.value ? null : controller.saveOutlet,
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildCronSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
        ),
        onPressed: () async {
          await controller.saveCronConfig();
        },
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
