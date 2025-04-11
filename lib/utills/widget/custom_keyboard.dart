import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final void Function(String) onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  CustomKeyboard(
      {super.key,
      required this.onTextInput,
      required this.onBackspace,
      required this.onDone});

  final List<String> _numbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ];
  final List<String> _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.map((number) {
              return _buildKey(
                number,
                backgroundColor: Colors.blueGrey[50],
                textColor: Colors.blueGrey[800],
                fontSize: 20,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Letter Keys
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _letters.map((letter) {
              return _buildKey(
                letter,
                backgroundColor: Colors.white,
                textColor: Colors.blueGrey[800],
                fontSize: 18,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Backspace Button
          // Backspace and Done Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey(
                '',
                icon: Icons.backspace,
                backgroundColor: Colors.red[400],
                onTap: onBackspace,
                width: 100,
              ),
              _buildKey(
                'Done',
                backgroundColor: Colors.green[400],
                textColor: Colors.white,
                onTap: onDone,
                width: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    String text, {
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    double? width,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => onTextInput(text),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blueGrey.withOpacity(0.2),
        highlightColor: Colors.blueGrey.withOpacity(0.1),
        child: Ink(
          width: width ?? 28,
          height: 35,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 16)
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.blueGrey[800],
                      fontSize: fontSize ?? 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
