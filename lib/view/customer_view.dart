import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view/void_view.dart';
import 'package:queue_system/widget/app_loading.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:sizer/sizer.dart';
import '../view_models/controller/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerController());

    return Obx(() {
      switch (controller.rxRequestStatus.value) {
        case Status.LOADING:
          return const AppLoading();
        case Status.ERROR:
          if (controller.error.value == 'No Internet') {
            return const Text('No Conections');
          }
          if (controller.error.value == 'Request Time Out') {
            return const Center(child: Text('Request Time Out'));
          } else {
            return const Text('Something Wrong');
          }

        case Status.COMPLETED:
          return Scaffold(
              backgroundColor: const Color(0xffecf0f3),
              body: controller.adminController.branch.value.playAds!
                  ? controller.adminController.statusRealtime.value
                      ? Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            AppText(
                                              text: controller.adminController
                                                  .branch.value.fullName!,
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                AppText(
                                                  text: controller
                                                      .currentDate.value,
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 6.sp,
                                                ),
                                                const SizedBox(width: 6.0),
                                                SizedBox(
                                                  width: 14.w,
                                                  child: AppText(
                                                    text: controller
                                                        .currentTime.value,
                                                    color: AppColors.blackCalm,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 6.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ))),
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                  top: 10,
                                                ),
                                                child: Container(
                                                  width: controller
                                                      .titleSize.value.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffecf0f3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    gradient:
                                                        const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xffecf0f3),
                                                        Color(0xffecf0f3),
                                                      ],
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffffffff),
                                                        offset: Offset(
                                                            -20.0, -20.0),
                                                        blurRadius: 30,
                                                        spreadRadius: 0.0,
                                                      ),
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffced2d5),
                                                        offset:
                                                            Offset(20.0, 20.0),
                                                        blurRadius: 30,
                                                        spreadRadius: 0.0,
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: Center(
                                                    child: AppText(
                                                      text: 'Queue Number',
                                                      fontSize: 8.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.blackCalm,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                alignment: WrapAlignment.center,
                                                children: List.generate(
                                                  controller.adminController.pax
                                                      .length,
                                                  (index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Container(
                                                        width: controller
                                                            .containerWidth
                                                            .value
                                                            .sp,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xffecf0f3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Color(0xffecf0f3),
                                                              Color(0xffecf0f3),
                                                            ],
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffffffff),
                                                              offset: Offset(
                                                                  -20.0, -20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffced2d5),
                                                              offset: Offset(
                                                                  20.0, 20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                bottom: 10),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            AppText(
                                                              text:
                                                                  "${controller.adminController.pax[index].pax!.notation!} ",
                                                              fontSize:
                                                                  controller
                                                                      .numberSize
                                                                      .value
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .maroon,
                                                            ),
                                                            AppText(
                                                              text: controller
                                                                  .adminController
                                                                  .pax[index]
                                                                  .queue!
                                                                  .queueNumber!
                                                                  .substring(1),
                                                              fontSize:
                                                                  controller
                                                                      .numberSize
                                                                      .value
                                                                      .sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Visibility(
                                                visible: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    600,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 20,
                                                      left: 20,
                                                      bottom: 20,
                                                    ),
                                                    child: Container(
                                                        width: controller
                                                            .titleSize.value.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xffecf0f3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Color(0xffecf0f3),
                                                              Color(0xffecf0f3),
                                                            ],
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffffffff),
                                                              offset: Offset(
                                                                  -20.0, -20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffced2d5),
                                                              offset: Offset(
                                                                  20.0, 20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            controller
                                                                    .adminController
                                                                    .branch
                                                                    .value
                                                                    .playAds!
                                                                ? AspectRatio(
                                                                    aspectRatio:
                                                                        16 / 9,
                                                                    child: Video(
                                                                        controller: controller
                                                                            .adminController
                                                                            .controllerVideo),
                                                                  )
                                                                : AspectRatio(
                                                                    aspectRatio:
                                                                        16 / 9,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/noads.gif',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Image
                                                                      .network(
                                                                    controller
                                                                            .adminController
                                                                            .branch
                                                                            .value
                                                                            .brand!
                                                                            .logo ??
                                                                        'https://upload.wikimedia.org/wikipedia/commons/3/38/Solid_white_bordered.png',
                                                                    width: 6.w,
                                                                    height: 6.h,
                                                                    filterQuality:
                                                                        FilterQuality
                                                                            .high,
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible: controller
                                                                          .adminController
                                                                          .branch
                                                                          .value
                                                                          .brand!
                                                                          .codeName !=
                                                                      'ST',
                                                                  child:
                                                                      Expanded(
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/bisagroup.png',
                                                                      width:
                                                                          15.w,
                                                                      height:
                                                                          15.h,
                                                                      filterQuality:
                                                                          FilterQuality
                                                                              .high,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                AppText(
                                                                  text: controller
                                                                      .adminController
                                                                      .branch
                                                                      .value
                                                                      .brand!
                                                                      .fullName!,
                                                                  fontSize:
                                                                      6.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                AppText(
                                                                  text:
                                                                      '${controller.adminController.branch.value.address!}, ${controller.adminController.branch.value.city!}, ${controller.adminController.branch.value.province!}, ${controller.adminController.branch.value.country!}',
                                                                  fontSize:
                                                                      5.sp,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ))),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            MediaQuery.of(context).size.width >=
                                                600,
                                        child: Expanded(
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                                bottom: 20,
                                              ),
                                              child: Container(
                                                  width: controller
                                                      .titleSize.value.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffecf0f3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    gradient:
                                                        const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xffecf0f3),
                                                        Color(0xffecf0f3),
                                                      ],
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffffffff),
                                                        offset: Offset(
                                                            -20.0, -20.0),
                                                        blurRadius: 30,
                                                        spreadRadius: 0.0,
                                                      ),
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffced2d5),
                                                        offset:
                                                            Offset(20.0, 20.0),
                                                        blurRadius: 30,
                                                        spreadRadius: 0.0,
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.all(15),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      controller
                                                              .adminController
                                                              .branch
                                                              .value
                                                              .playAds!
                                                          ? AspectRatio(
                                                              aspectRatio:
                                                                  16 / 9,
                                                              child: Video(
                                                                  controller: controller
                                                                      .adminController
                                                                      .controllerVideo),
                                                            )
                                                          : AspectRatio(
                                                              aspectRatio:
                                                                  16 / 9,
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/noads.gif',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                Image.network(
                                                              controller
                                                                      .adminController
                                                                      .branch
                                                                      .value
                                                                      .brand!
                                                                      .logo ??
                                                                  'https://upload.wikimedia.org/wikipedia/commons/3/38/Solid_white_bordered.png',
                                                              width: 6.w,
                                                              height: 6.h,
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .high,
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: controller
                                                                    .adminController
                                                                    .branch
                                                                    .value
                                                                    .brand!
                                                                    .codeName !=
                                                                'ST',
                                                            child: Expanded(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/bisagroup.png',
                                                                width: 15.w,
                                                                height: 15.h,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          AppText(
                                                            text: controller
                                                                .adminController
                                                                .branch
                                                                .value
                                                                .brand!
                                                                .fullName!,
                                                            fontSize: 6.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          AppText(
                                                            text:
                                                                '${controller.adminController.branch.value.address!}, ${controller.adminController.branch.value.city!}, ${controller.adminController.branch.value.province!}, ${controller.adminController.branch.value.country!}',
                                                            fontSize: 5.sp,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                                left: 1,
                                top: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.offAllNamed(Routes.home);
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 30,
                                    color: AppColors.grey,
                                  ),
                                ))
                          ],
                        )
                      : Stack(
                          children: [
                            Video(
                                controller:
                                    controller.adminController.controllerVideo),
                            Positioned(
                                left: 1,
                                top: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.offAllNamed(Routes.home);
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ))
                          ],
                        )
                  : Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        AppText(
                                          text: controller.adminController
                                              .branch.value.fullName!,
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            AppText(
                                              text:
                                                  controller.currentDate.value,
                                              color: AppColors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 6.sp,
                                            ),
                                            const SizedBox(width: 6.0),
                                            SizedBox(
                                              width: 14.w,
                                              child: AppText(
                                                text: controller
                                                    .currentTime.value,
                                                color: AppColors.blackCalm,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 6.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))),
                            Expanded(
                              flex: 6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                              top: 10,
                                            ),
                                            child: Container(
                                              width:
                                                  controller.titleSize.value.w,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffecf0f3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xffecf0f3),
                                                    Color(0xffecf0f3),
                                                  ],
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xffffffff),
                                                    offset:
                                                        Offset(-20.0, -20.0),
                                                    blurRadius: 30,
                                                    spreadRadius: 0.0,
                                                  ),
                                                  BoxShadow(
                                                    color: Color(0xffced2d5),
                                                    offset: Offset(20.0, 20.0),
                                                    blurRadius: 30,
                                                    spreadRadius: 0.0,
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Center(
                                                child: AppText(
                                                  text: 'Queue Number',
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blackCalm,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            alignment: WrapAlignment.center,
                                            children: List.generate(
                                              controller
                                                  .adminController.pax.length,
                                              (index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    width: controller
                                                        .containerWidth
                                                        .value
                                                        .sp,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffecf0f3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient:
                                                          const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xffecf0f3),
                                                          Color(0xffecf0f3),
                                                        ],
                                                      ),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffffffff),
                                                          offset: Offset(
                                                              -20.0, -20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffced2d5),
                                                          offset: Offset(
                                                              20.0, 20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        AppText(
                                                          text:
                                                              "${controller.adminController.pax[index].pax!.notation!} ",
                                                          fontSize: controller
                                                              .numberSize
                                                              .value
                                                              .sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.maroon,
                                                        ),
                                                        AppText(
                                                          text: controller
                                                              .adminController
                                                              .pax[index]
                                                              .queue!
                                                              .queueNumber!
                                                              .substring(1),
                                                          fontSize: controller
                                                              .numberSize
                                                              .value
                                                              .sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Visibility(
                                            visible: MediaQuery.of(context)
                                                    .size
                                                    .width <=
                                                600,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 20,
                                                  left: 20,
                                                  bottom: 20,
                                                ),
                                                child: Container(
                                                    width: controller
                                                        .titleSize.value.w,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffecf0f3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient:
                                                          const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xffecf0f3),
                                                          Color(0xffecf0f3),
                                                        ],
                                                      ),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffffffff),
                                                          offset: Offset(
                                                              -20.0, -20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffced2d5),
                                                          offset: Offset(
                                                              20.0, 20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.all(15),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        AspectRatio(
                                                          aspectRatio: 16 / 9,
                                                          child: Image.asset(
                                                            'assets/images/noads.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  Image.network(
                                                                controller
                                                                        .adminController
                                                                        .branch
                                                                        .value
                                                                        .brand!
                                                                        .logo ??
                                                                    'https://upload.wikimedia.org/wikipedia/commons/3/38/Solid_white_bordered.png',
                                                                width: 6.w,
                                                                height: 6.h,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: controller
                                                                      .adminController
                                                                      .branch
                                                                      .value
                                                                      .brand!
                                                                      .codeName !=
                                                                  'ST',
                                                              child: Expanded(
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/bisagroup.png',
                                                                  width: 15.w,
                                                                  height: 15.h,
                                                                  filterQuality:
                                                                      FilterQuality
                                                                          .high,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            AppText(
                                                              text: controller
                                                                  .adminController
                                                                  .branch
                                                                  .value
                                                                  .brand!
                                                                  .fullName!,
                                                              fontSize: 6.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            AppText(
                                                              text:
                                                                  '${controller.adminController.branch.value.address!}, ${controller.adminController.branch.value.city!}, ${controller.adminController.branch.value.province!}, ${controller.adminController.branch.value.country!}',
                                                              fontSize: 5.sp,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        MediaQuery.of(context).size.width >=
                                            600,
                                    child: Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                            bottom: 20,
                                          ),
                                          child: Container(
                                              width:
                                                  controller.titleSize.value.w,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffecf0f3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xffecf0f3),
                                                    Color(0xffecf0f3),
                                                  ],
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xffffffff),
                                                    offset:
                                                        Offset(-20.0, -20.0),
                                                    blurRadius: 30,
                                                    spreadRadius: 0.0,
                                                  ),
                                                  BoxShadow(
                                                    color: Color(0xffced2d5),
                                                    offset: Offset(20.0, 20.0),
                                                    blurRadius: 30,
                                                    spreadRadius: 0.0,
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(15),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: Image.asset(
                                                      'assets/images/noads.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: Image.network(
                                                          controller
                                                                  .adminController
                                                                  .branch
                                                                  .value
                                                                  .brand!
                                                                  .logo ??
                                                              'https://upload.wikimedia.org/wikipedia/commons/3/38/Solid_white_bordered.png',
                                                          width: 6.w,
                                                          height: 6.h,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: controller
                                                                .adminController
                                                                .branch
                                                                .value
                                                                .brand!
                                                                .codeName !=
                                                            'ST',
                                                        child: Expanded(
                                                          child: Image.asset(
                                                            'assets/images/bisagroup.png',
                                                            width: 15.w,
                                                            height: 15.h,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      AppText(
                                                        text: controller
                                                            .adminController
                                                            .branch
                                                            .value
                                                            .brand!
                                                            .fullName!,
                                                        fontSize: 6.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      AppText(
                                                        text:
                                                            '${controller.adminController.branch.value.address!}, ${controller.adminController.branch.value.city!}, ${controller.adminController.branch.value.province!}, ${controller.adminController.branch.value.country!}',
                                                        fontSize: 5.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ))),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                            left: 1,
                            top: 3,
                            child: GestureDetector(
                              onTap: () {
                                Get.offAllNamed(Routes.home);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                size: 30,
                                color: AppColors.grey,
                              ),
                            ))
                      ],
                    ));
      }
    });
  }
}
