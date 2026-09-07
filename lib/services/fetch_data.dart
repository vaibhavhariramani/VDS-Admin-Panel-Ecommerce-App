import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../models/Bill.dart';
import '../models/Orders.dart';
import '../models/Product.dart';
import '../models/Shop.dart';
import '../models/UserType.dart';
import '../models/Users.dart';
import 'auth_service.dart';

class FetchService extends GetxService {
  static FetchService get to => Get.find<FetchService>();
  final storageref = FirebaseStorage.instance;
  final FirebaseFirestore Collection = FirebaseFirestore.instance;

  Future<List<Product>> fetchAllProductsByShop(String? shopId) async {
    List<Product> _products = [];
    print("Fetching Products Data according to Shop Id: $shopId");
    print(AuthService.to.isAuthenticated);
    if (AuthService.to.isAuthenticated) {
      try {
        CollectionReference productsCollection =
            Collection.collection('Products');
        print(productsCollection);
        QuerySnapshot querySnapshot =
            await productsCollection.where('shopId', isEqualTo: shopId).get();
        List<DocumentSnapshot> products = querySnapshot.docs;
        print(products.length);
        for (var productDoc in products) {
          print('Product ID: ${productDoc.id}');
          print('Product Data: ${productDoc.data()}');
          _products
              .add(Product.fromJson(productDoc.data() as Map<String, dynamic>));
          print("length of products: ${_products.length}");
          print("printing products: ${_products}");
        }
        print("checking Refreshed Value:  ");
        for (var item in _products) {
          print('$item \n\n');
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _products;
  }

  //Fetching Shop Id from User Id
  Future<String?> fetchShopId() async {
    String? userId = AuthService.to.user.value?.id;
    if (userId == null) return null;

    try {
      CollectionReference ShopsDB = Collection.collection('Shops');
      // Primary owner first (the common case, one query) - only falls back
      // to the additionalAdmins array (see firestore.rules' isShopOwner())
      // if that finds nothing, since most shops only ever have one admin
      // and don't need the second read.
      QuerySnapshot<Object?> querySnapshot =
          await ShopsDB.where("shopAdmin", isEqualTo: userId).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      querySnapshot =
          await ShopsDB.where("additionalAdmins", arrayContains: userId).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      print("No shop found for the user.");
      return null;
    } catch (e) {
      print('Error fetching shopId: $e');
      return null;
    }
  }

  Future<Shop?> fetchShopById(String shopId) async {
    try {
      final DocumentSnapshot<Object?> snap =
          await Collection.collection('Shops').doc(shopId).get();
      if (!snap.exists) return null;
      return Shop.fromJson(snap.data() as Map<String, dynamic>?, id: snap.id);
    } catch (e) {
      print('Error fetching shop $shopId: $e');
      return null;
    }
  }

  //Fetching Shop Currency from User Id
  Future<String?> fetchShopCurrency() async {
    print("running fetching Shop Current");
    String? id = AuthService.to.user.value?.id;
    try {
      CollectionReference ShopsDB = Collection.collection('Shops');
      QuerySnapshot<Object?> querySnapshot =
          await ShopsDB.where("shopAdmin", isEqualTo: id).limit(1).get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      String? shopCurr = data['currencyType'];
      Get.log("Fetched Shop currency : $shopCurr ");
      return shopCurr;
    } catch (e) {
      print('Error fetching shop currency: $e');
      return null;
    }
  }

  /// The `regionId`/`Country` to stamp onto a new Product or Bill doc,
  /// read from the shop's own doc. Products and Bills are created by this
  /// app (unlike Shops/Regions, which currently aren't), so this is where
  /// the hierarchy denormalization actually gets applied going forward —
  /// existing docs created before this need a separate backfill.
  Future<({String? regionId, String? country})> fetchShopHierarchy(
      String? shopId) async {
    if (shopId == null) return (regionId: null, country: null);
    try {
      final DocumentSnapshot<Object?> doc =
          await Collection.collection('Shops').doc(shopId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return (
        regionId: data?['regionId']?.toString(),
        country: data?['Country']?.toString(),
      );
    } catch (e) {
      print('Error fetching shop hierarchy for $shopId: $e');
      return (regionId: null, country: null);
    }
  }

  /// Region Admins (`UserType.MERCHANT`) for the signed-in Country Admin's
  /// country. Previously this went through the `Countries` collection's
  /// `RegionMerchantUserID`/`ShopsUnderMerchant` fields, which had no
  /// agreed relationship with the separate `Regions` collection that
  /// actually backs shop lookups (`DataService.FetchShopIds`) — two
  /// collections claiming the same region↔shop edge. `Regions` is now
  /// the single source of truth for that edge (see `Regions.Country` in
  /// [fetchRegionsForCountry]); this method no longer reads `Countries` at
  /// all, and instead queries `Users` directly for Region Admins sharing
  /// the Country Admin's `Country` name.
  Future<RxList<Users?>> fetchAllMERCANTS() async {
    RxList<Users?> _merchants = RxList<Users?>();

    if (AuthService.to.isAuthenticated) {
      try {
        CollectionReference UsersDB = Collection.collection('Users');
        var UserCountry = AuthService.to.user.value!.country;

        print("Fetching Merchants (Region Admins)");
        print("Users country is : $UserCountry");

        QuerySnapshot<Object?> querySnapshot = await UsersDB
            .where('userType', isEqualTo: UserType.MERCHANT.name)
            .where('Country', isEqualTo: UserCountry)
            .get();

        for (var document in querySnapshot.docs) {
          var userDataMap = document.data() as Map<String, dynamic>;
          print(userDataMap);
          print("*****************************");
          Users temp = Users(
            id: document.id,
            fullname: userDataMap['fullname'],
            img_token: userDataMap['imgToken'],
            phn_number: userDataMap['phone'],
            gmail_id: "",
            fb_id: "",
            applie_id: "",
            email: userDataMap['email'],
            phonepinID: "",
            user_type: getUserTypeFromString(userDataMap['userType']?.toString() ?? ''),
            current_language: "",
            current_lat: 0.0,
            isUserSecure: true,
            radiusPreference: 0.0,
            saved_location: "",
            current_lon: 0.0,
            managed_by: "",
            country: userDataMap['Country'],
          );
          _merchants.add(temp);
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    print("Length of list fetched from google firebase for merchants");
    print(_merchants.length);
    return _merchants;
  }

  /// Regions belonging to a Country Admin's country — requires each
  /// `Regions` doc to carry a `Country` field using the same name-string
  /// convention already on `Users.Country`. Existing `Regions` docs
  /// created before this field existed won't be returned until they're
  /// backfilled with it.
  Future<List<Map<String, dynamic>>> fetchRegionsForCountry(
      String? countryName) async {
    final List<Map<String, dynamic>> regions = [];
    if (countryName == null) return regions;
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Regions')
          .where('Country', isEqualTo: countryName)
          .get();
      for (var doc in querySnapshot.docs) {
        regions.add({'id': doc.id, ...(doc.data() as Map<String, dynamic>)});
      }
    } catch (e) {
      print('Error fetching regions for country $countryName: $e');
    }
    return regions;
  }

  /// Streams the current user's own shop's online orders only. Deliberately
  /// async-resolves shopId first rather than exposing an unscoped stream —
  /// a prior version of this method queried the whole `OnlineOrders`
  /// collection with no shop filter, leaking every shop's orders to any
  /// signed-in client.
  Stream<QuerySnapshot> OnlineOrders({String? search, String? filter}) {
    return Stream.fromFuture(fetchShopId()).asyncExpand((String? shopId) {
      if (shopId == null) return const Stream<QuerySnapshot>.empty();
      return Collection.collection('OnlineOrders')
          .where('shopId', isEqualTo: shopId)
          .orderBy('booking', descending: true)
          .snapshots();
    });
  }

  Stream<QuerySnapshot> regions(int? filter) {
    if (filter != null) {
      return Collection.collection('Regions')
          .where('pincode', isEqualTo: filter)
          .snapshots();
    } else {
      return Collection.collection('Regions').snapshots();
    }
  }

  Stream<QuerySnapshot> orderItems(String id) {
    return Collection.collection('Items')
        .where('orderID', isEqualTo: id)
        .snapshots();
  }

  Stream<QuerySnapshot> employee() {
    return Collection.collection('Employee').snapshots();
  }

  /// A single order by its own document id - used by the Order Details
  /// route (`/dashboard/orders/online/order-details/:orderId`) to resolve
  /// the order directly from the URL, so a deep link or a page refresh
  /// works even without the in-memory list the Orders table builds.
  Future<Orders?> fetchOrderById(String orderId) async {
    try {
      final DocumentSnapshot<Object?> doc =
          await Collection.collection('OnlineOrders').doc(orderId).get();
      if (!doc.exists) return null;
      return Orders.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching order $orderId: $e');
      return null;
    }
  }

  Future<RxList<Orders?>> fetchOnlineOrdersUsingShopId() async {
    RxList<Orders?> _onlineOrders = RxList<Orders?>();
    if (AuthService.to.isAuthenticated) {
      String? shopId = await fetchShopId();
      try {
        CollectionReference OnlineOrderDB =
            Collection.collection('OnlineOrders');
        QuerySnapshot<Object?> querySnapshot =
            await OnlineOrderDB.where("shopId", isEqualTo: shopId).get();
        for (var document in querySnapshot.docs) {
          var OrderData = document.data() as Map<String, dynamic>;
          // One malformed/legacy order used to take down the *entire*
          // list - a single bad document threw inside this loop with no
          // per-document try/catch, so every other (perfectly fine) order
          // silently vanished from the table too, not just the bad one.
          try {
            _onlineOrders.add(Orders.fromJson(OrderData));
          } catch (e) {
            print('Skipping order ${document.id}, failed to parse: $e');
          }
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _onlineOrders;
  }

  /// POS sales for the signed-in user's shop, from the `Bills` collection
  /// `BillingController.createBill()` writes to. Ordered newest-first;
  /// falls back to unordered if the composite index for
  /// (shopId, createdAt) hasn't been deployed yet, so the offline-orders
  /// table degrades gracefully instead of erroring outright.
  Future<RxList<Bill>> fetchOfflineOrdersUsingShopId() async {
    RxList<Bill> _offlineOrders = RxList<Bill>();
    if (!AuthService.to.isAuthenticated) return _offlineOrders;
    final String? shopId = await fetchShopId();
    if (shopId == null) return _offlineOrders;
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Bills')
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();
      _offlineOrders.addAll(querySnapshot.docs.map(Bill.fromDoc));
    } catch (e) {
      print('Ordered offline-orders query failed (index missing?), falling back to unordered: $e');
      try {
        QuerySnapshot<Object?> fallback = await Collection
            .collection('Bills')
            .where('shopId', isEqualTo: shopId)
            .get();
        final List<Bill> bills = fallback.docs.map(Bill.fromDoc).toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        _offlineOrders.addAll(bills);
      } catch (e2) {
        print('Error fetching offline orders: $e2');
      }
    }
    return _offlineOrders;
  }

  category() {
    return Collection.collection('Category')
        .snapshots(includeMetadataChanges: true);
  }
}
