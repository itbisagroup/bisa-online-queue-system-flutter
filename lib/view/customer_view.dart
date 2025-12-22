import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/utils/audio_player.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/widget/app_loading.dart';

import 'package:queue_system/widget/app_text.dart';
import 'package:queue_system/widget/box_queue.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_control_panel/video_player_control_panel.dart';
import 'package:window_manager/window_manager.dart';

class SecondaryWindow extends StatefulWidget {
  const SecondaryWindow({
    super.key,
  });

  @override
  State<SecondaryWindow> createState() => _SecondaryWindowState();
}

class _SecondaryWindowState extends State<SecondaryWindow> with WindowListener {
  List<String> dataList = [
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-'
  ];
  List<String> nextQueueList = [
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-',
    '-'
  ];
  List<String> expiredList = [];
  Map<String, Map<String, String>> resultMap = {};
  List<String> ads = ['novideo'];
  final AudioPlayerWav audioPlayer = AudioPlayerWav();
  final LogApp _logApp = LogApp();
  String fullName = '';
  String tittleCall = '';
  bool isLoading = true;
  bool adsVideoMuted = false;
  int delayedFullscreenTimer = 1;
  int delayedFullscreenStart = 0;
  String labelCall = '';
  String pathVideo = '';
  String brand = '';
  String queueCall = '';
  int callRepeat = 0;
  String address = '';
  String city = '';
  String province = '';
  String lang = 'id';
  VideoPlayerController? controller;
  Future<void>? _initializeVideoPlayerFuture;
  int nowPlayIndex = 0;
  String logo = '';
  bool playAds = false;
  bool doFullscreen = true;
  bool isAutoFullscreen = true;
  Timer? _fullscreenTimer;

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
    if (call.method.toString() == "endShift") {
      setState(() {
        resetMapValues(resultMap);
      });
    }

