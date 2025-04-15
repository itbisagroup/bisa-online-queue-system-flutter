import 'package:flutter/material.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/widget/app_text.dart';
import 'package:window_manager/window_manager.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> with WindowListener {
  // Sample queue data
  final List<Map<String, dynamic>> preparingQueue = [

  ];

  final List<Map<String, dynamic>> readyQueue = [
    {'number': 'A097', 'time': '10:15 AM'},
    {'number': 'A098', 'time': '10:18 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A099', 'time': '10:20 AM'},
    {'number': 'A100', 'time': '10:21 AM'},
  ];

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
                      title: 'SEDANG DIPERSIAPKAN',
                      queueList: preparingQueue,
                      titleIcon: Icons.hourglass_top,
                      color: Colors.orange[800]!,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Ready to Pick Up Section
                  Expanded(
                    child: _buildQueueSection(
                      title: 'ORDER SIAP DIAMBIL',
                      titleIcon: Icons.check_circle,
                      queueList: readyQueue,
                      color: AppColors.confirm,
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
                    child: Image.asset(
                      'assets/images/sushi-tei.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 4,
              child: TitleText(
                text: 'Sushi Tei Teuku Daud',
                fontSize: 50,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(
              child: Column(
                children: [
                  AppText(
                    text: 'Selasa, 10 Oktober 2023',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                  AppText(
                    text: '10:30 AM',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
        child: Column(
          children: [
            AppText(
              text: 'PANGGILAN SAAT INI',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
             SizedBox(
              width: 250,
               child: Divider(
                color: AppColors.black,
                thickness: 1, // Ketebalan
                height: 20, // Jarak vertikal
                           ),
             ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AppText(
                text: 'A100',
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
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
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
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
          Expanded(
            child: queueList.isEmpty
                ? const Center(
                    child: AppText(
                      text: 'Tidak ada antrian',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          queueList.length <= 4 ? 200 : 120, // Responsif
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

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
