import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;
import 'package:vdsadmin/models/ProductDealType.dart';
import 'package:vdsadmin/models/UserStatus.dart';

import '../models/InvitedUser.dart';
import '../models/InvitedUserStatus.dart';
import '../models/Product.dart';
import '../models/Shop.dart';
import '../models/UserType.dart';
import '../models/Users.dart';
import 'auth_service.dart';
import 'fetch_data.dart';

class DataService extends GetxService {
  static DataService get to => Get.find<DataService>();
  final storageref = FirebaseStorage.instance;
  final FirebaseFirestore Collection = FirebaseFirestore.instance;

  int invitedUserCount = 0;

  Future<String> uploadImage(String imagename) async {
    FilePickerResult? result = (await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      type: FileType.image,
    ));
    if (result != null) {
      Get.log("got file");
      Uint8List? doc = result.files.first.bytes;
      String ext = result.files.first.name.split('.').last;
      print('${result.files.first.name.split('.').last}---------');
      Reference ref =
          storageref.ref().child('images/ProfileImages/$imagename.$ext');
      print('uploading');
      await ref.putData(
        doc!,
        SettableMetadata(
          contentType: mime(ext),
        ),
      );
      String url = await ref.getDownloadURL();
      print('upload Complete $url');
      return url;
    } else {
      return "";
    }
  }

  Future<String> uploadImage1(String imagename) async {
    FilePickerResult? result = (await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    ));
    if (result != null) {
      Get.log("got file");
      Uint8List? doc = result.files.first.bytes;
      String ext = result.files.first.name.split('.').last;
      print('${result.files.first.name.split('.').last}---------');
      Reference ref =
          storageref.ref().child('images/dataImages/$imagename.$ext');
      print('uploading');
      await ref.putData(
        doc!,
        SettableMetadata(
          contentType: mime(ext),
        ),
      );
      String url = await ref.getDownloadURL();
      print('upload Complete $url');
      return url;
    } else {
      return "";
    }
  }

  static String getFileNameFromURL(String url) {
    String fileName = url.replaceAll(
        RegExp(
            r'https://firebasestorage.googleapis.com/v0/b/cucumia-369c1.appspot.com/o/'),
        '');

    if (fileName.contains("Profile_Images")) {
      return path.basename("/" +
          fileName.split('?').first.split("3A%20").last.replaceAll('%', ' '));
    } else {
      return path
          .basename("/" + fileName.split('?').first)
          .replaceAll('Banners%2F', '')
          .replaceAll('%20', ' ')
          .split('2F')
          .last
          .toUpperCase();
    }
  }

  static Future<String?> loadImageFromNetwork(String image) async {
    if (image != 'null') {
      try {
        return await http.get(Uri.parse(image)).then(
          (_response) {
            final String _data = base64Encode(_response.bodyBytes);
            return _data;
          },
        );
      } catch (e) {
        print(e);
      }
    }

    return null;
  }

  Future<String> uploadImageNamed(String imagename) => uploadImage(imagename);

  Future<List<Product>> fetchAllProducts() async {
    final String? shopId = await FetchService.to.fetchShopId();
    return await FetchService.to.fetchAllProductsByShop(shopId);
  }

  /// Resolves a Products document either by its Firestore doc id, or (for
  /// products created before doc-id/barcode were unified) by its `barcode`
  /// field, since [Product.id] is populated from `barcode` when the app
  /// reads products back (see Product.fromJson).
  Future<DocumentReference<Object?>?> _productDocRef(String productId) async {
    final DocumentReference<Object?> byId =
        Collection.collection('Products').doc(productId);
    final DocumentSnapshot<Object?> byIdSnap = await byId.get();
    if (byIdSnap.exists) {
      return byId;
    }
    final QuerySnapshot<Object?> byBarcode = await Collection
        .collection('Products')
        .where('barcode', isEqualTo: productId)
        .limit(1)
        .get();
    if (byBarcode.docs.isNotEmpty) {
      return byBarcode.docs.first.reference;
    }
    return null;
  }

  //Fetching List of Scheduled Products
  Future<List<Product>> fetchAllScheduledProducts(String? shopId) async {
    Get.log("Fetching Scheduled Products Data");
    List<Product> _ScheduledDataList = [];
    final DateTime now = DateTime.now();
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Products')
          .where('shopId', isEqualTo: shopId)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final bool isPublished = data['isPublished'] == true;
        final Timestamp? availableFrom = data['availableFrom'] as Timestamp?;
        if (isPublished &&
            availableFrom != null &&
            availableFrom.toDate().isAfter(now)) {
          _ScheduledDataList.add(Product.fromJson(data));
        }
      }
    } catch (e) {
      print('Error fetching scheduled products: $e');
    }
    return _ScheduledDataList;
  }

  //Fetching List of Published Products
  Future<List<Product>> fetchAllPublishedProducts(String? shopId) async {
    Get.log("Fetching Published Products Data");
    List<Product> _PublishedDataList = [];
    final DateTime now = DateTime.now();
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Products')
          .where('shopId', isEqualTo: shopId)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final bool isPublished = data['isPublished'] == true;
        final Timestamp? availableFrom = data['availableFrom'] as Timestamp?;
        final Timestamp? expiresOn = data['expiresOn'] as Timestamp?;
        final bool started =
            availableFrom == null || !availableFrom.toDate().isAfter(now);
        final bool notExpired =
            expiresOn == null || expiresOn.toDate().isAfter(now);
        if (isPublished && started && notExpired) {
          _PublishedDataList.add(Product.fromJson(data));
        }
      }
    } catch (e) {
      print('Error fetching published products: $e');
    }
    return _PublishedDataList;
  }

  //Fetching List of Products according to product type
  Future<List<Product>> fetchAllProductsaccordingProductType({
    String? shopId,
    required ProductDealType deal_type,
  }) async {
    Get.log("Fetching Products Data according to Product Type");
    List<Product> _DataList = [];
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Products')
          .where('shopId', isEqualTo: shopId)
          .where('dealType', isEqualTo: deal_type.name)
          .get();
      for (var doc in querySnapshot.docs) {
        _DataList.add(Product.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Error fetching products by deal type: $e');
    }
    return _DataList;
  }

  /// Shops belonging to the signed-in Region Admin (`UserType.MERCHANT`),
  /// resolved via `Regions.RegionHeadID` — `Regions` is the canonical
  /// region↔shop edge (see [FetchService.fetchAllMERCANTS]). This used to
  /// have four separate bugs that meant it could never actually return a
  /// populated shop: a `List` cast onto a `String?` variable, a
  /// `!= Null` check that compared against the *type* `Null` instead of
  /// the value `null` (always true, so it always tried to read a
  /// possibly-nonexistent doc), and a `Future<Users>` cast directly `as
  /// Users` instead of being awaited — all fixed below.
  Future<List<Map<Shop, Users?>>> FetchShopIds({
    String? userId,
  }) async {
    List<Map<Shop, Users?>> _Supershops = [];
    if (AuthService.to.isAuthenticated) {
      try {
        CollectionReference RegionDB = Collection.collection('Regions');
        CollectionReference ShopsDB = Collection.collection('Shops');
        UserType? userType = AuthService.to.user.value!.user_type;
        var UserID = AuthService.to.user.value!.id;
        List<String?> shopIDs = [];
        List<String?> ShopsUnderMerchant =
            (AuthService.to.user.value!.shops as List<dynamic>)
                .map((e) => e as String?)
                .toList();
        shopIDs.addAll(ShopsUnderMerchant);
        if (userType == UserType.MERCHANT) {
          QuerySnapshot<Object?> querySnapshot =
              await RegionDB.where("RegionHeadID", isEqualTo: UserID).get();

          print("if user type is MERCHANT Fetching Region Details");
          print("Users Region is : ${querySnapshot.docs}");
          print("priting list of shops under him: ${querySnapshot.docs}----->");

          for (var document in querySnapshot.docs) {
            var RegionalData = document.data() as Map<String, dynamic>;
            final List<dynamic>? shopsList =
                RegionalData['ShopsList'] as List<dynamic>?;
            if (shopsList != null) {
              shopIDs.addAll(shopsList.map((e) => e as String?));
            }
          }
        }
        for (var shopId in shopIDs) {
          DocumentSnapshot<Object?> querySnapshot =
              await ShopsDB.doc(shopId).get();
          if (querySnapshot.data() != null) {
            var ShopsDataMap = querySnapshot.data() as Map<String, dynamic>;
            print(ShopsDataMap);
            print("*****************************");
            Shop tempShop = Shop(
                id: ShopsDataMap['id'],
                name: ShopsDataMap['name'],
                img_token: ShopsDataMap['imgToken'],
                phn_number: ShopsDataMap['phone_number'],
                opening_time: ShopsDataMap['opening_time'],
                closing_time: ShopsDataMap['closing_time'],
                phonepinID: ShopsDataMap['phonepinID'],
                usersID: ShopsDataMap['shopAdmin'],
                shopcategoryID: ShopsDataMap['ShopCategory'],
                current_lon: ShopsDataMap['longitude'],
                current_lat: ShopsDataMap['latitude'],
                address: ShopsDataMap['address'],
                radiusPreference: ShopsDataMap['radiusPreference'],
                url: ShopsDataMap['url'],
                saved_location: "saved_location",
                rating: ShopsDataMap['rating'],
                managed_by: ShopsDataMap['shopAdmin'],
                renewed_on: ShopsDataMap['subscription']
                    ['subcription_subcribed_date'],
                expiry_date: ShopsDataMap['subscription']
                    ['subcription_expiry_date'],
                currency_type: ShopsDataMap['currencyType'],
                is_active: ShopsDataMap['isactive']);
            Users? tempUser =
                await AuthService.to.fetchUserDetails(tempShop.manager);
            _Supershops.add({tempShop: tempUser});
          }
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    print("Length of list fetched from google firebase for Shops Details");
    print(_Supershops.length);
    return _Supershops;
  }

  Future<Users?> FetchUpdatedData({
    required String id,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return null;
    }
    try {
      return await AuthService.to.fetchUserDetails(id);
    } catch (e) {
      print('Error fetching user $id: $e');
      return null;
    }
  }

  Future<bool> updateProductData({
    required String id,
    required String product_name,
    required double price,
    required DateTime available_from,
    required DateTime expire_on,
    required double discount,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return false;
    }
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.update({
        'name': product_name,
        'price': price,
        'discount': discount,
        'availableFrom': Timestamp.fromDate(available_from),
        'expiresOn': Timestamp.fromDate(expire_on),
      });
      await CreateLogs(action: "$product_name Product Edited");
      return true;
    } catch (e) {
      print('Error updating product $id: $e');
      return false;
    }
  }

  Future<bool> updateHotDealProductData({
    required String id,
    required String product_name,
    required double price,
    required DateTime available_from,
    required DateTime expire_on,
    required double discount,
    required DateTime startson,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return false;
    }
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.update({
        'name': product_name,
        'price': price,
        'discount': discount,
        'availableFrom': Timestamp.fromDate(available_from),
        'expiresOn': Timestamp.fromDate(expire_on),
        'startDate': Timestamp.fromDate(startson),
      });
      await CreateLogs(action: "$product_name Product Edited");
      return true;
    } catch (e) {
      print('Error updating hot deal product $id: $e');
      return false;
    }
  }

  Future<bool> scheduleProductData({
    required String id,
    required DateTime available_from,
    required DateTime expire_on,
  }) async {
    print('\n \n Scheduling product for future');
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.update({
        'availableFrom': Timestamp.fromDate(available_from),
        'expiresOn': Timestamp.fromDate(expire_on),
        'isPublished': true,
      });
      await CreateLogs(action: " Product Scheduled");
      return true;
    } catch (e) {
      print('Error scheduling product $id: $e');
      return false;
    }
  }

  Future<bool> productDelete({
    required String id,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return false;
    }
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.delete();
      await CreateLogs(action: "Product Deleted");
      return true;
    } catch (e) {
      print('Error deleting product $id: $e');
      return false;
    }
  }

  Future<bool> productUnpublish({
    required String id,
  }) async {
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.update({'isPublished': false});
      await CreateLogs(action: "Product Unpublished ");
      return true;
    } catch (e) {
      print('Error unpublishing product $id: $e');
      return false;
    }
  }

  Future<bool> publishNow(String productId) async {
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(productId);
      if (ref == null) return false;
      await ref.update({
        'availableFrom': Timestamp.now(),
        'isPublished': true,
      });
      await CreateLogs(action: "Product Published");
      return true;
    } catch (e) {
      print('Error publishing product $productId: $e');
      return false;
    }
  }

  Future<bool> updateProductStatus(String id, bool isPublished) async {
    try {
      final DocumentReference<Object?>? ref = await _productDocRef(id);
      if (ref == null) return false;
      await ref.update({'isPublished': isPublished});
      await CreateLogs(action: " Product Edited");
      return true;
    } catch (e) {
      print('Error updating product status $id: $e');
      return false;
    }
  }

  Future<bool> CreateNewHotProduct({
    required String img_token,
    required String product_name,
    required String shopid,
    required String currency_type,
    required double price,
    required double offer_price,
    required var offer_ends_on,
    required var offer_starts_on,
    required var offer_available_from,
    required String sku,
    required ProductDealType deal_type,
  }) async {
    if (!AuthService.to.isAuthenticated) {
      return false;
    }
    try {
      final hierarchy = await FetchService.to.fetchShopHierarchy(shopid);
      await Collection.collection('Products').doc(sku).set({
        'barcode': sku,
        'image': img_token,
        'name': product_name,
        'price': price,
        'discount': offer_price,
        'shopId': shopid,
        'regionId': hierarchy.regionId,
        'Country': hierarchy.country,
        'currencyType': currency_type,
        'dealType': deal_type.name,
        'availableFrom': _toTimestamp(offer_available_from),
        'expiresOn': _toTimestamp(offer_ends_on),
        'startDate': _toTimestamp(offer_starts_on),
        'isPublished': true,
        'createdOn': Timestamp.now(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error creating hot deal product: $e');
      return false;
    }
  }

  Timestamp? _toTimestamp(dynamic value) {
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is Timestamp) return value;
    return null;
  }

  Future<int> GetUserCount({
    required UserType userType,
    required UserStatus status,
  }) async {
    int userCount = 0;
    if (AuthService.to.isAuthenticated) {
      try {
        QuerySnapshot<Object?> querySnapshot = await Collection
            .collection('Users')
            .where('userType', isEqualTo: userType.name)
            .get();
        userCount = querySnapshot.docs.length;
      } catch (e) {
        print('Error fetching user count: $e');
      }
    }
    print('$userCount ---------------************');
    return userCount;
  }

  /// All registered customer users, for the Billing page's "Total Users"
  /// tabular view. Mirrors the field mapping `AuthService.fetchUserDetails`
  /// already uses for a single user doc.
  Future<List<Users>> fetchAllUsers({UserType userType = UserType.CUSTOMER}) async {
    List<Users> users = [];
    if (!AuthService.to.isAuthenticated) return users;
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Users')
          .where('userType', isEqualTo: userType.name)
          .get();
      for (var doc in querySnapshot.docs) {
        users.add(_userFromDoc(doc.id, doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Error fetching all users: $e');
    }
    return users;
  }

  /// Every account with a staff role (i.e. not a customer or rider) — the
  /// "Team" screen's member list. `Country`-only scoping isn't applied
  /// here; that's a coarser cut than any existing screen needed before, so
  /// it's deliberately platform-wide rather than guessed at.
  Future<List<Users>> fetchStaffUsers() async {
    List<Users> users = [];
    if (!AuthService.to.isAuthenticated) return users;
    const List<String> staffRoles = ['ADMIN', 'COUNTRY_HEAD', 'MERCHANT', 'SHOP_ADMIN', 'AFFILIATES'];
    try {
      QuerySnapshot<Object?> querySnapshot =
          await Collection.collection('Users').where('userType', whereIn: staffRoles).get();
      for (var doc in querySnapshot.docs) {
        users.add(_userFromDoc(doc.id, doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Error fetching staff users: $e');
    }
    return users;
  }

  Users _userFromDoc(String docId, Map<String, dynamic> data) {
    final dynamic rawPermissions = data['permissions'];
    return Users(
      id: data['id']?.toString() ?? docId,
      fullname: data['fullname']?.toString(),
      img_token: data['imgToken']?.toString(),
      phn_number: data['phone']?.toString(),
      email: data['email']?.toString(),
      user_type: getUserTypeFromString(data['userType']?.toString() ?? ''),
      country: data['Country']?.toString(),
      permissions: rawPermissions is List ? rawPermissions.map((e) => e.toString()).toSet() : null,
    );
  }

  /// Sets or clears a user's explicit permission override. `null`/empty
  /// removes the field entirely so [Users.effectivePermissions] falls back
  /// to the role default again, rather than storing an explicit empty set
  /// (which would mean "no permissions at all", not "use the default").
  Future<bool> updateUserPermissions(String uid, Set<String>? permissions) async {
    try {
      final DocumentReference<Object?> ref = Collection.collection('Users').doc(uid);
      if (permissions == null || permissions.isEmpty) {
        await ref.update({'permissions': FieldValue.delete()});
      } else {
        await ref.update({'permissions': permissions.toList()});
      }
      await CreateLogs(action: 'Updated permissions for $uid');
      return true;
    } catch (e) {
      print('Error updating permissions for $uid: $e');
      return false;
    }
  }

  /// All pending invites platform-wide, for the Team screen. Deliberately
  /// not scoped by inviter (unlike [FetchInvitedUserData], which is scoped
  /// to "invites I sent" for the Merchants/Shop Listing screens) — a Team
  /// overview should show every outstanding invite, not just the current
  /// admin's own.
  Future<List<InvitedUser>> fetchAllPendingInvites() async {
    List<InvitedUser> invites = [];
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('InvitedUsers')
          .where('status', isEqualTo: InvitedUserStatus.PENDING.name)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        invites.add(InvitedUser(
          id: doc.id,
          email: data['email'],
          fullname: data['fullname'],
          user_type: getUserTypeFromString(data['userType'] ?? ''),
          usersID: data['usersID'] ?? '',
          status: InvitedUserStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => InvitedUserStatus.PENDING,
          ),
        ));
      }
    } catch (e) {
      print('Error fetching pending invites: $e');
    }
    return invites;
  }

  Future<void> CreateinvitedUser(
      {String? emailId, required UserType user_type}) async {
    String? uid = AuthService.to.user.value?.id;
    try {
      await Collection.collection('InvitedUsers').add({
        'email': emailId,
        'fullname': emailId,
        'userType': user_type.name,
        'status': InvitedUserStatus.PENDING.name,
        'usersID': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Invited user Created");
    } catch (e) {
      print('Error creating invited user: $e');
    }
  }

  String _generateRandomPassword() {
    const String chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%^&*';
    final Random rand = Random.secure();
    return List.generate(20, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Creates the Firebase Auth account for an invited user on a secondary,
  /// throwaway [FirebaseApp] instance so the currently signed-in admin's
  /// session isn't replaced by the new account (which is what
  /// createUserWithEmailAndPassword does on the default app/instance).
  Future<void> _createInvitedAuthAccount(String email) async {
    FirebaseApp? inviteApp;
    try {
      inviteApp = await Firebase.initializeApp(
        name: 'InviteUserApp',
        options: Firebase.app().options,
      );
      final FirebaseAuth inviteAuth = FirebaseAuth.instanceFor(app: inviteApp);
      await inviteAuth.createUserWithEmailAndPassword(
        email: email,
        password: _generateRandomPassword(),
      );
      await inviteAuth.sendPasswordResetEmail(email: email);
      await inviteAuth.signOut();
    } on FirebaseAuthException catch (e) {
      print('Could not create auth account for $email: $e');
    } catch (e) {
      print('Could not create auth account for $email: $e');
    } finally {
      await inviteApp?.delete();
    }
  }

  /// Invitation emails now go through the `sendInvitationEmail` Cloud
  /// Function (see functions/index.js) instead of a direct HTTP POST from
  /// the client. The webhook's bearer token and sender address used to be
  /// hardcoded here, which meant they shipped in plain text inside the
  /// compiled Flutter Web bundle for anyone to read — they now live only
  /// server-side, via Secret Manager.
  Future<void> invitingUser({
    required List<String> inviteuser,
    required UserType user_type,
  }) async {
    for (var item in inviteuser) {
      try {
        await FirebaseFunctions.instance
            .httpsCallable('sendInvitationEmail')
            .call(<String, dynamic>{'recipient': item});
      } on FirebaseFunctionsException catch (e) {
        print('Invitation email failed for $item: ${e.code} ${e.message}');
        continue;
      } catch (e) {
        print('Invitation email failed for $item: $e');
        continue;
      }
      await CreateinvitedUser(emailId: item, user_type: user_type);
      await _createInvitedAuthAccount(item);
      await CreateLogs(action: "invited user $item");
    }
  }

  Future<List<InvitedUser>> FetchInvitedUserData({String? id}) async {
    List<InvitedUser> _userDataList = [];
    if (id == null) return _userDataList;
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('InvitedUsers')
          .where('usersID', isEqualTo: id)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _userDataList.add(InvitedUser(
          id: doc.id,
          email: data['email'],
          fullname: data['fullname'],
          user_type: getUserTypeFromString(data['userType'] ?? ''),
          usersID: data['usersID'] ?? '',
          status: InvitedUserStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => InvitedUserStatus.PENDING,
          ),
        ));
      }
    } catch (e) {
      print('Error fetching invited users: $e');
    }
    invitedUserCount = _userDataList.length;
    return _userDataList;
  }

  Future<void> uploadCSV(
      {required String csv, required Uint8List? filebytes}) async {
    var headers = {'Content-Type': 'text/csv'};
    var request = http.Request(
        'PUT',
        Uri.parse(
            'https://yqwrc9fz4k.execute-api.us-east-2.amazonaws.com/testing/csvstorebulkupload/$csv'));
    request.body = r'<file contents here>';

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  /// Writes a customer-facing message to the `Notifications` collection.
  /// The client app is expected to listen to this collection (either every
  /// doc where `targetType == 'all'`, or docs matching its own `shopId`)
  /// and surface it as an in-app notification. There is no push/FCM step
  /// here — delivery is "client reads Firestore", not a device push.
  Future<bool> sendNotification({
    required String title,
    required String body,
    required String targetType, // 'all' or 'shop'
    String? targetShopId,
    String? targetShopName,
  }) async {
    try {
      await Collection.collection('Notifications').add({
        'title': title,
        'body': body,
        'targetType': targetType,
        'targetShopId': targetShopId,
        'targetShopName': targetShopName,
        'createdBy': AuthService.to.user.value?.id,
        'createdByName': AuthService.to.user.value?.fullname,
        'createdOn': FieldValue.serverTimestamp(),
      });
      await CreateLogs(action: 'Sent notification: $title');
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    List<Map<String, dynamic>> _notifications = [];
    try {
      QuerySnapshot<Object?> querySnapshot = await Collection
          .collection('Notifications')
          .orderBy('createdOn', descending: true)
          .limit(50)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _notifications.add({'id': doc.id, ...data});
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    return _notifications;
  }

  Future<void> CreateLogs({String? action}) async {
    try {
      await Collection.collection('ActivityLogs').add({
        'usersID': AuthService.to.user.value?.id,
        'action': action,
        'datetime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating activity log: $e');
    }
  }

  String DateTimeToString({required DateTime date}) {
    DateTime CompleteDate = DateTime.parse(date.toString());
    return DateFormat('yyyy-MM-dd hh:mm a').format(CompleteDate).toString();
  }
}
