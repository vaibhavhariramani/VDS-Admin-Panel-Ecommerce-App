part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static String LOGIN_THEN(String afterSuccessfulLogin) =>
      '$LOGIN?then=${Uri.encodeQueryComponent(afterSuccessfulLogin)}';
  static const DELETION_STATUS = _Paths.DELETION_STATUS;
  static const PRODUCTS = _Paths.PRODUCTS;
  static const PRODUCTS_LISTING = _Paths.PRODUCTS_LISTING;
  static const MERCHANTS = _Paths.MERCHANTS;
  static const SHOP_LISTING = _Paths.SHOP_LISTING;
  static const ORDERS = _Paths.ORDERS;
  static const BILLING = _Paths.BILLING;
  static const CONTACT_US = _Paths.CONTACT_US;
  static const HELP = _Paths.HELP;
  static const STOREFRONT = _Paths.STOREFRONT;
  static const CUSTOMERS = _Paths.CUSTOMERS;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const DELETION_STATUS = '/deletion-status';
  static const PRODUCTS = '/products';
  static const PRODUCTS_LISTING = '/products-listing';
  static const MERCHANTS = '/merchants';
  static const SHOP_LISTING = '/shop-listing';
  static const ORDERS = '/orders';
  static const BILLING = '/billing';
  static const CONTACT_US = '/contact-us';
  static const HELP = '/help';
  static const STOREFRONT = '/storefront';
  static const CUSTOMERS = '/customers';
  static const SETTINGS = '/settings';
}
