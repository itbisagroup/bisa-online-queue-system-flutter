import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/enum/queue_status.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:queue_system/widget/app_error.dart';
import 'package:queue_system/widget/app_loading.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:queue_system/widget/no_internet.dart';
import 'package:sizer/sizer.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
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
          if (controller.error.value == 'Request Timed Out') {
            return DialogError(
              appBar: _appBarNoShift(context),
              title: 'Request Timeout!',
              description: 'Something went wrong, please try again',
              onTryAgain: () async {
                await controller.branchData();
                controller.updateQueueListApi();
              },
            );
          }
          if (controller.error.value == 'Unauthorized') {
            return DialogError(
              appBar: _appBarNoShift(context),
              title: 'Unauthorized!',
              description: 'You are not authorized to access this page',
              onTryAgain: () async {
                const storage = FlutterSecureStorage();
                await storage.deleteAll();
                Get.offAllNamed(Routes.auth);
              },
            );
          }
          if (controller.error.value == 'Bad Gateway') {
            return DialogError(
              appBar: _appBarNoShift(context),
              title: 'Server hit a snag!',
              description: 'Please wait a moment and try again',
              onTryAgain: () async {
                await controller.branchData();
                controller.updateQueueListApi();
              },
            );
          }
          if (controller.error.value == 'To Many Request') {
            return DialogError(
              appBar: _appBarNoShift(context),
              title: 'Server hit a too many request!',
              description: 'Please wait a moment and try again',
              onTryAgain: () async {
                await controller.branchData();
                controller.updateQueueListApi();
              },
            );
          }
          if (controller.error.value == 'Forbidden') {
            return ShiftNotFound(
              appBar: _appBarNoShift(context),
              title: 'Shift Not Found!',
              description: 'Try to create a new shift',
              onTryAgain: () async {
                Get.toNamed(Routes.shift);
              },
            );
          } else {
            return DialogError(
              appBar: _appBarNoShift(context),
              title: 'Something Went Wrong!',
              description:
                  'There is an error, please try again later or contact the administrator',
              onTryAgain: () async {
                await controller.branchData();
                await controller.updateQueueListApi();
              },
            );
          }

        case Status.COMPLETED:
          return Stack(
            children: [
              Scaffold(
                  backgroundColor: AppColors.white,
                  floatingActionButton: _floatingButton(context),
                  appBar: _appBar(context),
                  body: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 90),
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          alignment: WrapAlignment.center,
                          children: controller.paxWithQueue
                              .map(
                                (tags) => _listQueue(tags, context),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  children: [
                    AppText(
                      text:
                          '${controller.statusSynch.value} ${controller.lastSynch.value}',
                      color: AppColors.blackCalm,
                    ),
                    Row(
                      children: [
                        controller.statusCron.value
                            ? const AppText(
                                text: 'Success',
                                color: AppColors.confirm,
                              )
                            : const AppText(
                                text: 'Failed', color: AppColors.maroon),
                        AppText(
                          text: ' ${controller.lastCrone.value}',
                          color: AppColors.blackCalm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
      }
    });
  }

  Stack _listQueue(PaxWithQueue tags, BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 15,
          child: Container(
            width: 200,
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
                _buttonBottom(tags, context)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonBottom(PaxWithQueue tags, context) {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: controller
                          .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                          .queue!
                          .queueNumber !=
                      "0000"
                  ? controller
                              .paxWithQueue[
                                  controller.paxWithQueue.indexOf(tags)]
                              .queue!
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
                                  'Call (${controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
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
                                      .paxWithQueue[
                                          controller.paxWithQueue.indexOf(tags)]
                                      .pax!
                                      .id!) ==
                                  false
                              ? ElevatedButton.icon(
                                  onPressed: () => controller.callQueue(
                                    controller
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .pax!
                                        .id!,
                                    controller
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .queue!
                                        .callCount!,
                                  ),
                                  icon: const Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: AppColors.maroon,
                                  ),
                                  label: AppText(
                                    text: controller
                                                .paxWithQueue[controller
                                                    .paxWithQueue
                                                    .indexOf(tags)]
                                                .queue!
                                                .callCount! >=
                                            1
                                        ? 'Recall (${controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})'
                                        : 'Call (${controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    minimumSize: const Size(100, 40),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularCountDownTimer(
                                      duration:
                                          controller.branch.value.callDelay!,
                                      initialDuration: 0,
                                      controller: controller.getController(
                                          controller
                                              .paxWithQueue[controller
                                                  .paxWithQueue
                                                  .indexOf(tags)]
                                              .pax!
                                              .id!),
                                      width: 25,
                                      height: 25,
                                      ringColor: Colors.grey[300]!,
                                      ringGradient: null,
                                      fillColor: const Color.fromARGB(
                                          255, 247, 199, 199),
                                      fillGradient: null,
                                      backgroundColor: AppColors.maroon,
                                      backgroundGradient: null,
                                      strokeCap: StrokeCap.round,
                                      textStyle: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textFormat: CountdownTextFormat.S,
                                      isReverse: true,
                                      isReverseAnimation: true,
                                      isTimerTextShown: true,
                                      autoStart: false,
                                    ),
                                    const SizedBox(width: 10),
                                    const AppText(
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
                              'Call (${controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!.callCount!}/${controller.branch.value.callCount!})',
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
          controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!
                      .queueNumber ==
                  "0000"
              ? controller.isButtonAddDisabled(controller
                          .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                          .pax!
                          .id!) ==
                      false
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: SizedBox(
                          width: 160,
                          height: 32,
                          child: PopupMenuButton<String>(
                            icon: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_add,
                                  size: 20,
                                  color: AppColors.maroon,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                AppText(
                                  text: 'New Queue',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            onSelected: (String value) {
                              controller.newQueue(
                                controller
                                    .paxWithQueue[
                                        controller.paxWithQueue.indexOf(tags)]
                                    .pax!
                                    .id!,
                                value,
                              );
                            },
                            itemBuilder: (BuildContext context) {
                              int minQty = controller
                                  .paxWithQueue[
                                      controller.paxWithQueue.indexOf(tags)]
                                  .pax!
                                  .minQty!;
                              int maxQty = controller
                                  .paxWithQueue[
                                      controller.paxWithQueue.indexOf(tags)]
                                  .pax!
                                  .maxQty!;

                              return List.generate(maxQty - minQty + 1,
                                  (index) {
                                int number = minQty + index;
                                return PopupMenuItem<String>(
                                  value: number.toString(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: AppText(
                                          text: number.toString(),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      const Icon(
                                        FontAwesomeIcons.person,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
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
                                  .paxWithQueue[
                                      controller.paxWithQueue.indexOf(tags)]
                                  .pax!
                                  .id!) ==
                              false
                          ? SizedBox(
                              width: 70,
                              child: DropdownButton<String>(
                                focusColor: AppColors.grey,
                                borderRadius: BorderRadius.circular(10),
                                autofocus: true,
                                hint: const AppText(
                                  text: 'Status',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'served',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: AppColors.confirm,
                                        ),
                                        const SizedBox(width: 5),
                                        AppText(
                                          text: QueueStatus.served.label,
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
                                        const Icon(
                                          Icons.person_add_disabled_outlined,
                                          color: AppColors.maroon,
                                        ),
                                        const SizedBox(width: 5),
                                        AppText(
                                          text: QueueStatus.voided.label,
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
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .queue!
                                        .queueCode!,
                                    controller
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .pax!
                                        .id!,
                                  );
                                },
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
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
                                  .paxWithQueue[
                                      controller.paxWithQueue.indexOf(tags)]
                                  .pax!
                                  .id!) ==
                              false
                          ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: SizedBox(
                                width: 42,
                                height: 40,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.group_add,
                                    size: 20,
                                  ),
                                  onSelected: (String value) {
                                    controller.newQueue(
                                      controller
                                          .paxWithQueue[controller.paxWithQueue
                                              .indexOf(tags)]
                                          .pax!
                                          .id!,
                                      value,
                                    );
                                  },
                                  itemBuilder: (BuildContext context) {
                                    int minQty = controller
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .pax!
                                        .minQty!;
                                    int maxQty = controller
                                        .paxWithQueue[controller.paxWithQueue
                                            .indexOf(tags)]
                                        .pax!
                                        .maxQty!;

                                    return List.generate(maxQty - minQty + 1,
                                        (index) {
                                      int number = minQty + index;
                                      return PopupMenuItem<String>(
                                        value: number.toString(),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: AppText(
                                                text: number.toString(),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            const Icon(
                                              FontAwesomeIcons.person,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  },
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
        children: [
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppText(
                    text: 'Waiting : ',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  AppText(
                    text: controller
                        .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                        .queue!
                        .waitingCount!
                        .toString(),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _queueNumber(PaxWithQueue tags) {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 3,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                    text: controller
                        .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                        .pax!
                        .notation!,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon),
                TextAnimator(
                  controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                      .queue!.queueNumber!
                      .substring(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      fontFamily: 'Poppins',
                      letterSpacing: 1,
                      wordSpacing: 1,
                      color: AppColors.black),
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromBottom(
                          duration: const Duration(milliseconds: 1500)),
                ),
              ],
            ),
            Positioned(
                left: 10,
                bottom: 3,
                child: Visibility(
                  visible: controller
                          .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                          .queue!
                          .queueNumber !=
                      "0000",
                  child: Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: AppText(
                          text: controller.formatTimeDifference(
                            controller
                                .paxWithQueue[
                                    controller.paxWithQueue.indexOf(tags)]
                                .queue!
                                .createdDate!,
                          ),
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.person,
                            size: 12,
                            color: AppColors.black,
                          ),
                          AppText(
                            text:
                                ': ${controller.paxWithQueue[controller.paxWithQueue.indexOf(tags)].queue!.queueQty!.toString()}',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
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
              text: controller
                  .paxWithQueue[controller.paxWithQueue.indexOf(tags)]
                  .pax!
                  .variety!,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.blackCalm),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      bottomOpacity: 30,
      toolbarHeight: 120,
      backgroundColor: AppColors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          controller.branch.value.brand!.logo!.isEmpty
              ? const AppText(
                  text: 'logo',
                  fontSize: 7,
                )
              : CachedNetworkImage(
                  imageUrl: controller.branch.value.brand!.logo!,
                  height: 3.5.h,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => const AppText(
                    text: 'logo',
                    fontSize: 7,
                  ),
                ),
          SizedBox(width: 30),
          TitleText(
            text: controller.branch.value.fullName!,
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.black,
            ),
            onSelected: (String value) {
              if (value == 'screen') {
                if (controller.secondaryWindowIDs.isEmpty) {
                  controller.openSecondaryWindow();
                } else {
                  controller.closeSecondaryWindow();
                }
              }
              if (value == 'shift') {
                Get.toNamed(Routes.shift);
              }
              if (value == 'config') {
                Get.toNamed(Routes.config);
              }
              if (value == 'sync') {
                controller.sync();
              } else if (value == 'printer') {
                Get.toNamed(Routes.printer);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Synchronizes',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'screen',
                child: Row(
                  children: [
                    Icon(controller.secondaryWindowIDs.isEmpty
                        ? Icons.add_to_queue
                        : Icons.close_sharp),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: AppText(
                        text: controller.secondaryWindowIDs.isEmpty
                            ? 'Customer Screen'
                            : 'Close Customer Screen',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'printer',
                child: Row(
                  children: [
                    Icon(Icons.print_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Printer Setting',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'shift',
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.calendarPlus,
                    ),
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
              const PopupMenuItem<String>(
                value: 'config',
                child: Row(
                  children: [
                    Icon(Icons.settings_applications),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Configuration',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                      color: AppColors.black,
                    ),
                    AppText(
                      text: 'Version 0.2.1 (alpha-test)',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    AppText(
                      text: 'Bisagroup © 2024. All Rights Reserved',
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      color: AppColors.black,
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

  AppBar _appBarNoShift(BuildContext context) {
    return AppBar(
      bottomOpacity: 30,
      toolbarHeight: 120,
      backgroundColor: AppColors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.black,
            ),
            onSelected: (String value) {
              if (value == 'shift') {
                Get.toNamed(Routes.shift);
              }
              if (value == 'config') {
                Get.toNamed(Routes.config);
              }
              if (value == 'sync') {
                controller.sync();
              } else if (value == 'printer') {
                Get.toNamed(Routes.printer);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Synchronizes',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'printer',
                child: Row(
                  children: [
                    Icon(Icons.print_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Printer Setting',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'shift',
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.calendarPlus,
                    ),
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
              const PopupMenuItem<String>(
                value: 'config',
                child: Row(
                  children: [
                    Icon(Icons.settings_applications),
                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: AppText(
                        text: 'Configuration',
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                      color: AppColors.black,
                    ),
                    AppText(
                      text: 'Version 0.2.1 (alpha-test)',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    AppText(
                      text: 'Bisagroup © 2024. All Rights Reserved',
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      color: AppColors.black,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Column(
              children: [
                Visibility(
                  visible: controller.withHoldVisible.value &&
                      controller.withhold.isNotEmpty,
                  child: Stack(
                    children: [
                      SizedBox(
                          width: 400,
                          height: 400,
                          child: Card(
                            color: AppColors.lessBrown,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: AppText(
                                      text: 'Queue Numbers Withhold',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 15,
                                  child: ListView.builder(
                                      itemCount: controller.withhold.length,
                                      itemBuilder: (context, index) {
                                        final withhold =
                                            controller.withhold[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, bottom: 10),
                                          child: SizedBox(
                                            height: 100,
                                            child: Card(
                                              child: Container(
                                                color: AppColors.white,
                                                child: Column(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          withhold.queueNumber!,
                                                      fontSize: 35,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.black,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        TextButton.icon(
                                                            onPressed: () {
                                                              controller
                                                                  .onItemWitWithholdSelected(
                                                                'served',
                                                                withhold
                                                                    .queueCode!,
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              Icons.done,
                                                              color: AppColors
                                                                  .confirm,
                                                            ),
                                                            label: AppText(
                                                                text:
                                                                    QueueStatus
                                                                        .served
                                                                        .label,
                                                                color: AppColors
                                                                    .confirm)),
                                                        TextButton.icon(
                                                            onPressed: () {
                                                              controller
                                                                  .onItemWitWithholdSelected(
                                                                'void',
                                                                withhold
                                                                    .queueCode!,
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color: AppColors
                                                                  .maroon,
                                                            ),
                                                            label: AppText(
                                                              text: QueueStatus
                                                                  .voided.label,
                                                              color: AppColors
                                                                  .maroon,
                                                            ))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          )),
                      Positioned(
                          right: 1,
                          child: IconButton(
                            tooltip: "Close",
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              controller.withHoldVisible.value = false;
                            },
                          ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: !controller.withHoldVisible.value &&
                      controller.withhold.isNotEmpty,
                  child: SizedBox(
                    width: 160,
                    child: FloatingActionButton(
                      heroTag: 'withhold',
                      onPressed: () {
                        controller.changeVisibleWithold();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              FontAwesomeIcons.personCircleExclamation,
                              color: AppColors.maroon,
                              size: 24,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          AppText(
                            text: 'Withhold',
                            maxLines: 1,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
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
                        text: 'All Queues',
                        maxLines: 1,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        useRootNavigator: false,
                        isScrollControlled: true,
                        backgroundColor: AppColors.white,
                        useSafeArea: false,
                        context: context,
                        builder: (context) {
                          controller.apiQueueDetailList();
                          return Stack(
                            children: [
                              FractionallySizedBox(
                                  heightFactor: 0.9,
                                  widthFactor: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      SizedBox(
                                        height: 35,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 30, left: 10),
                                          child: TextField(
                                            controller: controller
                                                .textEditingController,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            onSubmitted: (value) {
                                              controller
                                                  .apiQueueDetailSearch(value);
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Obx(
                                            () => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ActionChip(
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  label: AppText(
                                                    text: 'All',
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            0
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          0
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller.statusValueFilter
                                                        .value = 0;

                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .waiting.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            1
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          1
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 1;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .calling.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            2
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          2
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 2;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .lastCall.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            3
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          3
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 3;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .served.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            4
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          4
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 4;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .voided.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            7
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          7
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 7;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .cancelled.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            8
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          8
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 8;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                                ActionChip(
                                                  label: AppText(
                                                    text: QueueStatus
                                                        .expired.label,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: controller
                                                                .statusValueFilter
                                                                .value ==
                                                            9
                                                        ? AppColors.white
                                                        : AppColors.grey,
                                                  ),
                                                  side: const BorderSide(
                                                      color: AppColors.grey
                                                      // No border color
                                                      ),
                                                  backgroundColor: controller
                                                              .statusValueFilter
                                                              .value ==
                                                          9
                                                      ? AppColors.maroon
                                                      : AppColors.white,
                                                  onPressed: () {
                                                    controller
                                                        .selectedPageNumber
                                                        .value = 1;
                                                    controller.statusValueFilter
                                                        .value = 9;
                                                    controller
                                                        .apiQueueDetailList();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Obx(
                                          () => controller.isLoading.value
                                              ? const Center(
                                                  child: SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                )
                                              : controller.allQueue.isEmpty
                                                  ? controller
                                                          .buttonRefreshDetail
                                                          .value
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const AppText(
                                                              text:
                                                                  'Unable to Load Data!',
                                                              fontSize: 16,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .maroon,
                                                              ),
                                                              onPressed: () {
                                                                controller
                                                                    .apiQueueDetailList();
                                                              },
                                                              child:
                                                                  const AppText(
                                                                text:
                                                                    'Try Again',
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const Center(
                                                          child: AppText(
                                                            text: 'No data',
                                                            fontSize: 16,
                                                          ),
                                                        )
                                                  : ListView.builder(
                                                      itemCount: controller
                                                          .allQueue.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final queue = controller
                                                            .allQueue[index];
                                                        return Stack(
                                                          children: [
                                                            Card(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  230,
                                                                  230,
                                                                  230),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            12,
                                                                        top:
                                                                            12),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          AppText(
                                                                            text:
                                                                                queue.queueNumber,
                                                                            fontSize:
                                                                                26,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                controller.statusIcons(queue.status.value!),
                                                                                size: 16,
                                                                                color: controller.statusColors(queue.status.value!),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              AppText(
                                                                                text: queue.status.label!,
                                                                                fontSize: 14,
                                                                                color: controller.statusColors(queue.status.value!),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 3,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        AppText(
                                                                                          text: 'Pax : ${queue.queueQty}',
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: AppColors.blackCalm,
                                                                                        ),
                                                                                        const SizedBox(width: 5),
                                                                                        const Icon(FontAwesomeIcons.person, size: 20, color: AppColors.blackCalm),
                                                                                        const SizedBox(width: 10),
                                                                                        Visibility(
                                                                                          visible: queue.status.value! <= 3,
                                                                                          child: PopupMenuButton<String>(
                                                                                            icon: const Icon(Icons.edit_square, size: 20, color: Colors.black),
                                                                                            onSelected: (String value) {
                                                                                              controller.updateQtyQueue(
                                                                                                queue.queueCode,
                                                                                                value,
                                                                                              );
                                                                                            },
                                                                                            itemBuilder: (BuildContext context) {
                                                                                              int minQty = queue.pax.minQty!;
                                                                                              int maxQty = queue.pax.maxQty!;
                                                                                              int qty = queue.queueQty;

                                                                                              return List.generate(maxQty - minQty + 1, (index) {
                                                                                                int number = minQty + index;

                                                                                                // Return null if the number is equal to the current qty
                                                                                                if (number == qty) {
                                                                                                  return null;
                                                                                                }

                                                                                                return PopupMenuItem<String>(
                                                                                                  value: number.toString(),
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Padding(
                                                                                                        padding: const EdgeInsets.only(right: 8),
                                                                                                        child: AppText(
                                                                                                          text: number.toString(),
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          color: AppColors.black,
                                                                                                        ),
                                                                                                      ),
                                                                                                      const Icon(
                                                                                                        FontAwesomeIcons.person,
                                                                                                        size: 16,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              }).whereType<PopupMenuItem<String>>().toList();
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 5,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    const AppText(
                                                                                      text: 'Created :',
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: AppColors.blackCalm,
                                                                                    ),
                                                                                    AppText(
                                                                                      text: controller.formatDate(queue.createdAt),
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.normal,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    AppText(
                                                                                      text: 'Call Count : ${queue.callCount}',
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: AppColors.blackCalm,
                                                                                    ),
                                                                                    AppText(
                                                                                      text: controller.formatDate(queue.latestCall),
                                                                                      fontSize: 14,
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
                                                                visible: queue
                                                                        .status
                                                                        .value! <=
                                                                    3,
                                                                child:
                                                                    Positioned(
                                                                  right: 1,
                                                                  top: 1,
                                                                  child:
                                                                      PopupMenuButton<
                                                                          String>(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .more_vert),
                                                                    onSelected:
                                                                        (String
                                                                            value) {
                                                                      if (value ==
                                                                          'print') {
                                                                        controller
                                                                            .printQueue(
                                                                          queue
                                                                              .queueCode
                                                                              .toString(),
                                                                        );
                                                                      } else if (value ==
                                                                          'served') {
                                                                        AppDialog
                                                                            .confirmationMsg(
                                                                          title:
                                                                              "Served Queue",
                                                                          message:
                                                                              "Are you sure want to served this queue?",
                                                                          function:
                                                                              () {
                                                                            Get.back();
                                                                            controller.servedQueueDetail(
                                                                              queue.queueCode,
                                                                            );
                                                                          },
                                                                          aksiText:
                                                                              "Ok",
                                                                        );
                                                                      } else if (value ==
                                                                          'void') {
                                                                        AppDialog
                                                                            .confirmationMsg(
                                                                          title:
                                                                              "Void Queue",
                                                                          message:
                                                                              "Are you sure want to served this void?",
                                                                          function:
                                                                              () {
                                                                            Get.back();
                                                                            controller.voidQueueDetail(
                                                                              queue.queueCode,
                                                                            );
                                                                          },
                                                                          aksiText:
                                                                              "Ok",
                                                                        );
                                                                      }
                                                                    },
                                                                    itemBuilder: (BuildContext
                                                                            context) =>
                                                                        <PopupMenuEntry<
                                                                            String>>[
                                                                      const PopupMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'print',
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.print_rounded),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(left: 6),
                                                                              child: AppText(
                                                                                text: 'Reprint',
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'served',
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.check_circle_rounded,
                                                                              color: AppColors.confirm,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 6),
                                                                              child: AppText(
                                                                                text: QueueStatus.served.label,
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 12,
                                                                                color: AppColors.confirm,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'void',
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.person_add_disabled_outlined,
                                                                              color: AppColors.red,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 6),
                                                                              child: AppText(
                                                                                text: QueueStatus.voided.label,
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 12,
                                                                                color: AppColors.red,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ))
                                                          ],
                                                        );
                                                      },
                                                    ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Obx(
                                          () => NumberPagination(
                                            onPageChanged: (int pageNumber) {
                                              controller.selectedPageNumber
                                                  .value = pageNumber;
                                              controller.apiQueueDetailList();
                                            },
                                            threshold: 8,
                                            pageTotal:
                                                controller.pageTotal.value,
                                            pageInit: controller
                                                .selectedPageNumber.value,
                                            colorPrimary: AppColors.black,
                                            colorSub: Colors.white,
                                          ),
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
                                    text: 'All Queues',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackCalm,
                                  )),
                              Positioned(
                                  right: 10,
                                  bottom: 55,
                                  child: Row(
                                    children: [
                                      const AppText(
                                        text: 'Total data : ',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.maroon,
                                      ),
                                      Obx(
                                        () => AppText(
                                          text: controller.totalData.value
                                              .toString(),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blackCalm,
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          );
                        });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
