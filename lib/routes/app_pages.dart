import 'package:get/get.dart';
import 'package:pickup_queue_system/routes/middleware/outlet_avaliable.dart';
import 'package:pickup_queue_system/routes/middleware/outlet_not_avaliable.dart';

import 'package:pickup_queue_system/screen/home_screen.dart';
import 'package:pickup_queue_system/screen/initial_screen.dart';
import 'package:pickup_queue_system/screen/shift_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      middlewares: [OutletNotAvaliable()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.shift,
      page: () => const ShiftScreen(),
      middlewares: [OutletNotAvaliable()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.initial,
      middlewares: [Outletavaliable()],
      page: () => const InitialScreen(),
      transition: Transition.noTransition,
    ),
    
  ];
}
