import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view/auth_view.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';
import 'package:queue_system/widget/app_error.dart';
import 'package:queue_system/widget/app_loading.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:queue_system/widget/no_internet.dart';
import 'package:sizer/sizer.dart';
import '../data/response/status.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    return Obx(() {
      switch (controller.rxRequestStatus.value) {
        case Status.LOADING:
          return const AppLoading();
        case Status.ERROR:
          if (controller.error.value == 'No Internet') {
            return const NoInternet();
          }
          if (controller.error.value == 'Request Time Out') {
            return const TimeOut();
          }
          if (controller.error.value == 'Unautorized') {
            return const AuthView();
          } else {
            return const TimeOut();
          }

        case Status.COMPLETED:
          return Scaffold(
              backgroundColor: AppColors.white,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: _floatingButton(context),
              appBar: _appBar(context),
              body: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      alignment: WrapAlignment.center,
                      children: controller.pax
                          .map(
                            (tags) => _listQueue(tags, context),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ));
      }
    });
  }

  Stack _listQueue(PaxWithQueue tags, BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 15,
          child: Container(
            width: 180,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tittleQueue(tags),
                _queueNumber(tags),
                _waitingCount(tags),
                _buttonBottom(tags)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonBottom(PaxWithQueue tags) {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: controller.pax[controller.pax.indexOf(tags)].queue!
                          .queueNumber !=
                      "0000"
                  ? controller.pax[controller.pax.indexOf(tags)].queue!
                              .callCount ==
                          controller.branch.value.callCount!
                      ? SizedBox(
                          width: 160,
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              size: 18,
                              color: AppColors.grey,
                            ),
                            label: AppText(
                              text:
                                  'Call (${controller.pax[controller.pax.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(100, 40),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 160,
                          height: 30,
                          child: controller.isButtonDisabled(controller
                                      .pax[controller.pax.indexOf(tags)]
                                      .pax!
                                      .uuid!) ==
                                  false
                              ? ElevatedButton.icon(
                                  onPressed: () => controller.callQueue(
                                      controller
                                          .pax[controller.pax.indexOf(tags)]
                                          .pax!
                                          .uuid!,
                                      controller
                                          .pax[controller.pax.indexOf(tags)]
                                          .queue!
                                          .callCount!),
                                  icon: const Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: AppColors.maroon,
                                  ),
                                  label: AppText(
                                    text: controller
                                                .pax[controller.pax
                                                    .indexOf(tags)]
                                                .queue!
                                                .callCount! >=
                                            1
                                        ? 'Recall (${controller.pax[controller.pax.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})'
                                        : 'Call (${controller.pax[controller.pax.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    minimumSize: const Size(100, 40),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.grey,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    AppText(
                                      text: 'Calling...',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey,
                                    )
                                  ],
                                ),
                        )
                  : SizedBox(
                      width: 160,
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          size: 18,
                          color: AppColors.grey,
                        ),
                        label: AppText(
                          text:
                              'Call (${controller.pax[controller.pax.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(100, 40),
                        ),
                      ),
                    )),
          controller.pax[controller.pax.indexOf(tags)].queue!.queueNumber ==
                  "0000"
              ? controller.isButtonAddDisabled(controller
                          .pax[controller.pax.indexOf(tags)].pax!.uuid!) ==
                      false
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 10),
                      child: SizedBox(
                        width: 160,
                        height: 30,
                        child: ElevatedButton.icon(
                          onPressed: () => controller.newQueue(
                            controller
                                .pax[controller.pax.indexOf(tags)].pax!.uuid!,
                          ),
                          icon: const Icon(
                            Icons.group_add,
                            size: 18,
                            color: AppColors.maroon,
                          ),
                          label: const AppText(
                            text: 'New Queue',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(100, 40),
                          ),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 10),
                      child: SizedBox(
                        width: 160,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.grey,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            AppText(
                              text: 'Creating...',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            )
                          ],
                        ),
                      ),
                    )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      controller.isupdateStatusDisabled(controller
                                  .pax[controller.pax.indexOf(tags)]
                                  .pax!
                                  .uuid!) ==
                              false
                          ? SizedBox(
                              width: 70,
                              child: DropdownButton<String>(
                                focusColor: AppColors.grey,
                                borderRadius: BorderRadius.circular(10),
                                autofocus: true,
                                hint: const AppText(
                                  text: 'Status',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'served',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          color: AppColors.confirm,
                                        ),
                                        SizedBox(width: 5),
                                        AppText(
                                          text: 'Served',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.confirm,
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'void',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_add_disabled_outlined,
                                          color: AppColors.maroon,
                                        ),
                                        SizedBox(width: 5),
                                        AppText(
                                          text: 'Void',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.maroon,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  controller.onItemSelected(
                                      newValue,
                                      controller
                                          .pax[controller.pax.indexOf(tags)]
                                          .queue!
                                          .queueId!,
                                      controller
                                          .pax[controller.pax.indexOf(tags)]
                                          .pax!
                                          .uuid!);
                                },
                                style: const TextStyle(
                                  fontSize: 14, // Ukuran font
                                  color: Colors.black, // Warna teks
                                ),
                                isExpanded: true,
                                iconSize: 24,
                                iconEnabledColor: AppColors.maroon,
                                underline: Container(
                                  height: 2,
                                  color: AppColors.maroon, // Warna underline
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.grey,
                                strokeWidth: 2,
                              ),
                            ),
                      controller.isButtonAddDisabled(controller
                                  .pax[controller.pax.indexOf(tags)]
                                  .pax!
                                  .uuid!) ==
                              false
                          ? SizedBox(
                              width: 42, // Lebar dari tombol
                              height: 40, // Tinggi dari tombol
                              child: ElevatedButton(
                                onPressed: () => controller.newQueue(
                                  controller.pax[controller.pax.indexOf(tags)]
                                      .pax!.uuid!,
                                ),
                                child: const Icon(
                                  Icons.group_add,
                                  size: 18,
                                  color: AppColors.maroon,
                                ), // Ikon dengan ukuran kecil

                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8), // Padding kecil
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.grey,
                                strokeWidth: 2,
                              ),
                            ),
                    ])
        ],
      ),
    );
  }

  Widget _waitingCount(PaxWithQueue tags) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppText(
            text: 'Waiting : ',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          AppText(
            text: controller
                .pax[controller.pax.indexOf(tags)].queue!.waitingCount!
                .toString(),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.maroon,
          ),
        ],
      ),
    );
  }

  Widget _queueNumber(PaxWithQueue tags) {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
                text:
                    controller.pax[controller.pax.indexOf(tags)].pax!.notation!,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon),
            AppText(
              text: controller
                  .pax[controller.pax.indexOf(tags)].queue!.queueNumber!
                  .substring(1),
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tittleQueue(PaxWithQueue tags) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.person,
            size: 18,
          ),
          AppText(
              text: controller.pax[controller.pax.indexOf(tags)].pax!.variety!,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.blackCalm),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      title: TitleText(
        text: controller.branch.value.fullName!,
        fontSize: 12.sp,
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (String value) {
              if (value == '1') {
                controller.custommerScreen();
              }
              if (value == '4') {
                controller.setRealtime();
                Get.offAllNamed(Routes.home);
              } else if (value == '2') {
                Get.toNamed(Routes.printer);
              } else if (value == '3') {
                controller.resetQueue();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '4',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Refresh',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: '1',
                child: Row(
                  children: [
                    Icon(Icons.add_to_queue),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Customer Screen',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: '2',
                child: Row(
                  children: [
                    Icon(Icons.print_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Printer Preview',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: '3',
                child: Row(
                  children: [
                    Icon(Icons.restore_page),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Reset',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _floatingButton(BuildContext context) {
    return SizedBox(
      height: 30,
      child: FloatingActionButton.extended(
          backgroundColor: AppColors.maroon,
          label: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.paste,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              AppText(
                text: 'Details',
                maxLines: 1,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                textAlign: TextAlign.end,
              ),
            ],
          ),
          onPressed: () {
            controller.apiQueueDetailList(controller.selectedPageNumber.value);
            showModalBottomSheet(
                useRootNavigator: false,
                isScrollControlled: true,
                useSafeArea: false,
                context: context,
                builder: (context) {
                  return Stack(
                    children: [
                      FractionallySizedBox(
                          heightFactor: 0.9,
                          widthFactor: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              SizedBox(
                                height: 35,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30, left: 10),
                                  child: TextField(
                                    controller:
                                        controller.textEditingController,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    onSubmitted: (value) {
                                      controller.apiQueueDetailSearch(value);
                                    },
                                    decoration: const InputDecoration(
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.all(9),
                                      isDense: true,
                                      hintText: 'Search queue number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.black,
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Obx(
                                  () => controller.isLoading.value
                                      ? const Center(
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : controller.allQueue.isEmpty
                                          ? const Center(
                                              child: AppText(
                                                text: 'No data',
                                                fontSize: 16,
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  controller.allQueue.length,
                                              itemBuilder: (context, index) {
                                                final queue =
                                                    controller.allQueue[index];
                                                return Stack(
                                                  children: [
                                                    Card(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              230,
                                                              230,
                                                              230),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 12,
                                                                top: 12),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  AppText(
                                                                    text: queue
                                                                        .queueNumber,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          3),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        controller.statusIcons(queue
                                                                            .status
                                                                            .value!),
                                                                        size:
                                                                            16,
                                                                        color: controller.statusColors(queue
                                                                            .status
                                                                            .value!),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      AppText(
                                                                        text: queue
                                                                            .status
                                                                            .label!,
                                                                        fontSize:
                                                                            12,
                                                                        color: controller.statusColors(queue
                                                                            .status
                                                                            .value!),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            AppText(
                                                                              text: 'Call Count : ${queue.callCount}',
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                            AppText(
                                                                              text: controller.formatDynamicDate(queue.latestCall),
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const AppText(
                                                                              text: 'Created : ',
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                            AppText(
                                                                              text: controller.formatDate(queue.createdAt),
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          queue.status.value! <=
                                                              3,
                                                      child: Positioned(
                                                        right: 1,
                                                        top: 1,
                                                        child: PopupMenuButton<
                                                            String>(
                                                          icon: const Icon(
                                                              Icons.more_vert),
                                                          onSelected:
                                                              (String value) {
                                                            if (value ==
                                                                'print') {
                                                              controller
                                                                  .printQueue(queue
                                                                      .queueId
                                                                      .toString());
                                                            } else if (value ==
                                                                'served') {
                                                              controller
                                                                  .servedQueueDetail(
                                                                      queue
                                                                          .queueId);
                                                            } else if (value ==
                                                                'void') {
                                                              controller
                                                                  .voidQueueDetail(
                                                                      queue
                                                                          .queueId);
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            const PopupMenuItem<
                                                                String>(
                                                              value: 'print',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons
                                                                      .print_rounded),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                6),
                                                                    child:
                                                                        AppText(
                                                                      text:
                                                                          'Reprint',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const PopupMenuItem<
                                                                String>(
                                                              value: 'served',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .check_circle_rounded,
                                                                    color: AppColors
                                                                        .confirm,
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                6),
                                                                    child:
                                                                        AppText(
                                                                      text:
                                                                          'Served',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12,
                                                                      color: AppColors
                                                                          .confirm,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const PopupMenuItem<
                                                                String>(
                                                              value: 'void',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .person_add_disabled_outlined,
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                6),
                                                                    child:
                                                                        AppText(
                                                                      text:
                                                                          'Void',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12,
                                                                      color: AppColors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: NumberPagination(
                                  onPageChanged: (int pageNumber) {
                                    controller.selectedPageNumber.value =
                                        pageNumber;
                                    controller.apiQueueDetailList(pageNumber);
                                  },
                                  threshold: 15,
                                  pageTotal: controller.pageTotal.value,
                                  pageInit: controller.selectedPageNumber.value,
                                  colorPrimary: AppColors.black,
                                  colorSub: Colors.white,
                                ),
                              ),
                            ],
                          )),
                      Positioned(
                        right: 10,
                        top: 1,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                      const Positioned(
                          left: 20,
                          top: 10,
                          child: AppText(
                            text: 'All Queue',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackCalm,
                          ))
                    ],
                  );
                });
          }),
    );
  }
}
