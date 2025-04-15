import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const CustomChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Get.theme.colorScheme.primary.withOpacity(0.2),
      backgroundColor: Get.theme.colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected 
            ? Get.theme.colorScheme.primary 
            : Get.theme.colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
              ? Get.theme.colorScheme.primary 
              : Get.theme.colorScheme.outline,
        ),
      ),
    );
  }
}