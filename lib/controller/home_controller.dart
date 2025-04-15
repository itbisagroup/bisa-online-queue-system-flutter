import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:pickup_queue_system/data/model/test_model.dart';

class HomeController extends GetxController {
  var dataList = <DataModel>[].obs;
  var filteredList = <DataModel>[].obs;
  var selectedStatus = 'All'.obs;
  var searchQuery = ''.obs;
  var isLoading = true.obs;

  var queue = ''.obs;
  var description = ''.obs;

  var activeField = ''.obs; // "queue", "description", atau "search"

  final List<String> statusOptions = [
    'All',
    'Pending',
    'Processing',
    'Completed',
    'Rejected',
    'On Hold',
  ];

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
    ever(selectedStatus, (_) => filterData());
    ever(searchQuery, (_) => filterData());
  }

  void setActiveField(String field) {
    activeField.value = field;
  }

  void addCharacter(String char) {
    switch (activeField.value) {
      case 'queue':
        queue.value += char;
        break;
      case 'description':
        description.value += char;
        break;
      case 'search':
        searchQuery.value += char;
        break;
    }
  }

  void backspace() {
    switch (activeField.value) {
      case 'queue':
        if (queue.isNotEmpty) {
          queue.value = queue.value.substring(0, queue.value.length - 1);
        }
        break;
      case 'description':
        if (description.isNotEmpty) {
          description.value =
              description.value.substring(0, description.value.length - 1);
        }
        break;
      case 'search':
        if (searchQuery.isNotEmpty) {
          searchQuery.value =
              searchQuery.value.substring(0, searchQuery.value.length - 1);
        }
        break;
    }
  }

  void done() {
    Get.snackbar(
      'Done',
      'Queue: ${queue.value}, Description: ${description.value}, Search: ${searchQuery.value}',
    );
    activeField.value = '';
  }

  Future<void> openCustomerWindow() async {
    Size size = await DesktopWindow.getWindowSize();
    final x = size.width + 100;

    DesktopMultiWindow.createWindow(jsonEncode({'args1': 'Sub window'}))
        .then((value) async {
      value
        ..setFrame(Rect.fromLTWH(x, 0, 600, 600))
        ..setTitle("")
        ..show();
    });
  }

  void printSomething() {
    Get.snackbar(
      'Print',
      'Queue: ${queue.value}, Description: ${description.value}, Search: ${searchQuery.value}',
    );
  }

  void loadDummyData() {
    dataList.assignAll([
      DataModel(
        id: 1,
        title: 'B110',
        description: 'GOJEK',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Pending',
        keyInfo: '8',
      ),
      DataModel(
        id: 2,
        title: 'HD110',
        description: 'SHOPEE FOOD',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Processing',
        keyInfo: '8',
      ),
      DataModel(
        id: 3,
        title: 'C120',
        description: 'GRAB',
        date: DateTime.now(),
        status: 'Completed',
        keyInfo: '8',
      ),
      DataModel(
        id: 4,
        title: 'C110',
        description: 'GRAB',
        date: DateTime.now().add(const Duration(days: 1)),
        status: 'On Hold',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'GOJEK',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'GOJEK',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'Maemunah',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'SHOPEE FOOD',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'GRAB',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'GRAB',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: '',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
      DataModel(
        id: 5,
        title: 'B120',
        description: 'SHOPEE FOOD',
        date: DateTime.now().add(const Duration(days: 2)),
        status: 'Rejected',
        keyInfo: '8',
      ),
    ]);

    filterData();
  }

  void filterData() {
    filteredList.assignAll(dataList.where((data) {
      final matchesStatus =
          selectedStatus.value == 'All' || data.status == selectedStatus.value;
      final matchesSearch =
          data.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              data.description
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase());
      return matchesStatus && matchesSearch;
    }));
  }

  void updateStatus(int id, String newStatus) {
    final index = dataList.indexWhere((item) => item.id == id);
    if (index != -1) {
      dataList[index] = dataList[index].copyWith(status: newStatus);
      filterData();
    }
  }

  void addNewData(DataModel newData) {
    dataList.add(newData);
    filterData();
  }
}

extension DataModelExtension on DataModel {
  DataModel copyWith({
    String? title,
    String? description,
    String? status,
    String? keyInfo,
  }) {
    return DataModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date,
      status: status ?? this.status,
      keyInfo: keyInfo ?? this.keyInfo,
    );
  }
}
