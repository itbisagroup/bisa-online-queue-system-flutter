

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                          SizedBox(height: 20),
                          AppText(
                            text: title,
                            fontSize: 16,
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: TextButton(
                              onPressed:func ,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 8),
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
                          icon: const Icon(Icons.close, color: AppColors.grey))),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static showToastInfo({required String msg}) {
    var fToast = FToast();
    fToast.init(Get.overlayContext!);

    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 39, 39, 39),
          borderRadius: BorderRadius.circular(5),
        ),
        child: AppText(
          text: msg,
          maxLines: 3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }
  static showToastError({required String msg}) {
    var fToast = FToast();
    fToast.init(Get.overlayContext!);

    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:  AppColors.maroon,
          borderRadius: BorderRadius.circular(5),
        ),
        child: AppText(
          text: msg,
          maxLines: 3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  static showToastSuccess({required String msg}) {
    var fToast = FToast();
    fToast.init(Get.overlayContext!);

    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:  AppColors.blackCalm,
          borderRadius: BorderRadius.circular(5),
        ),
        child: AppText(
          text: msg,
          maxLines: 3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

}
