import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class BoxWrap extends StatelessWidget {
  final Map<String, Map<String, String>> resultMap;

  const BoxWrap({super.key, required this.resultMap});

  @override
  Widget build(BuildContext context) {
    // Get the constraints of the available space within the Expanded widget
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        // Determine the best fit for rows and columns based on boxCount
        int columns = (resultMap.length <= 4)
            ? 2
            : (resultMap.length <= 9)
                ? 3
                : 4;
        int rows = (resultMap.length / columns).ceil();

        // Calculate width and height for each box within the given space
        double itemWidth = (availableWidth / columns) - 14; // Adjust for spacing
        double itemHeight = (availableHeight / rows) - 12; // Adjust for spacing

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 20.0,
          children: List.generate(resultMap.length, (index) {
            String key = resultMap.keys.elementAt(index);
            Map<String, String> values = resultMap[key]!;
            return Container(
              padding: const EdgeInsets.all(20),
              width: itemWidth,
              height: itemHeight,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        key == '0000'
                            ? const AppText(
                                text: '-',
                                fontSize: 330,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              )
                            : AppText(
                                text: key,
                                fontSize: 330,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        const SizedBox(width: 10),
                        TextAnimator(
                          values['current']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 330,
                            fontFamily: 'Poppins',
                            letterSpacing: 1,
                            wordSpacing: 1,
                            color: AppColors.maroon,
                          ),
                          incomingEffect:
                              WidgetTransitionEffects.incomingSlideInFromBottom(
                                  duration: const Duration(milliseconds: 1500)),
                        ),
                      ],
                    ),
                    Visibility(
                        visible: values['next'] != '000',
                        child: const Icon(
                          FontAwesomeIcons.anglesUp,
                          size: 50,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: values['next'] != '000',
                          child: AppText(
                            text: key,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Visibility(
                          visible: values['next'] != '000',
                          child: TextAnimator(
                            values['next']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 80,
                              fontFamily: 'Poppins',
                              letterSpacing: 1,
                              wordSpacing: 1,
                              color: AppColors.black,
                            ),
                            incomingEffect: WidgetTransitionEffects
                                .incomingSlideInFromBottom(
                                    duration:
                                        const Duration(milliseconds: 1500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
