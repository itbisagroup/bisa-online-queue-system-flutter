import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Get.theme.colorScheme.outline,
            ),
          ),
          filled: true,
          fillColor: Get.theme.colorScheme.surface,
        ),
      ),
    );
  }
}