part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static String LOGIN_THEN(String afterSuccessfulLogin) =>
      '$LOGIN?then=${Uri.encodeQueryComponent(afterSuccessfulLogin)}';
  static const DELETION_STATUS = _Paths.DELETION_STATUS;
  static const PRODUCTS_LISTING = _Paths.PRODUCTS_LISTING;
  static const MATSER_LIST = _Paths.MATSER_LIST;
  static const MERCHANTS = _Paths.MERCHANTS;
  static const SHOP_LISTING = _Paths.SHOP_LISTING;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const DELETION_STATUS = '/deletion-status';
  static const PRODUCTS_LISTING = '/products-listing';
  static const MATSER_LIST = '/matser-list';
  static const MERCHANTS = '/merchants';
  static const SHOP_LISTING = '/shop-listing';
}
