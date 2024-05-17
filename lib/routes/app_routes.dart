part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const auth = _Paths.auth;
  static const home = _Paths.home;
  static const customer = _Paths.customer;
  static const printer = _Paths.printer;

}

abstract class _Paths {
  _Paths._();

  static const auth = '/auth';
  static const home = '/home';
  static const customer = '/customer';
  static const printer = '/printer';


}
