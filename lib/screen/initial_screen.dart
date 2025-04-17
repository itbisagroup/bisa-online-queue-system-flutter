import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/initial_controller.dart';


class InitialScreen extends GetView<InitialController> {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InitialController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Outlet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => _buildLogoField()),
            const SizedBox(height: 20),
            _buildFullNameField(),
            const SizedBox(height: 20),
            _buildCodeNameField(),
            const SizedBox(height: 20),
            _buildAddressField(),
            const SizedBox(height: 20),
            _buildPhoneNumberField(),
            const SizedBox(height: 30),
            Obx(() => _buildSubmitButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoField() {
    return Column(
      children: [
        if (controller.logoPath.value.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(controller.logoPath.value),
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
        if (controller.logoPath.value.isEmpty)
          const Text(
            'Logo is required',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Full Name*',
        border: OutlineInputBorder(),
      ),
      onChanged: controller.fullName,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter full name';
        }
        return null;
      },
    );
  }

  Widget _buildCodeNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Code Name',
        border: OutlineInputBorder(),
      ),
      onChanged: controller.codeName,
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Address',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: controller.address,
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.phone,
      onChanged: controller.phoneNumber,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: controller.isLoading.value ? null : () async {
          final success = await controller.saveOutlet();
          if (success) {
            Get.back();
            Get.snackbar('Success', 'Outlet saved successfully');
          }
        },
        child: controller.isLoading.value
            ? const CircularProgressIndicator()
            : const Text('Save Outlet'),
      ),
    );
  }
}