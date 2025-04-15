import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/home_controller.dart';
import 'package:pickup_queue_system/data/model/test_model.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/widget/app_text.dart';
import 'package:pickup_queue_system/utills/widget/custom_chip.dart';
import 'package:pickup_queue_system/utills/widget/custom_keyboard.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildQueueCreationPanel(context),
          _buildQueueListPanel(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: AppColors.white,
      leading: Image.asset('assets/images/sushi-tei.png'),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppText(
            text: 'Sushi Tei Teuku Daud',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: AppColors.black,
          ),
          SizedBox(height: 2),
          AppText(
            text: 'Shift : 24/01/2024 08:00 - ',
            fontWeight: FontWeight.normal,
            fontSize: 18,
            color: AppColors.blackCalm,
          ),
        ],
      ),
      actions: [
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            controller.openCustomerWindow();
          },
          icon: const Icon(Icons.tv, size: 30, color: AppColors.black),
          label: const AppText(
            text: 'Tampilkan Layar\nAntrian',
            textAlign: TextAlign.center,
            maxLines: 2,
            fontWeight: FontWeight.w600,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 30),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings, size: 30, color: AppColors.black),
        ),
        const SizedBox(width: 16),
      ],
      centerTitle: false,
    );
  }

  Widget _buildQueueCreationPanel(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 320,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Buat Antrian',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => _buildCustomTextField(
                          context: context,
                          label: 'Kode Antrian',
                          value: controller.queue.value,
                          onTap: () => _showKeyboard(context, 'queue'),
                        )),
                    const SizedBox(height: 26),
                    Obx(() => _buildCustomTextField(
                          context: context,
                          label: 'Keterangan',
                          value: controller.description.value,
                          minLines: 3,
                          maxLines: 4,
                          onTap: () => _showKeyboard(context, 'description'),
                        )),
                    const SizedBox(height: 24),
                    _buildCreateQueueButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueListPanel(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            _buildFilterRow(),
            const SizedBox(height: 16),
            _buildQueueListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                children: controller.statusOptions.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomChip(
                      label: status,
                      isSelected: controller.selectedStatus.value == status,
                      onSelected: () =>
                          controller.selectedStatus.value = status,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => _buildSearchField()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      readOnly: true,
      onTap: () => _showKeyboard(Get.context!, 'search'),
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Get.theme.colorScheme.outline),
        ),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
      ),
      controller: TextEditingController(text: controller.searchQuery.value),
    );
  }

  Widget _buildQueueListView() {
    return Expanded(
      child: Obx(() {
        if (controller.filteredList.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        return ListView.builder(
          itemCount: controller.filteredList.length,
          itemBuilder: (context, index) {
            final data = controller.filteredList[index];
            return _buildQueueCard(data);
          },
        );
      }),
    );
  }

  Widget _buildQueueCard(DataModel data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQueueInfoSection(data),
              _buildQueueActionSection(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueInfoSection(DataModel data) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fastfood, color: AppColors.maroon, size: 40),
              const SizedBox(width: 8),
              AppText(
                  text: data.title, fontSize: 24, fontWeight: FontWeight.bold),
              const SizedBox(width: 12),
              _buildStatusBadge(data.status),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
              text: data.description,
              fontSize: 16,
              fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          _buildCreationTime(data.date),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusTextColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: status,
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCreationTime(DateTime date) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        AppText(
          text: 'Dibuat: $date',
          color: Colors.grey,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _buildQueueActionSection(DataModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildCallButton(),
            const SizedBox(height: 12),
            _buildStatusDropdown(data.status),
          ],
        ),
        _buildQueueOptionsMenu(),
      ],
    );
  }

  Widget _buildCallButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.volume_up, size: 20, color: AppColors.white),
      label: const AppText(
        text: 'Panggil',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.white,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
    );
  }

  Widget _buildStatusDropdown(String currentStatus) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          iconSize: 24,
          elevation: 8,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 14,
            color: _getStatusTextColor(currentStatus),
            fontWeight: FontWeight.w500,
          ),
          items: [
            _buildDropdownItem('Pending', Icons.access_time),
            _buildDropdownItem('Processing', Icons.autorenew),
            _buildDropdownItem('Completed', Icons.check_circle),
            _buildDropdownItem('Rejected', Icons.cancel),
            _buildDropdownItem('On Hold', Icons.pause),
          ],
          onChanged: (value) {
            if (value != null) {
              // Handle status change
            }
          },
        ),
      ),
    );
  }

  Widget _buildQueueOptionsMenu() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'reprint',
          child: AppText(text: 'Reprint', fontSize: 16),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: AppText(text: 'Edit', fontSize: 16),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          // Handle edit action
        } else if (value == 'delete') {
          // Handle delete action
        }
      },
    );
  }

  Widget _buildCreateQueueButton() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        label: const AppText(
          text: 'Buat Antrian',
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        icon: const Icon(
          Icons.person_add_alt_1,
          color: AppColors.white,
          size: 26,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  void _showKeyboard(BuildContext context, String field) {
    controller.setActiveField(field);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: 400,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: CustomKeyboard(
            onTextInput: controller.addCharacter,
            onBackspace: controller.backspace,
            onDone: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: _getStatusTextColor(value)),
          const SizedBox(width: 8),
          AppText(text: value, fontSize: 16, color: _getStatusTextColor(value)),
        ],
      ),
    );
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'On Hold':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCustomTextField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      readOnly: true,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1,
          wordSpacing: 1,
          color: AppColors.blackCalm,
        ),
        alignLabelWithHint: maxLines > 1,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
      onTap: onTap,
    );
  }
}
