import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:queue_system/utils/audio_player.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/log.dart';

import 'package:queue_system/widget/app_text.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_control_panel/video_player_control_panel.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:window_manager/window_manager.dart';

class SecondaryWindow extends StatefulWidget {
  const SecondaryWindow({
    super.key,
  });

  @override
  State<SecondaryWindow> createState() => _SecondaryWindowState();
}

class _SecondaryWindowState extends State<SecondaryWindow> with WindowListener {
  List<String> dataList = ['-', '-', '-', '-', '-', '-', '-', '-'];
  List<String> nextQueueList = ['-', '-', '-', '-', '-', '-', '-', '-'];
  Map<String, Map<String, String>> resultMap = {};
  List<String> ads = ['novideo'];
  final AudioPlayerWav audioPlayer = AudioPlayerWav();
  final LogApp _logApp = LogApp();
  String fullName = '';
  String tittleCall = '';
  String labelCall = '';
  String pathVideo = '';
  String brand = '';
  String queueCall = '';
  int callRepeat = 0;
  String address = '';
  String city = '';
  String province = '';
  VideoPlayerController? controller;
  Future<void>? _initializeVideoPlayerFuture;
  int nowPlayIndex = 0;
  String logo = '';
  bool playAds = false;
  bool doFullscreen = true;
  Timer? _fullscreenTimer;
  static const Duration initialDelay = Duration(minutes: 2);
  static const Duration additionalDelay = Duration(minutes: 2);
  int maxCall = 0;
  int callCount = 0;
  late Stream<String> _dateTimeStream;
  late Stream<String> _hourTimeStream;

