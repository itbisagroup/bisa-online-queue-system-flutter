import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';

class AppDialog {
  static void showDialogLoading() {
    Get.dialog(
      const Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static showToastSuccess({
    required String title,
    required String desc,
    required VoidCallback func,
  }) {
    AwesomeDialog(
      context: NavigationService.navigatorKey.currentContext!,
      closeIcon: const Icon(Icons.close, color: AppColors.grey),
      autoHide: const Duration(seconds: 2),
      dialogType: DialogType.success,
      animType: AnimType.scale,
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      descTextStyle: const TextStyle(
        fontSize: 16,
      ),
      title: title,
      desc: desc,
      width: 400,
      onDismissCallback: (type) async {
        func();
      },
    ).show();
  }

  static showToastError({
    required String title,
    required String desc,
    required VoidCallback func,
  }) {
    AwesomeDialog(
            context: NavigationService.navigatorKey.currentContext!,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: title,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            descTextStyle: const TextStyle(
              fontSize: 16,
            ),
            desc: desc,
            width: 400,
            onDismissCallback: (type) {
              func();
            },
            btnOkOnPress: () {},
            btnOkColor: AppColors.maroon)
        .show();
  }

  static showToastInfo({
    required String title,
    required String desc,
    required VoidCallback func,
  }) {
    AwesomeDialog(
            context: NavigationService.navigatorKey.currentContext!,
            dialogType: DialogType.infoReverse,
            animType: AnimType.scale,
            title: title,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            descTextStyle: const TextStyle(
              fontSize: 16,
            ),
            desc: desc,
            width: 400,
            onDismissCallback: (type) {
              func();
            },
            btnOkOnPress: () {},
            btnOkColor: AppColors.blackCalm)
        .show();
  }

  static showToastShiftEnd({
    required String title,
    required String desc,
    required VoidCallback ok,
  }) {
    AwesomeDialog(
      context: NavigationService.navigatorKey.currentContext!,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      autoHide: const Duration(minutes: 1),
      title: title,
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      descTextStyle: const TextStyle(
        fontSize: 16,
      ),
      desc: desc,
      width: 400,
      btnCancelText: 'Not Now',
      btnCancelColor: AppColors.maroon,
      btnCancelOnPress: () {},
     
      btnOkOnPress: () {
        ok();
      },
    ).show();
  }

  static void showDialogMsg({
    required String title,
    required IconData icon,
    required VoidCallback func,
    required String textFunc,
  }) async {
    await Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: Card(
                      color: AppColors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 60,
                            color: AppColors.maroon,
                          ),
                          const SizedBox(height: 20),
                          AppText(
                            text: title,
                            fontSize: 16,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: TextButton(
                              onPressed: func,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  AppText(
                                    text: textFunc,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      right: 5,
                      top: 1,
                      child: IconButton(
                          onPressed: Get.back,
                          icon:
                              const Icon(Icons.close, color: AppColors.grey))),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void confirmationMsg({
    required String title,
    required String message,
    required function,
    required String aksiText,
  }) async {
    await Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: false,
          child: Center(
            child: SizedBox(
              width: 450,
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                      text: title,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.maroon,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AppText(
                              text: message,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 35,
                                  child: MaterialButton(
                                    onPressed: () => Get.back(),
                                    color: AppColors.red,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const AppText(
                                        text: "Cancel",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 35,
                                  child: MaterialButton(
                                    onPressed: function,
                                    color: AppColors.confirm,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: AppText(
                                        text: aksiText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
