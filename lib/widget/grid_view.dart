import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';

class CardCustommer extends StatelessWidget {
  final int itemCount;
  final String notation;
  final String queueNumber;

  const CardCustommer({super.key, required this.itemCount, required this.notation, required this.queueNumber});

  @override
  Widget build(BuildContext context) {
 
    double scaleFactor = 1 /
        (1 +
            itemCount *
                0.1);


    return Center(
      child: Transform.scale(
        scale: scaleFactor,
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xffecf0f3),
            borderRadius: BorderRadius.circular(10),
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
                offset: Offset(-20.0, -20.0),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(
                text: 'Queue Number',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Divider(
                  thickness: 3,
                  color: AppColors.stroke,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                        text: notation,
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon),
                    AppText(
                      text: queueNumber,
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
