import 'UserType.dart';

/// Permission keys used across the app. Stored as plain strings on
/// `Users/{uid}.permissions` in Firestore rather than a Dart enum, so new
/// keys can be added later without an enum/schema migration.
class Permission {
  Permission._();

  // Products
  static const String productsRead = 'products.read';
  static const String productsWrite = 'products.write';

  // Orders
  static const String ordersRead = 'orders.read';
  static const String ordersWrite = 'orders.write';

  // Inventory
  static const String inventoryRead = 'inventory.read';
  static const String inventoryWrite = 'inventory.write';

  // POS
  static const String posAccess = 'pos.access';

  // Reports
  static const String reportsRead = 'reports.read';

  // Region Admin (UserType.MERCHANT)
  static const String shopsRead = 'shops.read';
  static const String shopsInvite = 'shops.invite';
  static const String shopsManage = 'shops.manage';
  static const String regionalBannersWrite = 'regional_banners.write';
  static const String regionalMarketWrite = 'regional_market.write';
  static const String regionalReportsRead = 'regional_reports.read';

  // Country Admin (UserType.COUNTRY_HEAD)
  static const String regionsCreate = 'regions.create';
  static const String regionsManage = 'regions.manage';
  static const String regionalMarketsManage = 'regional_markets.manage';
  static const String countryReportsRead = 'country_reports.read';

  // Referral partner (UserType.AFFILIATES)
  static const String referralsRead = 'referrals.read';

  // Rider (UserType.RIDER) — a rider doesn't use the admin panel at all,
  // but shares the same Users/permissions model so the Delivery app's
  // Firestore access can be gated by the same rule helpers as everyone
  // else, rather than inventing a parallel authorization scheme.
  static const String deliveriesRead = 'deliveries.read';
  static const String deliveriesWrite = 'deliveries.write';
  static const String earningsRead = 'earnings.read';

  // Super Admin — a wildcard rather than every key above, since Super
  // Admin is defined as "complete platform-level control" rather than an
  // enumerable set that has to be kept in sync by hand.
  static const String platformFullAccess = 'platform.full_access';
}

/// Default permission set granted to each role. This is only a *fallback*:
/// a user's effective permissions come from their own `Users` doc's
/// `permissions` field when Firestore has one set explicitly, so an admin
/// can grant or revoke individual permissions per user. Every existing
/// `Users` doc predates this field, so today every user resolves through
/// this map until permissions are explicitly assigned.
final Map<UserType, Set<String>> kDefaultPermissionsByRole =
    <UserType, Set<String>>{
  UserType.ADMIN: <String>{Permission.platformFullAccess},
  UserType.COUNTRY_HEAD: <String>{
    Permission.regionsCreate,
    Permission.regionsManage,
    Permission.regionalMarketsManage,
    Permission.countryReportsRead,
    Permission.shopsRead,
  },
  UserType.MERCHANT: <String>{
    Permission.shopsRead,
    Permission.shopsInvite,
    Permission.shopsManage,
    Permission.regionalBannersWrite,
    Permission.regionalMarketWrite,
    Permission.regionalReportsRead,
  },
  UserType.SHOP_ADMIN: <String>{
    Permission.productsRead,
    Permission.productsWrite,
    Permission.ordersRead,
    Permission.ordersWrite,
    Permission.inventoryRead,
    Permission.inventoryWrite,
    Permission.posAccess,
    Permission.reportsRead,
  },
  UserType.AFFILIATES: <String>{
    Permission.referralsRead,
  },
  UserType.RIDER: <String>{
    Permission.deliveriesRead,
    Permission.deliveriesWrite,
    Permission.earningsRead,
  },
  UserType.CUSTOMER: <String>{},
};
