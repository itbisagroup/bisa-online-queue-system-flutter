import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize; // Use a scale factor for flexibility
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final FontStyle fontStyle;
  final TextOverflow overflow;
  final int maxLines;

  const TitleText({
    Key? key,
    required this.text,
    this.fontSize = 12, // Default to normal size
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.fontStyle = FontStyle.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontFamily: 'Madelin',
        fontSize: fontSize,
        letterSpacing: 1,
        wordSpacing: 1,
        shadows: const [
          Shadow(
            blurRadius: 2.0,
            offset: Offset(2.0, 2.0),
            color: Color.fromARGB(255, 204, 204, 204),
          ),
        ],
        color: color,
        fontStyle: fontStyle,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final FontStyle fontStyle;
  final TextOverflow overflow;
  final int maxLines;

  const AppText({
    Key? key,
    required this.text,
    this.fontSize = 12.0,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.fontStyle = FontStyle.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: 'Poppins',
        letterSpacing: 1,
        wordSpacing: 1,
        color: color,
        fontStyle: fontStyle,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
