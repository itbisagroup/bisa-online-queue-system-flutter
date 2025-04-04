import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/enum/queue_status.dart';
import 'package:queue_system/view_models/controller/shift_controller.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:sizer/sizer.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class ShiftView extends GetView<ShiftController> {
  const ShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ShiftController());
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: AppText(
            text: '${'all'.tr} Shifts',
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        floatingActionButton: Obx(() => WidgetAnimator(
              incomingEffect: WidgetTransitionEffects(
                  delay: const Duration(milliseconds: 15),
                  offset: const Offset(0, -30),
                  curve: Curves.bounceOut,
                  duration: const Duration(milliseconds: 900)),
              atRestEffect: WidgetRestingEffects.wave(),
              child: controller.buttonNew.value
                  ? SizedBox(
                      width: 160,
                      child: FloatingActionButton(
                        heroTag: 'new',
                        backgroundColor: AppColors.confirm,
                        onPressed: () {
                          controller.newShiftDialog();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Icon(
                                FontAwesomeIcons.calendarPlus,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AppText(
                              text: 'new_shift'.tr,
                              maxLines: 1,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 160,
                      child: FloatingActionButton(
                        heroTag: 'end',
                        backgroundColor: AppColors.maroon,
                        onPressed: () {
                          controller.endShiftDialog();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Icon(
                                Icons.exit_to_app,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AppText(
                              text: 'end_shift'.tr,
                              maxLines: 1,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ),
            )),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator()),
            );
          } else if (controller.buttonRefresh.value) {
            return Center(
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(text: 'unable_to_load'.tr, fontSize: 20),
                    const SizedBox(
                      height: 80,
                    ),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.maroon),
                      ),
                      onPressed: () async {
                        await controller
                            .shiftData(controller.selectedPageNumber.value);
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: AppText(
                        text: 'try_again'.tr,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (controller.allshift.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
              child: Row(
                children: [
                  _listShifts(),
                  _detailShift(),
                ],
              ),
            );
          } else {
            return Center(
              child: AppText(
                text: 'no_data'.tr,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        }));
  }

  Widget _detailShift() {
    return Expanded(
        flex: 8,
        child: controller.isLoadingDetail.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.isGetDetailError.value
                ? Center(
                    child: SizedBox(
                      width: 50.w,
                      height: 50.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(text: 'unable_to_load'.tr, fontSize: 20),
                          const SizedBox(
                            height: 80,
                          ),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(AppColors.maroon),
                            ),
                            onPressed: () async {
                              await controller.detailShiftData(
                                  controller.selectedCard.value);
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: AppText(
                              text: 'try_again'.tr,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Card(
                                color: AppColors.white,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: controller
                                                .detailShift.branch!.logoUrl!,
                                            width: 60,
                                            height: 60,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child:
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress)),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const AppText(
                                              text: 'logo',
                                              fontSize: 7,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          AppText(
                                            text: controller
                                                .detailShift.branch!.fullName!,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 7.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, bottom: 10),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text: 'queue_config'.tr,
                                            fontSize: 5.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: 'queue_count'.tr,
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text: 'call_count'.tr,
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text: 'call_delay'.tr,
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text: 'call_repeat'.tr,
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text: 'play_video'.tr,
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text:
                                                          ': ${controller.detailShift.branch!.queueCount} ${'times'.tr}',
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text:
                                                          ': ${controller.detailShift.branch!.callCount!} ${'times'.tr}',
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text:
                                                          ': ${controller.detailShift.branch!.callDelay!} ${'seconds'.tr}',
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text:
                                                          ': ${controller.detailShift.branch!.callRepeat!} ${'times'.tr}',
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    AppText(
                                                      text: controller
                                                              .detailShift
                                                              .branch!
                                                              .playAds!
                                                          ? ': ${'play_video_desc'.tr}'
                                                          : ': ${'play_video_desc_no'.tr}',
                                                      fontSize: 5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: controller
                                              .detailShift.status!.value !=
                                          1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons
                                                    .check_circle_outline_sharp,
                                                color: AppColors.maroon,
                                                size: 10.sp),
                                            const SizedBox(width: 5),
                                            AppText(
                                              text: 'closed_shift'.tr,
                                              fontSize: 5.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.maroon,
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            SizedBox(
                                              child: TextButton.icon(
                                                onPressed: () {
                                                  controller.getDetailShiftEnd(
                                                      controller
                                                          .detailShift.id!);
                                                },
                                                icon: Icon(Icons.print,
                                                    color: AppColors.black,
                                                    size: 7.sp),
                                                label: AppText(
                                                    text: 'Print',
                                                    fontSize: 4.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Card(
                                  color: AppColors.white,
                                  child: controller.detailShift.queue == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            AppText(
                                                text: 'recaps'.tr,
                                                fontSize: 6.sp,
                                                fontWeight: FontWeight.bold),
                                            Expanded(
                                                child: Center(
                                                    child: AppText(
                                                        text: 'no_data'.tr))),
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                        right: 7,
                                                        bottom: 7,
                                                        child: Row(
                                                          children: [
                                                            const AppText(
                                                                text:
                                                                    'Total : '),
                                                            AppText(
                                                              text: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .length
                                                                  .toString(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ],
                                                        )),
                                                    Transform.scale(
                                                      scale: 0.3.sp,
                                                      child: PieChart(
                                                        PieChartData(
                                                          sections: [
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .waiting
                                                                  .color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      1)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      1)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .calling
                                                                  .color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      2)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      2)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .lastCall
                                                                  .color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      3)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      3)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              showTitle: true,
                                                              color: QueueStatus
                                                                  .served.color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      4)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      4)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .voided.color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      7)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      7)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .cancelled
                                                                  .color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      8)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      8)
                                                                  .length
                                                                  .toString(),
                                                              radius: 50,
                                                            ),
                                                            PieChartSectionData(
                                                              titleStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: QueueStatus
                                                                  .expired
                                                                  .color,
                                                              value: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      9)
                                                                  .length
                                                                  .toDouble(),
                                                              title: controller
                                                                  .detailShift
                                                                  .queue!
                                                                  .where((element) =>
                                                                      element
                                                                          .status
                                                                          .value ==
                                                                      9)
                                                                  .length
                                                                  .toString(),
                                                              badgePositionPercentageOffset:
                                                                  10,
                                                              radius: 50,
                                                            ),
                                                          ],
                                                          sectionsSpace: 0,
                                                          centerSpaceRadius: 40,
                                                          centerSpaceColor:
                                                              Colors.white,
                                                          borderData:
                                                              FlBorderData(
                                                                  show: false),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .waiting.color,
                                                    ),
                                                    AppText(
                                                      text: QueueStatus
                                                          .waiting.label.tr,
                                                      fontSize: 3.5.sp,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .calling.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .calling.label.tr,
                                                        fontSize: 3.5.sp),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .lastCall.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .lastCall.label.tr,
                                                        fontSize: 3.5.sp),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .served.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .served.label.tr,
                                                        fontSize: 3.5.sp),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .voided.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .voided.label.tr,
                                                        fontSize: 3.5.sp),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .cancelled.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .cancelled.label.tr,
                                                        fontSize: 3.5.sp),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      width: 1.w,
                                                      height: 0.5.h,
                                                      color: QueueStatus
                                                          .expired.color,
                                                    ),
                                                    AppText(
                                                        text: QueueStatus
                                                            .expired.label.tr,
                                                        fontSize: 3.5.sp),
                                                  ],
                                                ),
                                              ))
                                            ],
                                          ),
                                        )),
                            ),
                          ),
                        ],
                      )),
                      Expanded(
                          flex: 2,
                          child: SizedBox(
                            width: double.infinity,
                            child: controller.detailShift.queue == null
                                ? Center(
                                    child: AppText(text: 'no_data'.tr),
                                  )
                                : Card(
                                    color: AppColors.white,
                                    child: CustomScrollView(
                                      slivers: <Widget>[
                                        SliverStickyHeader(
                                          header: Container(
                                            height: 60.0,
                                            color: AppColors.maroon,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Center(
                                                      child: AppText(
                                                          text:
                                                              "queue_number".tr,
                                                          fontSize: 4.sp,
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                                Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: AppText(
                                                          text: "created_at".tr,
                                                          fontSize: 4.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                                Expanded(
                                                    flex: 1,
                                                    child: Center(
                                                      child: AppText(
                                                          text: "quantity".tr,
                                                          fontSize: 4.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                                Expanded(
                                                    flex: 1,
                                                    child: Center(
                                                      child: AppText(
                                                          text: "call_count".tr,
                                                          fontSize: 4.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                                Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: AppText(
                                                          text: "last_call".tr,
                                                          fontSize: 4.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                                Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: AppText(
                                                          text: "Status",
                                                          fontSize: 4.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          sliver: SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              (context, index) => ListTile(
                                                dense: true,
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Center(
                                                          child: AppText(
                                                            text: controller
                                                                .detailShift
                                                                .queue![index]
                                                                .queueNumber
                                                                .toString(),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 3.5.sp,
                                                          ),
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: AppText(
                                                              fontSize: 3.5.sp,
                                                              text: controller
                                                                  .formatDate(controller
                                                                      .detailShift
                                                                      .queue![
                                                                          index]
                                                                      .createdAt
                                                                      .toString())),
                                                        )),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Center(
                                                          child: AppText(
                                                              fontSize: 3.5.sp,
                                                              text: controller
                                                                  .detailShift
                                                                  .queue![index]
                                                                  .queueQty
                                                                  .toString()),
                                                        )),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Center(
                                                          child: AppText(
                                                              fontSize: 3.5.sp,
                                                              text: controller
                                                                  .detailShift
                                                                  .queue![index]
                                                                  .callCount
                                                                  .toString()),
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: controller
                                                                      .detailShift
                                                                      .queue![
                                                                          index]
                                                                      .latestCall !=
                                                                  null
                                                              ? AppText(
                                                                  fontSize:
                                                                      3.5.sp,
                                                                  text: controller.formatDate(controller
                                                                      .detailShift
                                                                      .queue![
                                                                          index]
                                                                      .latestCall
                                                                      .toString()))
                                                              : AppText(
                                                                  fontSize:
                                                                      3.5.sp,
                                                                  text: '-'),
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: AppText(
                                                              fontSize: 3.5.sp,
                                                              text: controller
                                                                  .adminController
                                                                  .statusLabel(controller
                                                                      .detailShift
                                                                      .queue![
                                                                          index]
                                                                      .status
                                                                      .value).tr,
                                                              color: controller
                                                                  .statusColors(controller
                                                                      .detailShift
                                                                      .queue![
                                                                          index]
                                                                      .status
                                                                      .value)),
                                                        )),
                                                  ],
                                                ),
                                                subtitle: const Divider(
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              childCount: controller
                                                  .detailShift.queue!.length,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          )),
                      const SizedBox(
                        height: 60,
                      )
                    ],
                  ));
  }

  Expanded _listShifts() {
    return Expanded(
        flex: 3,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: controller.detailButton.value ? double.infinity : 500,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: controller.allshift.length,
                          itemBuilder: (context, index) {
                            final shift = controller.allshift[index];

                            return Obx(
                              () => Stack(
                                children: [
                                  Card(
                                    color: controller.selectedCard.value ==
                                            shift.id!
                                        ? Colors.grey[300]
                                        : Colors.white,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.selectedCard.value =
                                            shift.id!;
                                        controller.detailButton.value = true;
                                        controller.detailShiftData(shift.id!);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: AppText(
                                            text: shift.branch!.fullName!,
                                            fontSize: 5.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  AppText(
                                                    text:
                                                        'Total ${'queue'.tr}: ',
                                                    fontSize: 4.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  AppText(
                                                    text: shift.countQueueData
                                                        .toString(),
                                                    fontSize: 4.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AppText(
                                                    text: controller.formatDate(
                                                        shift.startedAt!.date),
                                                    fontSize: 3.5.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  AppText(
                                                    text: ' - ',
                                                    fontSize: 3.5.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        shift.endedAt != '',
                                                    child: AppText(
                                                      text: shift.endedAt != ''
                                                          ? controller
                                                              .formatDate(shift
                                                                  .endedAt!)
                                                          : '',
                                                      fontSize: 3.5.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          leading: const Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: Icon(
                                              FontAwesomeIcons.calendarDay,
                                              size: 30,
                                              color: AppColors.maroon,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    bottom: 20,
                                    child: Visibility(
                                      visible: shift.status!.value == 9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline_sharp,
                                            size: 16,
                                            color: AppColors.maroon,
                                          ),
                                          const SizedBox(width: 5),
                                          AppText(
                                            text: shift.status!.label,
                                            fontSize: 10,
                                            color: AppColors.maroon,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 15.sp,
                                      right: 5.sp,
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 6.sp,
                                      )),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Obx(
                () => NumberPagination(
                  onPageChanged: (int pageNumber) {
                    controller.selectedPageNumber.value = pageNumber;
                    controller.shiftData(pageNumber);
                  },
                  totalPages: controller.pageTotal.value,
                  currentPage: controller.selectedPageNumber.value,
                ),
              ),
            ),
          ],
        ));
  }
}