    if (call.method.toString() == "withholdQueue") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        expiredList.clear();
        expiredList = List<String>.from(jsonList);
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
    if (call.method.toString() == "lang") {
      String language = jsonDecode(call.arguments as String);
      setState(() {
        lang = language;
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
    if (call.method.toString() == "maxCallQueue") {
      int jsonMap = jsonDecode(call.arguments as String);
      setState(() {
        maxCall = jsonMap;
      });
    }
    if (call.method.toString() == "doFullscreen") {
      if (playAds && isAutoFullscreen) {
        setState(() {
          _dateTimeStream = _getDateTimeStream();
          _hourTimeStream = _getHourTimeStream();
          doFullscreen = false;
        });

        if (delayedFullscreenStart == 0) {
          _startFullscreenTimer();
        } else {
          setState(() {
            delayedFullscreenStart += delayedFullscreenTimer * 60;
          });
        }
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
        if (playAds && !adsVideoMuted) {
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

  void resetMapValues(Map<String, Map<String, String>> map) {
    map.forEach((key, value) {
      value['current'] = '000';
      value['next'] = '000';
    });
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
    String formattedDate = lang == 'id'
        ? '$day, ${now.day} $month ${now.year}'
        : '$day, $month ${now.day}, ${now.year}';

    return formattedDate;
  }

  String _getFormattedHourTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  String _getDayName(int day) {
    var dayNames = {
      1: lang == 'id' ? 'Senin' : 'Monday',
      2: lang == 'id' ? 'Selasa' : 'Tuesday',
      3: lang == 'id' ? 'Rabu' : 'Wednesday',
      4: lang == 'id' ? 'Kamis' : 'Thursday',
      5: lang == 'id' ? 'Jumat' : 'Friday',
      6: lang == 'id' ? 'Sabtu' : 'Saturday',
      7: lang == 'id' ? 'Minggu' : 'Sunday',
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
    var monthNames = {
      1: lang == 'id' ? 'Januari' : 'January',
      2: lang == 'id' ? 'Februari' : 'February',
      3: lang == 'id' ? 'Maret' : 'March',
      4: lang == 'id' ? 'April' : 'April',
      5: lang == 'id' ? 'Mei' : 'May',
      6: lang == 'id' ? 'Juni' : 'June',
      7: lang == 'id' ? 'Juli' : 'July',
      8: lang == 'id' ? 'Agustus' : 'August',
      9: lang == 'id' ? 'September' : 'September',
      10: lang == 'id' ? 'Oktober' : 'October',
      11: lang == 'id' ? 'November' : 'November',
      12: lang == 'id' ? 'Desember' : 'December',
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
    setState(() {
      delayedFullscreenStart = delayedFullscreenTimer * 60;
    });
    _fullscreenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (delayedFullscreenStart > 0) {
        setState(() {
          delayedFullscreenStart--;
        });
      } else {
        setState(() {
          _fullscreenTimer?.cancel();
          doFullscreen = true;
        });
      }
    });
  }

  void updatePathVideo() async {
    final currentVideoPath =
        await const FlutterSecureStorage().read(key: 'env_path');
    final autoFullscreenTimer =
        await const FlutterSecureStorage().read(key: 'auto_fullscreen_timer');
    final adsMuted = await const FlutterSecureStorage().read(key: 'ads_muted');
    final autoFullscreen =
        await const FlutterSecureStorage().read(key: 'auto_fullscreen');
    int timerFulscreen = int.parse(autoFullscreenTimer!);
    bool muted = adsMuted == '1' ? true : false;
    setState(() {
      pathVideo = currentVideoPath ?? '';
      adsVideoMuted = muted;
      if (playAds) {
        muted ? controller!.setVolume(0.0) : controller!.setVolume(1.0);
      }
      delayedFullscreenTimer = timerFulscreen;
      isAutoFullscreen = autoFullscreen == '1' ? true : false;
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
      if (adsVideoMuted) {
        setState(() {
          controller!.setVolume(0.0);
        });
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
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false;
      });
    });
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
              body: isLoading
                  ? const AppLoading()
                  : doFullscreen && playAds && isAutoFullscreen
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
                                      color: Colors.transparent,
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
                            Padding(
                              padding: const EdgeInsets.all(
                                40.0,
                              ),
                              child: Column(
                                children: [
                                  // Header
                                  Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: CachedNetworkImage(
                                                    imageUrl: logo,
                                                    width: 30.w,
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                downloadProgress) =>
                                                            SizedBox(
                                                              width: 50,
                                                              child: CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress),
                                                            ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const SizedBox()),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Center(
                                                  child: TitleText(
                                                    text: fullName,
                                                    fontSize: 19.sp,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    StreamBuilder<String>(
                                                      stream: _dateTimeStream,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                          return AppText(
                                                            text:
                                                                snapshot.data ??
                                                                    '',
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .blackCalm,
                                                          );
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      },
                                                    ),
                                                    StreamBuilder<String>(
                                                      stream: _hourTimeStream,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                          return AppText(
                                                            text:
                                                                snapshot.data ??
                                                                    '',
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                AppColors.black,
                                                          );
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      )),
                                  // Body and Aside
                                  Expanded(
                                    flex: 15,
                                    child: Row(
                                      children: [
                                        // Main Body
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 20,
                                                  ),
                                                  child: Container(
                                                    width: double.infinity,
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
                                                    alignment: Alignment.center,
                                                    child: AppText(
                                                      text: lang == 'id'
                                                          ? 'Antrean Sekarang'
                                                          : 'Current Serving',
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 12,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20, top: 20),
                                                    child: BoxWrap(
                                                      resultMap: resultMap,
                                                    ),
                                                  )),
                                              Visibility(
                                                visible: expiredList.isNotEmpty,
                                                child: Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20, right: 20),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xffecf0f3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Color(0xffecf0f3),
                                                              Color(0xffecf0f3),
                                                            ],
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffffffff),
                                                              offset: Offset(
                                                                  -20.0, -20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xffced2d5),
                                                              offset: Offset(
                                                                  20.0, 20.0),
                                                              blurRadius: 30,
                                                              spreadRadius: 0.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            AppText(
                                                              text: lang == 'id'
                                                                  ? 'Akan Berakhir: '
                                                                  : 'Expired Soon: ',
                                                              fontSize: 5.sp,
                                                              // fontStyle: FontStyle.italic,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                child:
                                                                    DefaultTextStyle(
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          6.sp,
                                                                      color: AppColors
                                                                          .maroon,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  child:
                                                                      AnimatedTextKit(
                                                                    repeatForever:
                                                                        true,
                                                                    pause: const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    animatedTexts: [
                                                                      FadeAnimatedText(
                                                                          expiredList
                                                                              .join(', ')),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        // Aside
                                        Expanded(
                                            flex: 4,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffecf0f3),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient:
                                                      const LinearGradient(
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
                                                      offset:
                                                          Offset(-20.0, -20.0),
                                                      blurRadius: 30,
                                                      spreadRadius: 0.0,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xffced2d5),
                                                      offset:
                                                          Offset(20.0, 20.0),
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
                                                    Expanded(
                                                      flex: 5,
                                                      child: AspectRatio(
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
                                                                onPlayEnded:
                                                                    () {
                                                                  if (nowPlayIndex +
                                                                          1 >=
                                                                      ads.length) {
                                                                    // end of playlist
                                                                    if (true) {
                                                                      if (ads.length ==
                                                                          1) {
                                                                        controller!
                                                                            .seekTo(Duration.zero);
                                                                        controller!
                                                                            .play();
                                                                      } else {
                                                                        playVideo(
                                                                            0);
                                                                      }
                                                                    }
                                                                  } else {
                                                                    playNextVideo();
                                                                  }
                                                                },
                                                              )
                                                            : Image.asset(
                                                                'assets/images/novideo.webp',
                                                                fit: BoxFit
                                                                    .contain,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                              ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Visibility(
                                                        visible:
                                                            queueCall != '',
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
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
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.05,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.06,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  filterQuality:
                                                                      FilterQuality
                                                                          .high,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                AppText(
                                                                  text: lang ==
                                                                          'id'
                                                                      ? 'Perhatian!'
                                                                      : 'Attention!',
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.25,
                                                              child:
                                                                  DefaultTextStyle(
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
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
                                                                              (maxCall - 1)
                                                                          ? " $queueCall"
                                                                          : " $queueCall",
                                                                      rotateOut:
                                                                          true,
                                                                      textStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            35.sp,
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
                                                    Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          AppText(
                                                            text:
                                                                'BISA Online Queue System V.${VersionApp.version}',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          AppText(
                                                            text: lang == 'id'
                                                                ? 'BISA Group © ${DateTime.now().year}. Hak Cipta Dilindungi UU.'
                                                                : 'BISA Group © ${DateTime.now().year}. All Rights Reserved.',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 10,
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )));
    });
  }
}
