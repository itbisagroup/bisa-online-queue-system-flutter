import 'package:get/get.dart';
import 'package:queue_system/routes/middleware/key_avaliable.dart';
import 'package:queue_system/routes/middleware/key_notavaliable.dart';
import 'package:queue_system/view/admin_view.dart';
import 'package:queue_system/view/auth_view.dart';
import 'package:queue_system/view/config_view.dart';
import 'package:queue_system/view/setting_printer.dart';
import 'package:queue_system/view/shift_view.dart';


part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.auth;

  static final routes = [
    GetPage(
      name: Routes.home,
      middlewares: [KeyNotAvaliable()],
      page: () => const AdminView(),
      transition: Transition.noTransition,
    ),
   
    GetPage(
      name: Routes.auth,
      middlewares: [KeyAvaliable()],
      page: () => const AuthView(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.printer,
      middlewares: [KeyNotAvaliable()],
      page: () =>  const PrinterSettingView(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.shift,
      middlewares: [KeyNotAvaliable()],
      page: () =>  const ShiftView(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.config,
      middlewares: [KeyNotAvaliable()],
      page: () =>  const ConfigView(),
      transition: Transition.noTransition,
    ),

  ];
}
