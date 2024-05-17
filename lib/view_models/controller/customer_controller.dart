
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';

class CustomerController extends GetxController {
  final adminController = Get.put(AdminController());
  RxString error = ''.obs;
  final rxRequestStatus = Status.COMPLETED.obs;
  late final player = Player();
  late final controllerVideo = VideoController(player);

  var currentDate = ''.obs;
  var currentTime = ''.obs;
  var isVisible = true.obs;
  var color = Colors.black.obs;
  var isMenuOpen = false.obs;
  var playVideo = false.obs;
  var containerWidth = 0.0.obs;
  var numberSize = 0.0.obs;
  var titleSize = 0.0.obs;

  var cardIndex = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    updateTime();
    toggleVisibility();
    play();
    sizeCardQueue();

  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  void setRxRequestStatus(Status _value) => rxRequestStatus.value = _value;
  void setError(String _value) => error.value = _value;

  void toggleMenu(String id) {
    isMenuOpen.value = !isMenuOpen.value;
    cardIndex.value = id;
  }

  void play() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    if (adminController.branch.value.playAds!) {
      List<String> assetsUrls = adminController.ads.map((ad) {
        return '${documentDirectory.path}/assets/videos/${ad.content}';
      }).toList();
      final playable = Playlist(
        assetsUrls.map((url) => Media(url)).toList(),
      );

      await player.open(
        playable,
        play: true,
      );
      await player.setPlaylistMode(PlaylistMode.loop);
    }
  }

  void updateTime() {
    currentTime.value = getCurrentTimeFormatted();
    currentDate.value = getCurrentDateFormatted();
    Future.delayed(const Duration(seconds: 1), updateTime);
  }

  String getCurrentDateFormatted() {
    DateTime now = DateTime.now();
    String dayOfWeek = _getDayOfWeek(now.weekday);
    String month = _getMonth(now.month);

    return '$dayOfWeek, ${now.day} $month ${now.year} |';
  }

  String getCurrentTimeFormatted() {
    DateTime now = DateTime.now();
    String hour = _twoDigits(now.hour);
    String minute = _twoDigits(now.minute);
    String second = _twoDigits(now.second);
    return '$hour : $minute : $second';
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case DateTime.january:
        return 'Januari';
      case DateTime.february:
        return 'Februari';
      case DateTime.march:
        return 'Maret';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'Mei';
      case DateTime.june:
        return 'Juni';
      case DateTime.july:
        return 'Juli';
      case DateTime.august:
        return 'Agustus';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'Oktober';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'Desember';
      default:
        return '';
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  void toggleVisibility() async {
    await Future.delayed(Duration(seconds: 12));
    isVisible.toggle();
    toggleVisibility();
  }

  void sizeCardQueue() {
    final listItem = adminController.pax.length;
    if (listItem == 1) {
      containerWidth.value = 230;
      numberSize.value = 70;
      titleSize.value = 76;
    } else if (listItem <= 4) {
      containerWidth.value = 170;
      numberSize.value = 53;
      titleSize.value = 115;
    } else if (listItem <= 6) {
      containerWidth.value = 160;
      numberSize.value = 38;
      titleSize.value = 110;
    } else if (listItem <= 9) {
      containerWidth.value = 110;
      numberSize.value = 35;
      titleSize.value = 116;
    } else {
      containerWidth.value = 80;
      numberSize.value = 26;
      titleSize.value = 116;
    }
  }
}
