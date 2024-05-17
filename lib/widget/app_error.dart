import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class TimeOut extends StatelessWidget {
  const TimeOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.circleExclamation,
                size: 100,
                color: AppColors.maroon,
              ),
              SizedBox(
                height: 20,
              ),
              const AppText(
                text: 'Something go wrong!',
                fontSize: 16,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: AppColors.maroon),
                  onPressed: () {
                    Get.offAllNamed(Routes.home);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 30,
                        weight: 10,
                        color: AppColors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      AppText(
                        text: 'Try Again',
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
