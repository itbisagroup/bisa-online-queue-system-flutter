import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:pickup_queue_system/controller/home_controller.dart';
import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/time_ago_helper.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!controller.isShiftOpened.value) {
          return _buildNoShiftView();
        } else {
          return Row(
            children: [
              _buildQueueCreationPanel(context),
              _buildQueueListPanel(context),
            ],
          );
        }
      }),
    );
  }

  Widget _buildNoShiftView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const AppText(
            text: 'Shift Belum Dibuka',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          const AppText(
            text: 'Silahkan buka shift untuk memulai Antrean',
            fontSize: 16,
            color: AppColors.blackCalm,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await controller.createNewShift();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const AppText(
              text: 'Buka Shift',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: AppColors.white,
      leading: Obx(
        () => controller.isLoading.value
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Image.file(
                  File(controller.outlet.value!.logo),
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(
            () => AppText(
              text: controller.isLoading.value
                  ? ''
                  : controller.outlet.value!.fullName,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => AppText(
              text: controller.isLoading.value || controller.shift.value == null
                  ? ''
                  : 'Shift : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(controller.shift.value!.shiftDate).toLocal())}',
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: AppColors.blackCalm,
            ),
          ),
        ],
      ),
      actions: [
        const SizedBox(width: 8),
        Obx(
          () => Visibility(
            visible: controller.isShiftOpened.value &&
                !controller.isLoading.value &&
                !controller.isCustomerScreenActive.value,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.openCustomerWindow();
              },
              icon: const Icon(Icons.tv, size: 30, color: AppColors.black),
              label: const AppText(
                text: 'Tampilkan Layar\nAntrean',
                textAlign: TextAlign.center,
                maxLines: 2,
                fontWeight: FontWeight.w600,
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
        Obx(
          () => Visibility(
            visible:
                controller.isShiftOpened.value && !controller.isLoading.value,
            child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.closeCurrentShift();
                },
                icon: const Icon(Icons.settings_backup_restore_sharp,
                    size: 20, color: AppColors.white),
                label: const AppText(
                  text: 'Tutup Shift',
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                )),
          ),
        ),
        const SizedBox(width: 30),
        PopupMenuButton(
          icon: const Icon(Icons.settings, size: 30, color: AppColors.black),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'config',
              child: Row(
                children: [
                  Icon(Icons.settings_applications_rounded),
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: AppText(
                      text: 'Konfigurasi',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'printer',
              child: Row(
                children: [
                  Icon(Icons.print),
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: AppText(
                      text: 'Printer',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'shift',
              child: Row(
                children: [
                  Icon(Icons.access_time),
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: AppText(
                      text: 'Shift',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'config') {
              Get.toNamed(Routes.config);
            } else if (value == 'shift') {
              Get.toNamed(Routes.shift);
            } else if (value == 'printer') {
              Get.toNamed(Routes.printer);
            }
          },
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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const AppText(
                        text: 'Buat Antrean',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                        context: context,
                        label: 'Kode Antrean',
                        value: controller.queueInput.value,
                        onTap: () => _showKeyboard(context, 'queue', false, () {
                          Navigator.pop(context);
                        }),
                      ),
                      const SizedBox(height: 26),
                      _buildCustomTextField(
                        context: context,
                        label: 'Keterangan',
                        value: controller.descriptionInput.value,
                        minLines: 3,
                        maxLines: 4,
                        onTap: () =>
                            _showKeyboard(context, 'description', true, () {
                          Navigator.pop(context);
                        }),
                        showHelperNotes: true, // Show helper notes
                      ),
                      const SizedBox(height: 24),
                      _buildCreateQueueButton(),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FittedBox(
                          child: AppText(
                            text: 'Statistik Antrean',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                color: AppColors.maroon, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              flex: 2,
                              child: AppText(
                                text: 'Total Antrean',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                ': ${controller.totalQueues.value}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        _buildStatusStats(),
                        const SizedBox(height: 16),
                         Row(
                           children: [
                             const AppText(
                              text: 'Status Sinkronisasi : ',
                              fontSize: 8,
                                               
                                                     ),
                             AppText(
                              text: controller.syncStatus.value,
                              fontSize: 8,
                                               
                                                     ),
                           ],
                         ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: QueueStatus.values.map((status) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: AppText(
                  text: status.description,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ': ${controller.queueCounts[status] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQueueListPanel(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Visibility(
        visible: controller.totalQueues.value > 0,
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
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CustomChip(
                    label: 'Semua',
                    isSelected: controller.selectedStatus.value == null,
                    onSelected: () => {
                      controller.selectedStatus.value = null,
                      controller.fetchQueues(pageNumber: 1),
                    },
                  ),
                ),
                // Menambahkan semua opsi status dari enum QueueStatus
                ...QueueStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomChip(
                        label: status.description,
                        isSelected: controller.selectedStatus.value == status,
                        onSelected: () => {
                              controller.selectedStatus.value = status,
                              controller.fetchQueues(pageNumber: 1),
                            }),
                  );
                }),
              ],
            ),
          ),
          Expanded(child: _buildSearchField()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      readOnly: true,
      onTap: () => _showKeyboard(Get.context!, 'search', true, () {
        controller.searchQuery.value = controller.searchQuery.value.trim();
        controller.fetchQueues(pageNumber: 1);
        Navigator.pop(Get.context!);
      }),
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
    return Obx(() {
      if (controller.queues.isEmpty) {
        return const Expanded(child: Center(child: Text('Belum ada Antrean')));
      }
      return Expanded(
        flex: 4,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: controller.queues.length,
                  itemBuilder: (context, index) {
                    final queue = controller.queues[index];
                    return _buildQueueCard(queue);
                  }),
            ),
            Obx(() {
              return NumberPagination(
                onPageChanged: (int pageNumber) {
                  controller.fetchQueues(pageNumber: pageNumber);
                },
                totalPages: controller.totalFetchQueues.value,
                currentPage: controller.selectedPageNumber.value,
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildQueueCard(QueueModel data) {
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

  Widget _buildQueueInfoSection(QueueModel data) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fastfood, color: AppColors.maroon, size: 40),
              const SizedBox(width: 8),
              AppText(
                  text: data.queueNumber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
              const SizedBox(width: 12),
              _buildStatusBadge(data.status),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
              text: data.description ?? '-',
              fontSize: 16,
              fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          _buildCreationTime(DateTime.parse(data.createdAt)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: QueueStatus.fromValue(status).color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: QueueStatus.fromValue(status).description,
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
          text: TimeAgoHelper.timeAgo(date),
          color: Colors.grey,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _buildQueueActionSection(QueueModel data) {
    return Visibility(
      visible: data.status == QueueStatus.waiting.value ||
          data.status == QueueStatus.calling.value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _buildCallButton(data),
              const SizedBox(height: 12),
              _chengeStatusButton(data),
            ],
          ),
          _buildQueueOptionsMenu(data),
        ],
      ),
    );
  }

  void showEditQueueDialog(QueueModel queue) {
    controller.queueUpdateController.text = queue.queueNumber;
    controller.descriptionUpdateController.text = queue.description ?? '';

    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Antrian'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: controller.queueUpdateController,
                    readOnly: true,
                    onTap: () =>
                        _showKeyboard(Get.context!, 'queueUpdate', false, () {
                      Navigator.pop(Get.context!);
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Nomor Antrian',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor antrian harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    onTap: () =>
                        _showKeyboard(context, 'descriptionUpdate', true, () {
                      Navigator.pop(context);
                    }),
                    controller: controller.descriptionUpdateController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      setState(() => errorMessage = null);
                      await controller.updateQueueDetails(
                        queueId: queue.id!,
                        newQueueNumber:
                            controller.queueUpdateController.text.trim(),
                        newDescription:
                            controller.descriptionUpdateController.text.trim(),
                      );
                      Get.back();
                    } catch (e) {
                      setState(
                          () => errorMessage = 'Gagal memperbarui antrian: $e');
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCallButton(QueueModel data) {
    return Obx(() {
      final isCalling = controller.callingQueueIds.contains(data.id);

      return ElevatedButton.icon(
        icon: isCalling
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.volume_up, size: 20, color: AppColors.white),
        label: AppText(
          text: isCalling ? 'Memanggil...' : 'Panggil',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isCalling
            ? null
            : () async {
                controller.callingQueueIds.add(data.id!);
                await controller.callQueue(
                    queueId: data.id!, queueNumber: data.queueNumber);
                await Future.delayed(const Duration(seconds: 30));
                controller.callingQueueIds.remove(data.id);
              },
      );
    });
  }

  Widget _chengeStatusButton(QueueModel data) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final newStatus = switch (value) {
          'served' => QueueStatus.completed,
          'unknown' => QueueStatus.none,
          _ => QueueStatus.none,
        };

        await controller.changeQueueStatus(
          queueId: data.id!,
          newStatus: newStatus,
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'served',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.confirm, size: 20),
              SizedBox(width: 12),
              AppText(
                text: 'Selesai',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.confirm,
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'unknown',
          child: Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.red, size: 20),
              SizedBox(width: 12),
              AppText(
                text: 'Tidak Diketahui',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.red,
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_drop_down, color: Colors.blue),
            SizedBox(width: 4),
            AppText(
              text: 'Ubah Status',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueOptionsMenu(QueueModel data) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: AppText(text: 'Edit', fontSize: 16),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          showEditQueueDialog(data);
        }
      },
    );
  }

  Widget _buildCreateQueueButton() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.queueInput.value.isEmpty
              ? null
              : () async {
                  await controller.createNewQueue();
                },
          label: const AppText(
            text: 'Buat Antrean',
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
      ),
    );
  }

  void _showKeyboard(BuildContext context, String field, bool visibleSpace,
      VoidCallback onDone) {
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
            onDone: onDone,
            visibleSpace: visibleSpace,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    int minLines = 1,
    int maxLines = 1,
    bool showHelperNotes = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
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
// Hapus suffixIcon
          ),
          controller: TextEditingController(text: value),
          onTap: onTap,
        ),
        if (showHelperNotes)
          Obx(() => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...controller.helperNotes.map(
                      (note) => InkWell(
                        onTap: () {
                          controller.selectedNote.value = note.name;
                          controller.descriptionInput.value = note.name;
                        },
                        child: Chip(
                          label: Text(note.name),
                          onDeleted: () => controller.deleteNote(note.id!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          backgroundColor: controller.selectedNote.value ==
                                  note.name
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : null,
                        ),
                      ),
                    ),
                    ActionChip(
                      label: const Text('Pilihan Lain'),
                      avatar: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddNoteDialog(context),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Otomatis Catatan'),
        content: TextField(
          controller: controller.newHelpperNoteController,
          onTap: () => _showKeyboard(context, 'newHelpperNote', true, () {
            Navigator.pop(context);
          }),
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.newHelpperNoteController.text.isNotEmpty) {
                controller.addNewNote(
                  controller.newHelpperNoteController.text.trim(),
                );
                controller.newHelpperNoteController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
