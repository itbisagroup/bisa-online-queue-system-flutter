import 'package:get/get.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';

import '../routes/app_pages.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            width: 500,
            height: 500,
            child: Card(
              color: AppColors.blackCalm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Image.asset(
                    'assets/images/nointernet.webp',
                    height: 300,
                    width: 300,
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                   AppText(
                    text: 'the_server_may_not_be_active'.tr,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    color: AppColors.white,
                  ),
                   AppText(
                    text: 'continue_to_experience_issues'.tr,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.white,
                  ),
                   AppText(
                    text:
                        'contact_administrator'.tr,
                    fontSize: 12,
                    color: AppColors.white,
                    fontWeight: FontWeight.normal,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey),
                      onPressed: () {
                        Get.offAllNamed(Routes.home);
                      },
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            size: 30,
                            weight: 10,
                            color: AppColors.white,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          AppText(
                            text: 'try_again'.tr,
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
