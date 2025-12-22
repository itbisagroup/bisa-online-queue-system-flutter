import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';

class DialogError extends StatelessWidget {
  final VoidCallback onTryAgain;
  final String title;
  final String description;
  final PreferredSize appBar;

  const DialogError(
      {super.key,
      required this.onTryAgain,
      required this.title,
      required this.appBar,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Card(
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
                  AppText(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: AppText(
                      text: description,
                      fontSize: 16,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextButton.icon(
                      onPressed: onTryAgain,
                      icon: const Icon(
                        Icons.refresh,
                        size: 30,
                        color: AppColors.maroon,
                      ),
                      label:  AppText(
                        text: 'try_again'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShiftNotFound extends StatelessWidget {
  final VoidCallback onTryAgain;
  final String title;
  final String description;
  final PreferredSize appBar;

  const ShiftNotFound(
      {super.key,
      required this.onTryAgain,
      required this.title,
      required this.appBar,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Card(
            color: AppColors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: Image.asset(
                  'assets/images/newshift.webp',
                  fit: BoxFit.fitWidth,
                  height: 300,
                )),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onTryAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blackCalm,
                      ),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: 'open_new_shift_now'.tr,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.arrow_circle_right,
                            size: 30,
                            color: AppColors.white,
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
      ),
    );
  }
}
