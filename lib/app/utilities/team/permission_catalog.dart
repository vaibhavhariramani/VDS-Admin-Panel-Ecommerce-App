import '../../../models/Permission.dart';

/// Human-readable labels for [Permission]'s string constants, grouped for
/// the Team screen's permissions editor. Dart has no cheap reflection over
/// a class of static const strings, so this list is maintained by hand —
/// add a row here when a new [Permission] constant is added.
class PermissionCatalogEntry {
  final String value;
  final String label;
  final String group;
  const PermissionCatalogEntry(this.value, this.label, this.group);
}

const List<PermissionCatalogEntry> kPermissionCatalog = [
  PermissionCatalogEntry(Permission.productsRead, 'View products', 'Products'),
  PermissionCatalogEntry(Permission.productsWrite, 'Create/edit products', 'Products'),
  PermissionCatalogEntry(Permission.inventoryRead, 'View inventory', 'Products'),
  PermissionCatalogEntry(Permission.inventoryWrite, 'Adjust inventory', 'Products'),
  PermissionCatalogEntry(Permission.ordersRead, 'View orders', 'Orders'),
  PermissionCatalogEntry(Permission.ordersWrite, 'Update/manage orders', 'Orders'),
  PermissionCatalogEntry(Permission.posAccess, 'Use POS / billing', 'Orders'),
  PermissionCatalogEntry(Permission.reportsRead, 'View shop reports', 'Orders'),
  PermissionCatalogEntry(Permission.shopsRead, 'View shops in region', 'Region'),
  PermissionCatalogEntry(Permission.shopsInvite, 'Invite shop admins', 'Region'),
  PermissionCatalogEntry(Permission.shopsManage, 'Manage shops in region', 'Region'),
  PermissionCatalogEntry(Permission.regionalBannersWrite, 'Manage regional banners', 'Region'),
  PermissionCatalogEntry(Permission.regionalMarketWrite, 'Manage regional market', 'Region'),
  PermissionCatalogEntry(Permission.regionalReportsRead, 'View regional reports', 'Region'),
  PermissionCatalogEntry(Permission.regionsCreate, 'Create regions', 'Country'),
  PermissionCatalogEntry(Permission.regionsManage, 'Manage regions', 'Country'),
  PermissionCatalogEntry(Permission.regionalMarketsManage, 'Manage regional markets', 'Country'),
  PermissionCatalogEntry(Permission.countryReportsRead, 'View country reports', 'Country'),
  PermissionCatalogEntry(Permission.referralsRead, 'View referrals', 'Affiliate'),
  PermissionCatalogEntry(Permission.deliveriesRead, 'View deliveries', 'Delivery'),
  PermissionCatalogEntry(Permission.deliveriesWrite, 'Accept/update deliveries', 'Delivery'),
  PermissionCatalogEntry(Permission.earningsRead, 'View rider earnings', 'Delivery'),
  PermissionCatalogEntry(Permission.platformFullAccess, 'Full platform access (Super Admin)', 'Platform'),
];
