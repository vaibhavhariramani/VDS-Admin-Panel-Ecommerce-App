enum UserType {
  ADMIN,
  MERCHANT,
  CUSTOMER,
  AFFILIATES,
  COUNTRY_HEAD,
  SHOP_ADMIN,
}

/// Display labels for each role. `MERCHANT` is labeled "Region Admin" —
/// that's what the role actually does in this app (manages the shops
/// under a region) — while the Dart enum value and the Firestore-stored
/// `userType` string both stay `MERCHANT` so no data migration is needed.
extension UserTypeLabel on UserType {
  String get label {
    switch (this) {
      case UserType.ADMIN:
        return 'Super Admin';
      case UserType.COUNTRY_HEAD:
        return 'Country Admin';
      case UserType.MERCHANT:
        return 'Region Admin';
      case UserType.SHOP_ADMIN:
        return 'Shop Admin';
      case UserType.AFFILIATES:
        return 'Referral Partner';
      case UserType.CUSTOMER:
        return 'Customer';
    }
  }
}
