import 'dart:convert';
import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;

import '../models/AcitivityLog.dart';
import '../models/Product.dart';
import '../models/Shop.dart';
import '../models/Users.dart';
import 'auth_service.dart';
import 'data_service.dart';

class FetchService extends GetxService {
  static FetchService get to => Get.find<FetchService>();
  final storageref = FirebaseStorage.instance;
  final Rx<Users?> amplifyUser = Rx<Users?>(null);
  final FirebaseFirestore Collection = FirebaseFirestore.instance;

  // GraphQLClient? client;
  int invitedUserCount = 0;
  @override
  void onInit() {
    _getGqlClient();
    super.onInit();
  }

  _getGqlClient() async {
    // client = await GqlHelper.getClient();
    // _startProductSubscriptions();
  }

  Future<List<Product>> fetchAllProductsByShop(String? shopId) async {
    List<Product> _products = [];
    // String? shopId = await fetchShopId();
    print("Fetching Products Data according to Shop Id: $shopId");
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String alllistShop = '''query MyQuery {
  searchProducts(filter: {shopID: {eq: "$shopId"}, _deleted: {ne: true}}, sort: {direction: desc, field: created_on}) {
    items {
      price
      id
      name
      img_token
      is_available
      offer_description
      offer_title
      product_category
      product_description
      shopID
      updatedAt
      has_offer
      expires_on
      discount
      deal_type
      currency_type
      created_on
      createdAt
      available_from
      _version
      _lastChangedAt
      _deleted
      sku
      start_date
      is_published
    }
  }
}


''';
        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': alllistShop,
            },
          ),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);

        var versionResopnseList =
            versionResopnseMap["data"]["searchProducts"]["items"];
        print(versionResopnseMap.toString() + 'is working');
        for (var i in versionResopnseList) {
          _products.add(Product.fromJson(i));
        }
        Get.log(_products.toString() + 'response');
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
    print("runni fetch");
    String? id = AuthService.to.user.value?.id;
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
    String Query = """query MyQuery {
  searchShops(filter: {usersID: {eq: "$id"}}) {
    items {
      id
      name
      phy_address
    }
  }
}""";

    var response = await http.post(
      url,
      headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
      body: json.encode(
        {
          'query': Query,
        },
      ),
    );
    print(
        "Fetching Id for Shop from User Id: ${AuthService.to.user.value!.id} \n");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    String shopId =
        json.decode(response.body)['data']["searchShops"]['items'][0]["id"];
    Get.log("Fetched ShopId : $shopId ");
    return shopId;
  }

  //Fetching Shop Currency from User Id
  Future<String?> fetchShopCurrency() async {
    print("running fetching Shop Current");
    String? id = AuthService.to.user.value?.id;
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
    String Query = """query MyQuery {
  searchShops(filter: {usersID: {eq: "$id"}}) {
    items {
      id
      currency_type
    }
  }
}
""";

    var response = await http.post(
      url,
      headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
      body: json.encode(
        {
          'query': Query,
        },
      ),
    );
    print(
        "Fetching Currency Type for Shop from User Id: ${AuthService.to.user.value!.id} \n");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    String shopCurr = json.decode(response.body)['data']["searchShops"]['items']
        [0]["currency_type"];
    Get.log("Fetched ShopId : $shopCurr ");
    return shopCurr;
  }

  Future<Shop?> FetchShopFromUserId({required String userid}) async {
    print("we are fetching shop from user ID");
    Shop? _shop = Shop();
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
    String Query = """query MyQuery {
  searchShops(filter: {usersID: {eq: "$userid"}, is_deleted: {ne: true}}) {
    items {
      name
      _deleted
      _lastChangedAt
      _version
      about
      closing_time
      createdAt
      created_on
      currency_type
      id
      img_token
      is_active
      is_deleted
      lat
      license_expiry_date
      license_renewed_on
      lon
      manager
      opening_time
      phn_number
      phonepinID
      phy_address
      rating
      shopcategoryID
      updatedAt
      url
      usersID
    }
  }
}
""";
    var response = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': Query}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    // var res = json.decode(response.body)['data']["searchShops"]['items'];
    // Shop temp = Shop.fromJson(res);
    var res = json.decode(response.body)['data']["searchShops"]['items'];
    // print(_result.data);
    // if ((_result.data ?? {})['searchShops']['items'].isNotEmpty) {
    for (var _item in res) {
      if (_item['name'].toString() != "null") {
        _shop = Shop.fromJson(_item);
      }
    }
    return _shop;
  }

  Future<List<Shop>> FetchShopFromUserHeirachy() async {
    Get.log("Fetching Shops Data From User Heirachy");
    String? Id = AuthService.to.user.value?.id;
    List<Shop> _DataList = [];
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

    String getUsers = """query MyQuery {
  listUsersHierarchies(filter: {managed_by: {eq: "$Id"}}) {
    items {
      user_id
    }
  }
}
""";

    var response = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': getUsers}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var res =
        json.decode(response.body)['data']["listUsersHierarchies"]['items'];

    for (var item in res) {
      print(item["user_id"]);
      var uuid = item["user_id"];
      await FetchShopFromUserId(userid: uuid).then((_shopresponse) {
        _DataList.add(_shopresponse!);
      });
    }
    return _DataList;
  }

  Future<List<Map<ActivityLog, Users?>>>
      FetchActivityLogFromUserHeirachy() async {
    Get.log("Fetching Shops Data From User Heirachy");
    String? Id = AuthService.to.user.value?.id;
    List<Map<ActivityLog, Users?>> _logs = [];
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

    String getUsers = """query MyQuery {
  listUsersHierarchies(filter: {managed_by: {eq: "$Id"}}) {
    items {
      user_id
    }
  }
}
""";

    var response = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': getUsers}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var res =
        json.decode(response.body)['data']["listUsersHierarchies"]['items'];
    print(res[0]);
    for (var item in res) {
      print(item["user_id"]);
      var id = item["user_id"];
      await DataService.to
          .FetchActivityLogsDetails(id)
          .then((List<Map<ActivityLog, Users?>> _logresponse) {
        _logs.addAll(_logresponse);
      });
    }
    return _logs;
  }

  Future<List<Users?>> fetchAllCountryPartners() async {
    List<Users?> _countr_partners = [];
    // String? shopId = await fetchShopId();
    print("Fetching Products Data of Country heads");
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String alllist = '''query MyQuery {
  syncUsers(filter: {user_type: {eq: COUNTRY_HEAD}}) {
    items {
      _deleted
      _lastChangedAt
      _version
      applie_id
      city
      country
      createdAt
      currency_type
      current_language
      current_lat
      current_lon
      deleted_parent
      email
      fb_id
      fullname
      gmail_id
      id
      img_token
      isUserSecure
      mag_subscription_left
      managed_by
      phn_number
      phonepinID
      radiusPreference
      saved_location
      shops_subscription_left
      status
      updatedAt
      user_type
    }
  }
}


''';
        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': alllist,
            },
          ),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);

        var versionResopnseList =
            versionResopnseMap["data"]["syncUsers"]["items"];
        print(versionResopnseMap.toString() + 'is working');
        for (var i in versionResopnseList) {
          _countr_partners.add(Users.fromJson(i));
        }
        Get.log(_countr_partners.toString() + 'response');
        print("checking Refreshed Value:  ");
        for (var item in _countr_partners) {
          print('$item \n\n');
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _countr_partners;
  }

  Future<RxList<Users?>> fetchAllMERCANTS() async {
    RxList<Users?> _merchants = RxList<Users?>();

    if (AuthService.to.isAuthenticated) {
      try {
        CollectionReference CountriesDB = Collection.collection('Countries');
        CollectionReference UsersDB = Collection.collection('Users');
        var UserCountry = AuthService.to.user.value!.country;
        QuerySnapshot<Object?> querySnapshot =
            await CountriesDB.where("Country", isEqualTo: UserCountry).get();

        print("Fetching Merchants");
        print("Users country is : ${AuthService.to.user.value!.country}");
        print("priting data from Country: ${UserCountry}----->");

        for (var document in querySnapshot.docs) {
          var merchantData = document.data() as Map<String, dynamic>;

          // Access MerchantUserID and ShopsUnderMerchant
          var merchantUserID = merchantData['RegionMerchantUserID'];
          var shopsUnderMerchant = merchantData['ShopsUnderMerchant'];

          print('MerchantUserID: $merchantUserID');
          print('ShopsUnderMerchant: $shopsUnderMerchant');
          DocumentSnapshot<Object?> querySnapshot =
              await UsersDB.doc(merchantUserID).get();
          if (querySnapshot.data().isDefinedAndNotNull) {
            // Assuming 'email' is a unique field, so there should be at most one document
            var userDataMap = querySnapshot.data() as Map<String, dynamic>;
            print(userDataMap);
            print("*****************************");
            String type_of_user = userDataMap['userType'];
            // Create your Users object with the fetched data
            Users temp = Users(
              id: userDataMap['id'],
              fullname: userDataMap['fullname'],
              img_token: userDataMap['imgToken'],
              phn_number: userDataMap['phone'],
              gmail_id: "",
              fb_id: "",
              applie_id: "",
              email: userDataMap['email'],
              phonepinID: "",
              user_type: getUserTypeFromString(userDataMap['userType'] ?? ''),
              current_language: "",
              current_lat: 0.0,
              isUserSecure: true,
              radiusPreference: 0.0,
              saved_location: "",
              current_lon: 0.0,
              managed_by: "",
              country: userDataMap['Country'],
            );
            // Assuming you have a Users.fromJson constructor to create Users objects
            _merchants.add(temp);
          }
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
}
