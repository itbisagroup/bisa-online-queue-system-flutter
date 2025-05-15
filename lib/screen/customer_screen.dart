import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/widget/app_text.dart';
import 'package:window_manager/window_manager.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'dart:async';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> with WindowListener {
  bool isLoading = true;
  late Timer _timer;
  String currentDate = '';
  String currentTime = '';
  // Sample queue data
  final List<Map<String, dynamic>> preparingQueue = [];
  final List<Map<String, dynamic>> readyQueue = [];
  String currentQueue = '-';
  String outletName = '';
  String outletLogo = '';

  void _updateDateTime() {
    final now = DateTime.now();

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    setState(() {
      currentDate = '$dayName, ${now.day} $monthName ${now.year}';
      currentTime =
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _handleMethodCallback(MethodCall call, int fromWindowID) async {
    if (call.method.toString() == "outletFullName") {
      String name = call.arguments as String;
      setState(() {
        outletName = name;
      });
    }
    if (call.method.toString() == "outletLogo") {
      String logo = call.arguments as String;
      setState(() {
        outletLogo = logo;
      });
    }
    if (call.method.toString() == "currentCallingQueue") {
      String queueNumber = call.arguments as String;
      setState(() {
        currentQueue = queueNumber;
      });
    }
    if (call.method.toString() == "queueCalling") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        readyQueue.clear();
        readyQueue.addAll(
          (jsonList).map((item) => {'number': item.toString()}).toList(),
        );
      });
    }
    if (call.method.toString() == "queueWaiting") {
      List<dynamic> jsonList = jsonDecode(call.arguments as String);
      setState(() {
        preparingQueue.clear();
        preparingQueue.addAll(
          (jsonList).map((item) => {'number': item.toString()}).toList(),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime(); // langsung update pertama
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false;
      });
    });
    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _timer.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with restaurant info
            _buildRestaurantHeader(),
            const SizedBox(height: 20),

            // Current serving section
            _buildCurrentServingCard(),
            const SizedBox(height: 30),

            // Two-column queue display
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Being Prepared Section
                  Expanded(
                    child: _buildQueueSection(
                      title: 'Sedang Dipersiapkan',
                      queueList: preparingQueue,
                      titleIcon: Icons.hourglass_top,
                      color: const Color(0xFFE9A95F),
                      imageAssetPath: 'assets/images/pack.png',
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Ready to Pick Up Section
                  Expanded(
                    child: _buildQueueSection(
                      title: 'Order Siap Diambil',
                      titleIcon: Icons.check_circle,
                      queueList: readyQueue,
                      color: const Color.fromARGB(255, 111, 189, 181),
                      imageAssetPath: 'assets/images/ready.png',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: outletLogo.isNotEmpty
                          ? Image.file(
                              File(outletLogo),
                              width: 300,
                           
                              fit: BoxFit.contain,
                            )
                          : const SizedBox()),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: TitleText(
                text: outletName,
                fontSize: 50,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
                color: const Color.fromARGB(255, 51, 56, 53)
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  AppText(
                    text: currentDate,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: const Color(0xFF65766B),
                  ),
                  AppText(
                    text: currentTime,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: const Color(0xFF65766B),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentServingCard() {
    return SizedBox(
      height: 300,
      width: 350,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextAnimator(
                  currentQueue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 120,
                    letterSpacing: 1,
                    wordSpacing: 1,
                    color: Color.fromARGB(255, 51, 56, 53)
                  ),
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromBottom(
                    duration: const Duration(milliseconds: 1500),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Image.asset(
                'assets/images/call.png',
                width: 80,
                height: 80,
              ),
            ),
            const Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: AppText(
                  text: 'Panggilan Saat Ini',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 51, 56, 53)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSection({
    required String title,
    required List<Map<String, dynamic>> queueList,
    required Color color,
    required IconData titleIcon,
    required String imageAssetPath, // opsional
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
// Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  titleIcon,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: AppText(
                    text: title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Expanded dibungkus Stack
          Expanded(
            child: Stack(
              children: [
                // Konten antrian
                queueList.isEmpty
                    ? const Center(
                        child: AppText(
                          text: 'Tidak ada antrian',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF65766B),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: queueList.length <= 4 ? 200 : 120,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: queueList.length,
                        itemBuilder: (context, index) {
                          final item = queueList[index];
                          return _buildQueueItem(
                            number: item['number'],
                            color: color,
                            index: index,
                          );
                        },
                      ),

                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Image.asset(
                    imageAssetPath,
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem({
    required String number,
    required Color color,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText(
            text: number,
            textAlign: TextAlign.center,
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
