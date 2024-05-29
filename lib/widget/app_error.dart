import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';
import '../routes/app_pages.dart';

class TimeOut extends StatelessWidget {
  final VoidCallback onTryAgain;

  const TimeOut({Key? key, required this.onTryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.circleExclamation,
                size: 100,
                color: AppColors.maroon,
              ),
              const SizedBox(
                height: 20,
              ),
              const AppText(
                text: 'Request Time Out!',
                fontSize: 16,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                  ),
                  onPressed: onTryAgain,
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
