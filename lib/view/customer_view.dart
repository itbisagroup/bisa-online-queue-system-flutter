import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:queue_system/data/response/status.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';

import 'package:queue_system/widget/app_loading.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:sizer/sizer.dart';

class SecondaryWindow extends StatefulWidget {
  final int windowID;
  const SecondaryWindow({super.key, required this.windowID});

  @override
  State<SecondaryWindow> createState() => _SecondaryWindowState();
}

class _SecondaryWindowState extends State<SecondaryWindow> {
  List<String> dataList = ['A001', 'B001', 'C001', 'D001'];
  final FlutterTts flutterTts = FlutterTts();
  List<String> ads = [];
  String fullName = '';
  String address = '';
  String city = '';
  String province = '';
  String logo =
      'https://upload.wikimedia.org/wikipedia/commons/3/38/Solid_white_bordered.png';
  bool playAds = false;
  int maxCall = 0;
  int callCount = 0;
  String queueNumber = '';
  late Stream<String> _dateTimeStream;
  Timer? _fullscreenTimer;
  int _remainingTime = 40;
  final int _additionalTime = 40;

  late final player = Player();

  late final controller = VideoController(player);
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();

  Future<void> _handleMethodCallback(MethodCall call, int fromWindowID) async {
    if (call.method.toString() == "updateQueue") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        dataList = List<String>.from(jsonList);
      });
    }
    if (call.method.toString() == "updateAds") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        ads = List<String>.from(jsonList);
      });
    }
    if (call.method.toString() == "updateFullname") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        fullName = jsonMap;
      });
    }
    if (call.method.toString() == "updatePlayAds") {
      bool jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        playAds = jsonMap;
      });
    }
    if (call.method.toString() == "updateLogo") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        logo = jsonMap;
      });
    }
    if (call.method.toString() == "callCount") {
      int jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        callCount = jsonMap;
      });
    }
    if (call.method.toString() == "maxCallQueue") {
      int jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        maxCall = jsonMap;
      });
    }
    if (call.method.toString() == "updateScreen") {
      if (playAds) {
        key.currentState?.exitFullscreen();

        if (_fullscreenTimer != null && _fullscreenTimer!.isActive) {
          _remainingTime += _additionalTime;
        } else {
          _remainingTime = _additionalTime;
        }
        // Buat timer baru dengan waktu total yang diperbarui
        _fullscreenTimer = Timer(Duration(seconds: _remainingTime), () {
          key.currentState?.enterFullscreen();
        });
      }
    }
    if (call.method.toString() == "address") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        address = jsonMap;
      });
    }
    if (call.method.toString() == "city") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        city = jsonMap;
      });
    }
    if (call.method.toString() == "province") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        province = jsonMap;
      });
    }
    if (call.method.toString() == "callQueue") {
      String queueNumber = jsonDecode(call.arguments as String);
      Future<void> speak(String text, int queueCount) async {
        List<dynamic> languages = await flutterTts.getLanguages;
        if (languages.contains('id-ID')) {
          await flutterTts.setLanguage('id-ID');
        } else {
          await flutterTts.setLanguage('en-US');
        }
        await flutterTts.setPitch(1.0);
        await flutterTts.setVolume(100);
        await flutterTts.setSpeechRate(0.5);
        final audio = AudioPlayer();
        await audio.play(AssetSource('sounds/attention.mp3'));
        await audio.onPlayerComplete.first;
        if (languages.contains('id-ID')) {
          if (queueCount == (maxCall - 1)) {
            final textSpeak = 'Panggilan Terakhir! Antrian Nomor! $text !';
            await flutterTts.speak(textSpeak);
          } else {
            final textSpeak = 'Antrian Nomor! $text!';
            await flutterTts.speak(textSpeak);
          }
        } else {
          if (queueCount == maxCall - 1) {
            final textSpeak = 'Last Call! Queue Number! $text !';
            await flutterTts.speak(textSpeak);
          } else {
            final textSpeak = 'Queue Number! $text!';
            await flutterTts.speak(textSpeak);
          }
        }
      }

      await speak(queueNumber, callCount);
      if (playAds) {
        await player.setVolume(35);
        Timer(Duration(seconds: 4), () {
          player.setVolume(100);
        });
      }
    }
  }

  Stream<String> _getDateTimeStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield _getFormattedDateTime();
    }
  }

  String _getFormattedDateTime() {
    DateTime now = DateTime.now();
    String day = _getDayName(now.weekday);
    String month = _getMonthName(now.month);
    String formattedDate = '$day, ${now.day} $month ${now.year}';
    String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '$formattedDate | $formattedTime';
  }

  String _getDayName(int day) {
    const dayNames = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return dayNames[day] ?? '';
  }

  String _getMonthName(int month) {
    const monthNames = {
      1: 'Januari',
      2: 'Februari',
      3: 'Maret',
      4: 'April',
      5: 'Mei',
      6: 'Juni',
      7: 'Juli',
      8: 'Agustus',
      9: 'September',
      10: 'Oktober',
      11: 'November',
      12: 'Desember',
    };
    return monthNames[month] ?? '';
  }

  void play() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    if (playAds) {
      List<String> assetsUrls = ads.map((ad) {
        return '${documentDirectory.path}/assets/videos/${ad}';
      }).toList();

      final playable = Playlist(
        assetsUrls.map((url) => Media(url)).toList(),
      );

      await player.open(playable);
      await player.setPlaylistMode(PlaylistMode.loop);
    }
  }

  @override
  void initState() {
    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
    Timer(Duration(seconds: 4), () {
      if (playAds) {
        play();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          key.currentState?.enterFullscreen();
        });
      }
    });
    super.initState();
    _dateTimeStream = _getDateTimeStream();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              backgroundColor: const Color(0xffecf0f3),
              body: playAds ? _playAdsView() : _notPlayAds()));
    });
  }

  Column _notPlayAds() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                      text: fullName,
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    StreamBuilder<String>(
                      stream: _dateTimeStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          return AppText(
                            text: snapshot.data ?? '',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    const SizedBox(width: 6.0),
                  ],
                ))),
        Expanded(
          flex: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 20, right: 20),
                      child: Container(
                        width: double.infinity,
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
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: const Center(
                          child: AppText(
                            text: 'Queue Number',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          dataList.length,
                          (index) {
                            List<String> initialLetters =
                                dataList.map((item) => item[0]).toList();
                            List<String> valuesAfterInitial = dataList
                                .map((item) => item.substring(1))
                                .toList();
                            double containerWidth;
                            double numberSize;

                            if (dataList.length == 1) {
                              containerWidth = 125;
                              numberSize = 70;
                            } else if (dataList.length <= 4) {
                              containerWidth = 60;
                              numberSize = 60;
                            } else if (dataList.length <= 6) {
                              containerWidth = 60;
                              numberSize = 37;
                            } else if (dataList.length <= 9) {
                              containerWidth = 38;
                              numberSize = 37;
                            } else {
                              containerWidth = 27;
                              numberSize = 25;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: containerWidth.w,
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
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    dataList[index] == '0000'
                                        ? AppText(
                                            text: '-',
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          )
                                        : AppText(
                                            text: initialLetters[index],
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                    SizedBox(width: 10),
                                    dataList[index] == '0000'
                                        ? SizedBox()
                                        : AppText(
                                            text: valuesAfterInitial[index],
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.maroon,
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      bottom: 20,
                    ),
                    child: Container(
                        width: 16,
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
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                'assets/images/noads.gif',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      logo,
                                      width: 6.w,
                                      height: 6.h,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  // Visibility(
                                  //   visible: controller
                                  //           .adminController
                                  //           .branch
                                  //           .value
                                  //           .brand!
                                  //           .codeName !=
                                  //       'ST',
                                  //   child: Expanded(
                                  //     child: Image.asset(
                                  //       'assets/images/bisagroup.png',
                                  //       width: 15.w,
                                  //       height: 15.h,
                                  //       filterQuality:
                                  //           FilterQuality.high,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DefaultTextStyle(
                                    style: const TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blackCalm),
                                    textAlign: TextAlign.center,
                                    child: AnimatedTextKit(
                                      repeatForever: true,
                                      animatedTexts: [
                                        RotateAnimatedText(fullName),
                                        RotateAnimatedText(address),
                                        RotateAnimatedText(city),
                                        RotateAnimatedText(province),
                                      ],
                                    ),
                                  ),
                                  // AppText(
                                  //   text:
                                  //       '${controller.adminController.branch.value.address!}, ${controller.adminController.branch.value.city!}, ${controller.adminController.branch.value.province!}, ${controller.adminController.branch.value.country!}',
                                  //   fontSize: 5.sp,
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ))),
              )
            ],
          ),
        ),
      ],
    );
  }

  Column _playAdsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                      text: fullName,
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    StreamBuilder<String>(
                      stream: _dateTimeStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          return AppText(
                            text: snapshot.data ?? '',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    const SizedBox(width: 6.0),
                  ],
                ))),
        Expanded(
          flex: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 20, right: 20),
                      child: Container(
                        width: double.infinity,
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
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: const Center(
                          child: AppText(
                            text: 'Queue Number',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          dataList.length,
                          (index) {
                            List<String> initialLetters =
                                dataList.map((item) => item[0]).toList();
                            List<String> valuesAfterInitial = dataList
                                .map((item) => item.substring(1))
                                .toList();
                            double containerWidth;
                            double numberSize;

                            if (dataList.length == 1) {
                              containerWidth = 125;
                              numberSize = 70;
                            } else if (dataList.length <= 4) {
                              containerWidth = 60;
                              numberSize = 60;
                            } else if (dataList.length <= 6) {
                              containerWidth = 60;
                              numberSize = 37;
                            } else if (dataList.length <= 9) {
                              containerWidth = 38;
                              numberSize = 37;
                            } else {
                              containerWidth = 27;
                              numberSize = 25;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: containerWidth.w,
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
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    dataList[index] == '0000'
                                        ? AppText(
                                            text: '-',
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          )
                                        : AppText(
                                            text: initialLetters[index],
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                    SizedBox(width: 10),
                                    dataList[index] == '0000'
                                        ? SizedBox()
                                        : AppText(
                                            text: valuesAfterInitial[index],
                                            fontSize: numberSize.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.maroon,
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      bottom: 20,
                    ),
                    child: Container(
                        width: 16,
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
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AspectRatio(
                                aspectRatio: 16 / 9,
                                child: MaterialVideoControlsTheme(
                                    normal: MaterialVideoControlsThemeData(
                                      topButtonBar: topBar(context),
                                    ),
                                    fullscreen: MaterialVideoControlsThemeData(
                                      topButtonBar: topBar(context),
                                    ),
                                    child: // Wrap [Video] widget with [MaterialDesktopVideoControlsTheme].
                                        MaterialDesktopVideoControlsTheme(
                                            normal:
                                                MaterialDesktopVideoControlsThemeData(
                                              topButtonBar: topBar(context),
                                            ),
                                            fullscreen:
                                                MaterialDesktopVideoControlsThemeData(
                                              topButtonBar: topBar(context),
                                            ),
                                            child: Video(
                                              key: key,
                                              controller: controller,
                                              onEnterFullscreen: () async {
                                                await defaultEnterNativeFullscreen();
                                              },
                                              onExitFullscreen: () async {
                                                await defaultExitNativeFullscreen();
                                              },
                                            )))
                                // Video(
                                //   controller: controller,
                                // ),
                                ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      logo,
                                      width: 6.w,
                                      height: 6.h,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                  // Visibility(
                                  //   visible: controller
                                  //           .adminController
                                  //           .branch
                                  //           .value
                                  //           .brand!
                                  //           .codeName !=
                                  //       'ST',
                                  //   child: Expanded(
                                  //     child: Image.asset(
                                  //       'assets/images/bisagroup.png',
                                  //       width: 15.w,
                                  //       height: 15.h,
                                  //       filterQuality:
                                  //           FilterQuality.high,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DefaultTextStyle(
                                    style: const TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blackCalm),
                                    textAlign: TextAlign.center,
                                    child: AnimatedTextKit(
                                      repeatForever: true,
                                      animatedTexts: [
                                        RotateAnimatedText(fullName),
                                        RotateAnimatedText(address),
                                        RotateAnimatedText(city),
                                        RotateAnimatedText(province),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> topBar(BuildContext context) {
    return [
      MaterialDesktopCustomButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (key.currentState?.isFullscreen() ?? false) {
            key.currentState?.exitFullscreen();
          }
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      const Spacer(),
    ];
  }
}