  Future<void> _handleMethodCallback(MethodCall call, int fromWindowID) async {
    if (call.method.toString() == "updateQueue") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        dataList = List<String>.from(jsonList);
        _updateResultMap();
      });
    }
    if (call.method.toString() == "nextQueue") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        nextQueueList = List<String>.from(jsonList);
        
        _updateResultMap();
      });
    }
    if (call.method.toString() == "updateAds") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);

      setState(() {
        ads = jsonList.map((ad) => pathVideo + ad).toList();
      });
    }
    if (call.method.toString() == "updateFullname") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        fullName = jsonMap;
      });
    }
    if (call.method.toString() == "updateBrand") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        brand = jsonMap;
      });
    }
    if (call.method.toString() == "updateCallText") {
      getCallText();
    }
    if (call.method.toString() == "updatePathVideo") {
      updatePathVideo();
    }
    if (call.method.toString() == "updatePlayAds") {
      bool jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        playAds = jsonMap;
      });
      setState(() {});
      if (playAds &&
          controller == null &&
          _initializeVideoPlayerFuture == null) {
        setState(() {
          playVideo(0);
        });
      }
      if (!playAds && controller != null) {
        setState(() {
          controller = null;
          controller!.dispose();
        });
      }
    }
    if (call.method.toString() == "updateLogo") {
      String jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        logo = jsonMap;
      });
    }
    if (call.method.toString() == "callRepeat") {
      int jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        callRepeat = jsonMap;
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
    if (call.method.toString() == "doFullscreen") {
      if (playAds) {
        setState(() {
          _dateTimeStream = _getDateTimeStream();
          _hourTimeStream = _getHourTimeStream();
          doFullscreen = false;
        });
        _startFullscreenTimer();

        // Optionally extend the delay if doFullscreen is called again
        _fullscreenTimer?.cancel();
        _fullscreenTimer = Timer(
          initialDelay + additionalDelay, // Add extra delay
          () {
            setState(() {
              doFullscreen = true;
            });
          },
        );
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
      setState(() {
        queueCall = queueNumber;
        String prefix = queueCall.substring(0, 1);

        for (int i = 0; i < dataList.length; i++) {
          if (dataList[i].startsWith(prefix)) {
            dataList[i] = queueCall;
          }
        }
        _updateResultMap();
      });

      Future<void> speak() async {
        final number = separateNumbers(queueNumber);
        final letters = separateLetters(queueNumber);
        int digitCount = getDigitCount(number);
        if (playAds) {
          setState(() {});
          controller!.setVolume(0.1);

          Future.delayed(const Duration(seconds: 13), () {
            setState(() {});
            controller!.setVolume(1.0);
          });
        }
        if (digitCount < 3) {
          if (callCount == (maxCall - 1)) {
            await audioPlayer.playPlaylist([
              'assets/sounds/attention.wav',
              'assets/sounds/lastcall.wav',
              'assets/sounds/alphabet/$letters.wav',
              'assets/sounds/number/$number.wav',
              'assets/sounds/already.wav',
            ]);
          } else {
            await audioPlayer.playPlaylist([
              'assets/sounds/attention.wav',
              'assets/sounds/calling.wav',
              'assets/sounds/alphabet/$letters.wav',
              'assets/sounds/number/$number.wav',
              'assets/sounds/already.wav',
            ]);
          }
        } else if (digitCount == 3) {
          int firstDigit = getFirstDigit(int.parse(number));
          int secondDigit = getSecondDigit(int.parse(number));
          int thirdDigit = getThirdDigit(int.parse(number));
          if (callCount == (maxCall - 1)) {
            await audioPlayer.playPlaylist([
              'assets/sounds/attention.wav',
              'assets/sounds/lastcall.wav',
              'assets/sounds/alphabet/$letters.wav',
              'assets/sounds/number/$firstDigit.wav',
              'assets/sounds/number/$secondDigit.wav',
              'assets/sounds/number/$thirdDigit.wav',
              'assets/sounds/already.wav',
            ]);
          } else {
            await audioPlayer.playPlaylist([
              'assets/sounds/attention.wav',
              'assets/sounds/calling.wav',
              'assets/sounds/alphabet/$letters.wav',
              'assets/sounds/number/$firstDigit.wav',
              'assets/sounds/number/$secondDigit.wav',
              'assets/sounds/number/$thirdDigit.wav',
              'assets/sounds/already.wav',
            ]);
          }
        } else {
          await _logApp.writeLog("Queue number is invalid");
        }
      }

      Future<void> callSpeakFunction() async {
        int repeatCount = callRepeat + 1;
        for (int i = 1; i <= repeatCount; i++) {
          await speak();

          await Future.delayed(const Duration(seconds: 13));
        }
      }

      await callSpeakFunction();
    }
  }

  void _updateResultMap() {
    resultMap.clear();
    for (int i = 0; i < dataList.length; i++) {
      String currentKey = nextQueueList[i][0];
      String currentNumber = dataList[i].substring(1);
      String nextNumber = nextQueueList[i].substring(1);

      resultMap[currentKey] = {
        'current': currentNumber,
        'next': nextNumber,
      };
    }
  }

  Stream<String> _getDateTimeStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield _getFormattedDateTime();
    }
  }

  Stream<String> _getHourTimeStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield _getFormattedHourTime();
    }
  }

  String _getFormattedDateTime() {
    DateTime now = DateTime.now();
    String day = _getDayName(now.weekday);
    String month = _getMonthName(now.month);
    String formattedDate = '$day, ${now.day} $month ${now.year}';

    return formattedDate;
  }

  String _getFormattedHourTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return formattedTime;
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

  String separateLetters(String input) {
    return input.replaceAll(RegExp(r'\d+'), '');
  }

  String separateNumbers(String input) {
    String numbers = input.replaceAll(RegExp(r'[A-Za-z]+'), '');
    return int.parse(numbers).toString();
  }

  int getFirstDigit(int value) {
    return value ~/ 100;
  }

  int getSecondDigit(int value) {
    return (value ~/ 10) % 10;
  }

  int getThirdDigit(int value) {
    return value % 10;
  }

  int getDigitCount(String value) {
    return value.length;
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

  void getCallText() async {
    final title = await const FlutterSecureStorage().read(key: 'env_title');
    final label = await const FlutterSecureStorage().read(key: 'env_label');
    setState(() {
      tittleCall = title ?? '';
      labelCall = label ?? '';
    });
  }

  void _startFullscreenTimer() {
    _fullscreenTimer?.cancel(); // Cancel any existing timer
    _fullscreenTimer = Timer(initialDelay, () {
      setState(() {
        doFullscreen = true;
      });
    });
  }

  void updatePathVideo() async {
    final currentVideoPath =
        await const FlutterSecureStorage().read(key: 'env_path');

    setState(() {
      pathVideo = currentVideoPath ?? '';
    });
  }

  void playPrevVideo() {
    if (nowPlayIndex <= 0) return;
    playVideo(--nowPlayIndex);
  }

  void playNextVideo() {
    if (nowPlayIndex >= ads.length - 1) return;
    playVideo(++nowPlayIndex);
  }

  void playVideo(int index) {
    nowPlayIndex = index;
    controller?.dispose();
    var path = ads[index];
    controller = VideoPlayerController.networkUrl(Uri.parse(path));

    _initializeVideoPlayerFuture = controller!.initialize().then((value) async {
      setState(() {});
      if (!controller!.value.isInitialized) {
        await _logApp.writeLog("controller.initialize() failed");

        return;
      }

      controller!.play();
    }).catchError((e) async {
      await _logApp.writeLog("controller.initialize() error occurs: $e");
    });
  }

  void loadingInit() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        doFullscreen = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
    windowManager.addListener(this);
    _dateTimeStream = _getDateTimeStream();
    _hourTimeStream = _getHourTimeStream();

    getCallText();
    updatePathVideo();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    controller!.dispose();
    _fullscreenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              backgroundColor: const Color(0xffecf0f3),
              body: doFullscreen && playAds
                  ? Stack(
                      children: [
                        JkVideoControlPanel(
                          controller!,
                          showClosedCaptionButton: false,
                          showFullscreenButton: false,
                          showVolumeButton: false,
                          onPrevClicked: (nowPlayIndex <= 0)
                              ? null
                              : () {
                                  playPrevVideo();
                                },
                          onNextClicked: (nowPlayIndex + 1 >= ads.length)
                              ? null
                              : () {
                                  playNextVideo();
                                },
                          onPlayEnded: () {
                            if (nowPlayIndex + 1 >= ads.length) {
                              // end of playlist
                              if (true) {
                                if (ads.length == 1) {
                                  controller!.seekTo(Duration.zero);
                                  controller!.play();
                                } else {
                                  playVideo(0);
                                }
                              }
                            } else {
                              playNextVideo();
                            }
                          },
                        ),
                        Positioned(
                            bottom: 10,
                            right: 0,
                            child: IconButton(
                                hoverColor: AppColors.grey,
                                onPressed: () {
                                  setState(() {
                                    _dateTimeStream = _getDateTimeStream();
                                    _hourTimeStream = _getHourTimeStream();
                                    doFullscreen = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.fullscreen_exit,
                                  size: 30,
                                  color: AppColors.white,
                                ))),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                                hoverColor: AppColors.grey,
                                onPressed: () async {
                                  await WindowManager.instance.close();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Color.fromARGB(255, 221, 221, 221),
                                ))),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CachedNetworkImage(
                                          imageUrl: logo,
                                          height: 5.h,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              SizedBox(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const SizedBox()),
                                      Expanded(
                                        child: Center(
                                          child: TitleText(
                                            text: fullName,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          StreamBuilder<String>(
                                            stream: _dateTimeStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.active) {
                                                return AppText(
                                                  text: snapshot.data ?? '',
                                                  fontSize: 6.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.blackCalm,
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                          ),
                                          StreamBuilder<String>(
                                            stream: _hourTimeStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.active) {
                                                return AppText(
                                                  text: snapshot.data ?? '',
                                                  fontSize: 7.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.black,
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
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
                                              bottom: 15, left: 20, right: 20),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffecf0f3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: const Center(
                                              child: AppText(
                                                text: 'Queue Number',
                                                fontSize: 25,
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
                                              resultMap.length,
                                              (index) {
                                                String key = resultMap.keys
                                                    .elementAt(index);
                                                Map<String, String> values =
                                                    resultMap[key]!;
                                                double containerWidth;
                                                double containerHight = 5;
                                                double numberSize;
                                                double numberNextSize = 4;
                                                double arrowNextSize = 5;

                                                if (dataList.length == 1) {
                                                  containerWidth = 115;
                                                  numberSize = 65;
                                                  containerHight = 28;
                                                  numberNextSize = 10;
                                                  arrowNextSize = 6;
                                                } else if (dataList.length <=
                                                    4) {
                                                  containerWidth = 56;
                                                  numberSize = 50;
                                                  containerHight = 20.1;
                                                  numberNextSize = 10;
                                                  arrowNextSize = 5;
                                                } else if (dataList.length <=
                                                    6) {
                                                  containerWidth = 56;
                                                  numberSize = 30;
                                                  containerHight = 12.8;
                                                  numberNextSize = 6;
                                                  arrowNextSize = 4;
                                                } else if (dataList.length <=
                                                    9) {
                                                  containerWidth = 36;
                                                  containerHight = 12.8;
                                                  numberSize = 30;
                                                  numberNextSize = 1;
                                                  arrowNextSize = 1;
                                                } else if (dataList.length <=
                                                    12) {
                                                  containerWidth = 36;
                                                  containerHight = 9.2;
                                                  numberSize = 26;
                                                  numberNextSize = 1;
                                                  arrowNextSize = 1;
                                                } else if (dataList.length <=
                                                    16) {
                                                  containerWidth = 26.5;
                                                  containerHight = 9.2;
                                                  numberSize = 23;
                                                  numberNextSize = 1;
                                                  arrowNextSize = 1;
                                                } else if (dataList.length <=
                                                    20) {
                                                  containerWidth = 20.5;
                                                  containerHight = 9.2;
                                                  numberSize = 20;
                                                  numberNextSize = 1;
                                                  arrowNextSize = 1;
                                                } else {
                                                  containerWidth = 15;
                                                  containerHight = 7;
                                                  numberSize = 15;
                                                  numberNextSize = 1;
                                                  arrowNextSize = 1;
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    width: containerWidth.w,
                                                    height: containerHight.h,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffecf0f3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient:
                                                          const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xffecf0f3),
                                                          Color(0xffecf0f3),
                                                        ],
                                                      ),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffffffff),
                                                          offset: Offset(
                                                              -20.0, -20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              Color(0xffced2d5),
                                                          offset: Offset(
                                                              20.0, 20.0),
                                                          blurRadius: 30,
                                                          spreadRadius: 0.0,
                                                        ),
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            key == '0000'
                                                                ? AppText(
                                                                    text: '-',
                                                                    fontSize:
                                                                        numberSize
                                                                            .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .black,
                                                                  )
                                                                : AppText(
                                                                    text: key,
                                                                    fontSize:
                                                                        numberSize
                                                                            .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .black,
                                                                  ),
                                                            const SizedBox(
                                                                width: 10),
                                                            TextAnimator(
                                                              values[
                                                                  'current']!,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    numberSize
                                                                        .sp,
                                                                fontFamily:
                                                                    'Poppins',
                                                                letterSpacing:
                                                                    1,
                                                                wordSpacing: 1,
                                                                color: AppColors
                                                                    .maroon,
                                                              ),
                                                              incomingEffect: WidgetTransitionEffects
                                                                  .incomingSlideInFromBottom(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              1500)),
                                                            ),
                                                          ],
                                                        ),
                                                        Visibility(
                                                            visible: values[
                                                                        'next'] !=
                                                                    '000' &&
                                                                resultMap
                                                                        .length <=
                                                                    6,
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .anglesUp,
                                                              size:
                                                                  arrowNextSize
                                                                      .sp,
                                                            )),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Visibility(
                                                              visible: values[
                                                                          'next'] !=
                                                                      '000' &&
                                                                  resultMap
                                                                          .length <=
                                                                      6,
                                                              child: AppText(
                                                                text: key,
                                                                fontSize:
                                                                    numberNextSize
                                                                        .sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: values[
                                                                          'next'] !=
                                                                      '000' &&
                                                                  resultMap
                                                                          .length <=
                                                                      6,
                                                              child:
                                                                  TextAnimator(
                                                                values['next']!,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      numberNextSize
                                                                          .sp,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  letterSpacing:
                                                                      1,
                                                                  wordSpacing:
                                                                      1,
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                                incomingEffect:
                                                                    WidgetTransitionEffects.incomingSlideInFromBottom(
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
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        child: Container(
                                            width: 16,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffecf0f3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: playAds
                                                      ? JkVideoControlPanel(
                                                          controller!,
                                                          showClosedCaptionButton:
                                                              true,
                                                          showFullscreenButton:
                                                              true,
                                                          showVolumeButton:
                                                              true,
                                                          onPrevClicked:
                                                              (nowPlayIndex <=
                                                                      0)
                                                                  ? null
                                                                  : () {
                                                                      playPrevVideo();
                                                                    },
                                                          onNextClicked:
                                                              (nowPlayIndex +
                                                                          1 >=
                                                                      ads.length)
                                                                  ? null
                                                                  : () {
                                                                      playNextVideo();
                                                                    },
                                                          onPlayEnded: () {
                                                            if (nowPlayIndex +
                                                                    1 >=
                                                                ads.length) {
                                                              // end of playlist
                                                              if (true) {
                                                                if (ads.length ==
                                                                    1) {
                                                                  controller!.seekTo(
                                                                      Duration
                                                                          .zero);
                                                                  controller!
                                                                      .play();
                                                                } else {
                                                                  playVideo(0);
                                                                }
                                                              }
                                                            } else {
                                                              playNextVideo();
                                                            }
                                                          },
                                                        )
                                                      : Image.asset(
                                                          'assets/images/novideo.webp',
                                                          fit: BoxFit.contain,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                        ),
                                                ),
                                                Visibility(
                                                  visible: queueCall != '',
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 130),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Image.asset(
                                                              'assets/images/notif.gif',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            AppText(
                                                              text:
                                                                  'Attention!',
                                                              fontSize: 7.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: 12.h,
                                                          child:
                                                              DefaultTextStyle(
                                                            style: TextStyle(
                                                                fontSize:
                                                                    10.5.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                            child:
                                                                AnimatedTextKit(
                                                              repeatForever:
                                                                  true,
                                                              animatedTexts: [
                                                                RotateAnimatedText(callCount ==
                                                                        (maxCall -
                                                                            1)
                                                                    ? "Panggilan Terakhir"
                                                                    : tittleCall),
                                                                RotateAnimatedText(
                                                                  callCount ==
                                                                          (maxCall -
                                                                              1)
                                                                      ? " $queueCall"
                                                                      : " $queueCall",
                                                                  rotateOut:
                                                                      true,
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        33.sp,
                                                                  ),
                                                                ),
                                                                RotateAnimatedText(
                                                                    labelCall),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 20),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      AppText(
                                                        text:
                                                            'BISA Online Queue System V.0.2.1 (alpha-test)',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      AppText(
                                                        text:
                                                            'Bisagroup © 2024. All Rights Reserved. ',
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 12,
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
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
                        ),
                      ],
                    )));
    });
  }
}
