import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vdsadmin/models/ProductDealType.dart';
import 'package:vdsadmin/models/UserStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/AcitivityLog.dart';
import '../models/Magazines.dart';
import '../models/Product.dart';
import '../models/Shop.dart';
import '../models/SubscriptionLogs.dart';
import '../models/UserType.dart';
import '../models/Users.dart';
import 'auth_service.dart';

class DataService extends GetxService {
  static DataService get to => Get.find<DataService>();
  final storageref = FirebaseStorage.instance;
  final Rx<Users?> amplifyUser = Rx<Users?>(null);
  final FirebaseFirestore Collection = FirebaseFirestore.instance;
  // GraphQLClient? client;
  int invitedUserCount = 0;
  @override
  void onInit() {
    // _getGqlClient();
    super.onInit();
  }

  _getGqlClient() async {
    // client = await GqlHelper.getClient();
    // _startProductSubscriptions();
  }

  Future<Users?> getLogedInUserDetails() async {
    if (_amplifyService.isAuthenticated &&
        token != null &&
        amplifyUser.value == null) {
      // try {
      //   final amplify.GraphQLOperation _operation = _amplifyService.api.query(
      //     request: amplify.GraphQLRequest(
      //       document: GqlQueries.getUserbyID,
      //       variables: {
      //         'id': token,
      //       },
      //     ),
      //   );
      //   return await _operation.response.then(
      //     (_response) {
      //       final _responseData = jsonDecode(_response.data);
      //       final Users _userData = Users.fromJson(_responseData['getUsers']);
      //       amplifyUser(_userData);
      //       Get.log(_userData.img_token.toString());
      //       return amplifyUser.value;
      //     },
      //   );
      // } on amplify.ApiException catch (e) {
      //   print('Query failed: $e');
      // } catch (e) {
      //   print(e);
      // }

      // return null;
    }
  }

  // void _startProductSubscriptions() async {
  //   final Stream<QueryResult> _subscription = client!.subscribe(
  //       SubscriptionOptions(document: gql(GqlSubcriptions.onCreateProduct)));

  //   _subscription.listen((event) {
  //     print(event.exception);
  //   });
  // }

  Future<List<Product>> fetchAllProducts() async {
    List<Product> _products = [];
    // final QueryResult _result = await client!
    //     .query(QueryOptions(document: gql(GqlQueries.fetchAllProducts)));

    // if (_result.hasException) {
    //   print('Fetch List Products faild');
    //   print(_result.exception.toString());
    // } else {
    // print((_result.data ?? {})['syncProducts']['items']);
    // if ((_result.data?? {}).isNotEmpty) {

    //   if ((_result.data ?? {})['syncProducts']['items'].isNotEmpty) {
    //     for (var _item in (_result.data ?? {})['syncProducts']['items']) {
    //       for (var _productsShop in _item['UserProductReviews']['items']) {
    //         if (_productsShop['_deleted'] == null) {
    //           _item['UserProductReviews'] = {"serializedData": _productsShop};
    //         } else {
    //           _item['UserProductReviews'] = [];
    //         }
    //       }

    //       _products.add(Product.fromJson(_item));
    //     }
    //   }
    // }
    return _products;
  }

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

    // isScreenLoading(false);
    return null;
  }

  Future<List<Magazines>> fetchAllMagazine() async {
    print("Fetching magazine from AWS");
    List<Magazines> _magazines = [];
    // final QueryResult _result = await client!
    //     .query(QueryOptions(document: gql(GqlQueries.fetchAllMagazines)));

    // if (_result.hasException) {
    //   print('Fetch Magazine List  failed');
    //   print(_result.exception.toString());
    // } else {
    //   print('____________________________________');
    //   Get.log(_result.data.toString());

    //   if ((_result.data ?? {})['searchMagazines']['items'].isNotEmpty) {
    //     for (var _item in (_result.data ?? {})['searchMagazines']['items']) {
    //       if (_item['_deleted'] == null) {
    //         _magazines.add(Magazines.fromJson(_item));
    //       }
    //       // print(_item);
    //     }
    //   }
    // }
    print(_magazines);
    return _magazines;
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
    print("Fetching Id for Shop from User Id: \n");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    String shopId =
        json.decode(response.body)['data']["searchShops"]['items'][0]["id"];
    Get.log("Fetched ShopId : $shopId ");
    return shopId;
  }

  //Fetching List of Scheduled Magazines
  Future<List<Magazines>> fetchAllScheduledMagazines() async {
    Get.log("Fetching Scheduled Magazine Data");
    List<Magazines> _ScheduledDataList = [];
    String? id = AuthService.to.user.value?.id;
    String? MagazineId = AuthService.to.user.value?.id;
    DateTime now = DateTime.now();
    DateTime? awsdate = DateTime.now();
    print('Parsing Date: $awsdate ');
    print('user id: $id uuuuuuuuuusssssssss');
    if (AuthService.to.user.value?.user_type == UserType.SHOP_ADMIN) {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String MagManagerQuery = """query MyQuery {
            listUsersHierarchies(filter: {user_id: {eq: "$id"}}) {
              items {
                managed_by
              }
            }
          }
          """;

      var response = await http.post(
        url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode(
          {
            'query': MagManagerQuery,
          },
        ),
      );
      print("Fetching details for Manager Of Magazine: \n");
      print(
          "Owner of this Shop Admin is : ${json.decode(response.body)['data']['listUsersHierarchies']['items'][0]['managed_by']}");
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      for (var item in json.decode(response.body)['data']
          ['listUsersHierarchies']['items']) {
        MagazineId = item['managed_by'];
        if (AuthService.to.isAuthenticated) {
          print(AuthService.to.user.value?.id);
          try {
            var url = Uri.parse(
                'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
            String scheduledMagQuery = """query MyQuery {
          listMagazines(filter: {publish_from: {gt: "$awsdate"}, usersID: {eq: "$MagazineId"}}) {
            items {
              id
              createdAt
              img_tokens
              offer_ends_on
              thumbnail
              title
              updatedAt
              uploaded_on
              usersID
              website_url
              publish_from
            }
          }
}""";

            var response = await http.post(
              url,
              headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
              body: json.encode(
                {
                  'query': scheduledMagQuery,
                },
              ),
            );
            print("Fetching details for Scheduled Magazine: \n");
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
            Map versionResopnseMap = jsonDecode(response.body);
            var versionResopnseList =
                versionResopnseMap["data"]["listMagazines"]["items"];
            for (var i in versionResopnseList) {
              _ScheduledDataList.add(Magazines.ierator(i));
            }

            print("checking Refreshed Value $_ScheduledDataList");
          } on Exception catch (e) {
            print('Query failed: $e');
          } catch (e) {
            print(e);
          }
        }
      }
      // MagazineId = AuthService.to.user.value?.id;
    } else {
      _ScheduledDataList.clear();
      if (AuthService.to.isAuthenticated) {
        print(AuthService.to.user.value?.id);
        try {
          var url = Uri.parse(
              'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
          String scheduledMagQuery = """query MyQuery {
  searchMagazines(sort: {direction: asc, field: uploaded_on}, filter: {usersID: {eq: "${id}"}, publish_from: {gt: "$awsdate"}}) {
    items {
      id
      img_tokens
      thumbnail
      title
      uploaded_on
      website_url
      usersID
      updatedAt
      publish_from
      offer_ends_on
      lon
      lat
      createdAt
      _version
      _lastChangedAt
      _deleted
    }
  }
}""";

          var response = await http.post(
            url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode(
              {
                'query': scheduledMagQuery,
              },
            ),
          );
          print("Fetching details for Scheduled Magazine: \n");
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
          Map versionResopnseMap = jsonDecode(response.body);
          var versionResopnseList =
              versionResopnseMap["data"]["searchMagazines"]["items"];
          for (var i in versionResopnseList) {
            _ScheduledDataList.add(Magazines.ierator(i));
          }

          print("checking Refreshed Value $_ScheduledDataList");
        } on Exception catch (e) {
          print('Query failed: $e');
        } catch (e) {
          print(e);
        }
      }
    }
    return _ScheduledDataList;
  }

  //Fetching List of Published Magazines
  Future<List<Magazines>> fetchAllPublishedMagazines() async {
    Get.log("Fetching Published Magazine Data");
    List<Magazines> _PublishedDataList = [];
    String? id = AuthService.to.user.value?.id;
    String? MagazineId = AuthService.to.user.value?.id;
    DateTime now = DateTime.now();
    DateTime? awsdate = DateTime.now();
    print('Parsing Date: $awsdate ');
    if (AuthService.to.user.value?.user_type == UserType.SHOP_ADMIN) {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String MagManagerQuery = """query MyQuery {
            listUsersHierarchies(filter: {user_id: {eq: "$id"}}) {
              items {
                managed_by
              }
            }
          }
          """;

      var response = await http.post(
        url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode(
          {
            'query': MagManagerQuery,
          },
        ),
      );
      print("Fetching details for Manager Of Magazine: \n");
      print(
          "Owner of this Shop Admin is : ${json.decode(response.body)['data']['listUsersHierarchies']['items'][0]['managed_by']}");
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      for (var item in json.decode(response.body)['data']
          ['listUsersHierarchies']['items']) {
        MagazineId = item['managed_by'];
        if (AuthService.to.isAuthenticated) {
          print(AuthService.to.user.value?.id);
          try {
            var url = Uri.parse(
                'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
            String publishedMagQuery = """query MyQuery {
  searchMagazines(filter: {usersID: {eq: "$MagazineId"}, _deleted: {ne: true}, publish_from: {lt: "$awsdate"}}) {
    items {
      _deleted
      _lastChangedAt
      _version
      createdAt
      id
      img_tokens
      lat
      lon
      offer_ends_on
      publish_from
      thumbnail
      title
      updatedAt
      uploaded_on
      usersID
      website_url
    }
  }
}
""";

            var response = await http.post(
              url,
              headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
              body: json.encode(
                {
                  'query': publishedMagQuery,
                },
              ),
            );
            print("Fetching details for Scheduled Magazine: \n");
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
            Map versionResopnseMap = jsonDecode(response.body);
            var versionResopnseList =
                versionResopnseMap["data"]["searchMagazines"]["items"];
            for (var i in versionResopnseList) {
              _PublishedDataList.add(Magazines.ierator(i));
            }

            print("checking Refreshed Value $_PublishedDataList");
          } on Exception catch (e) {
            print('Query failed: $e');
          } catch (e) {
            print(e);
          }
        }
      }
    } else {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String publishedMagQuery = """query MyQuery {
  searchMagazines(filter: {usersID: {eq: "$MagazineId"}, _deleted: {ne: true}, publish_from: {lt: "$awsdate"}}, sort: {direction: desc, field: uploaded_on}) {
    items {
      _deleted
      _lastChangedAt
      _version
      createdAt
      id
      img_tokens
      lat
      lon
      offer_ends_on
      publish_from
      thumbnail
      title
      updatedAt
      uploaded_on
      usersID
      website_url
    }
  }
}
""";

        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': publishedMagQuery,
            },
          ),
        );
        print("Fetching details for Scheduled Magazine: \n");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);
        var versionResopnseList =
            versionResopnseMap["data"]["searchMagazines"]["items"];
        for (var i in versionResopnseList) {
          _PublishedDataList.add(Magazines.ierator(i));
        }
      } catch (e) {
        print(e);
      }
    }
    return _PublishedDataList;
  }

  // Fetching List of All Products
  Future<List<Product>> fetchingProducts() async {
    Get.log("Fetching All Products Data");
    List<Product> _DataList = [];
    String? id = AuthService.to.user.value?.id;
    if (AuthService.to.isAuthenticated) {
      print(id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String allProductQuery = """query MyQuery {
  listProducts(filter: { shopID: {eq: "$id"}}) {
    items {
      id
      createdAt
      img_token
      expires_on
      name
      updatedAt
      shopID
      available_from
      created_on
      currency_type
      deal_type
      discount
      has_offer
      offer_description
      is_available
      offer_title
      price
      product_category
      product_description
    }
  }
}
""";

        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': allProductQuery,
            },
          ),
        );
        print("Fetching details for All Products: \n");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);
        var versionResopnseList =
            versionResopnseMap["data"]["listProducts"]["items"];
        for (var i in versionResopnseList) {
          _DataList.add(Product.IndexData(i));
        }

        print("checking Refreshed Value $_DataList");
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _DataList;
  }

  //Fetching List of Scheduled Products
  Future<List<Product>> fetchAllScheduledProducts(String? shopId) async {
    // String? shopId = await fetchShopId();
    Get.log("Fetching Scheduled Products Data");
    List<Product> _ScheduledDataList = [];
    String? id = AuthService.to.user.value?.id;
    DateTime now = DateTime.now();
    // DateTime date = DateTime(now.year, now.month, now.day);
    DateTime? awsdate = DateTime.now();
    print('dateTime right now according to AWSDATETIME FORMAT : $awsdate ');
    if (AuthService.to.isAuthenticated) {
      print(AuthService.to.user.value?.id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String scheduledProductQuery = """query MyQuery {
  searchProducts(filter: {shopID: {eq: "$shopId"}, available_from: {gte: "$awsdate"}, is_published: {eq: true}}, sort: {direction: desc, field: created_on}) {
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
    }
  }
}

""";

        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': scheduledProductQuery,
            },
          ),
        );
        print("Fetching details for Scheduled Products: \n");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);
        var versionResopnseList =
            versionResopnseMap["data"]["searchProducts"]["items"];
        for (var i in versionResopnseList) {
          _ScheduledDataList.add(Product.fromJson(i));
        }

        print("checking Refreshed Value $_ScheduledDataList");
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _ScheduledDataList;
  }

  //Fetching List of Published Products
  Future<List<Product>> fetchAllPublishedProducts(String? shopId) async {
    // String? shopId = await fetchShopId();
    Get.log("Fetching Published Products Data");
    List<Product> _PublishedDataList = [];
    String? id = AuthService.to.user.value?.id;
    DateTime now = DateTime.now();
    // DateTime date = DateTime(now.year, now.month, now.day);
    DateTime? awsdate = DateTime.now();
    print('dateTime right now according to AWSDATETIME FORMAT : $awsdate ');
    if (AuthService.to.isAuthenticated) {
      print(AuthService.to.user.value?.id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String PublishedProductQuery = """query MyQuery {
  searchProducts(filter: {shopID: {eq: "$shopId"}, available_from: {lte: "$awsdate"}, expires_on: {gte: "$awsdate"}, is_published: {eq: true}}, sort: {direction: desc, field: created_on}) {
    items {
      id
      name
      updatedAt
      shopID
      product_description
      product_category
      price
      offer_title
      offer_description
      is_available
      img_token
      has_offer
      expires_on
      discount
      deal_type
      currency_type
      created_on
      createdAt
      available_from
      _version
      _deleted
      _lastChangedAt
    }
  }
}


""";

        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': PublishedProductQuery,
            },
          ),
        );
        print("Fetching details for Published Products: \n");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);
        var versionResopnseList =
            versionResopnseMap["data"]["searchProducts"]["items"];
        for (var i in versionResopnseList) {
          _PublishedDataList.add(Product.fromJson(i));
        }

        print("checking Refreshed Value $_PublishedDataList");
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _PublishedDataList;
  }

  //Fetching List of Products according to product type
  Future<List<Product>> fetchAllProductsaccordingProductType({
    String? shopId,
    required ProductDealType deal_type,
    // required ProductDealType deal_type,
  }) async {
    Get.log("Fetching Products Data according to Product Type");
    List<Product> _DataList = [];

    String? id = AuthService.to.user.value?.id;
    DateTime now = DateTime.now();
    print("SHOP ID ::: ${shopId}");
    print("DEAL TYPE ::: ");
    // DateTime date = DateTime(now.year, now.month, now.day);
    DateTime? awsdate = DateTime.now();
    print('dateTime right now according to AWSDATETIME FORMAT : $awsdate ');
    if (AuthService.to.isAuthenticated) {
      print(AuthService.to.user.value?.id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String Query = """query MyQuery {
  searchProducts(filter: {shopID: {eq: "$shopId"}, deal_type: {eq: ""}, is_published: {eq: true}}, sort: {direction: desc, field: created_on}) {
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
      is_published
      sku
      start_date
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
        print("Fetching details for Products: \n");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Map versionResopnseMap = jsonDecode(response.body);
        var versionResopnseList =
            versionResopnseMap["data"]["searchProducts"]["items"];
        for (var i in versionResopnseList) {
          _DataList.add(Product.fromJson(i));
        }

        print("checking Refreshed Value $_DataList");
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _DataList;
  }

  Future<List<Map<Shop, Users?>>> FetchShopIds({
    String? userId,
  }) async {
    String? Id = AuthService.to.user.value?.id;
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
        // Access MerchantUserID and ShopsUnderMerchant
        shopIDs.addAll(ShopsUnderMerchant);
        if (userType == UserType.MERCHANT) {
          QuerySnapshot<Object?> querySnapshot =
              await RegionDB.where("RegionHeadID", isEqualTo: UserID).get();

          print("if user type is MERCHANT Fetching Region Details");
          print("Users Region is : ${querySnapshot.docs}");
          print("priting list of shops under him: ${querySnapshot.docs}----->");

          for (var document in querySnapshot.docs) {
            var RegionalData = document.data() as Map<String, dynamic>;
            List<String?> ShopsUnderMerchant =
                (RegionalData['ShopsList']) as List<String?>;
            // Access MerchantUserID and ShopsUnderMerchant
            shopIDs.add(ShopsUnderMerchant as String?);
          }
        }
        for (var shopId in shopIDs) {
          DocumentSnapshot<Object?> querySnapshot =
              await ShopsDB.doc(shopId).get();
          if (querySnapshot.data()!.isDefinedAndNotNull) {
            // Assuming 'email' is a unique field, so there should be at most one document
            var ShopsDataMap = querySnapshot.data() as Map<String, dynamic>;
            print(ShopsDataMap);
            print("*****************************");
            // Create your Users object with the fetched data
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
                // Products: Products,
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
                is_active: ShopsDataMap['is_active']);
            // Assuming you have a Users.fromJson constructor to create Users objects
            Users? tempUser =
                AuthService.to.fetchUserDetails(tempShop.manager) as Users;
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

  Future<List<Map<Shop, Users?>>> fetchAllShops(String userid) async {
    List<Map<Shop, Users?>> _shops = [];
    print("We are fetching shop details for user id: $userid");
    // final QueryResult _result = await client!.query(QueryOptions(document: gql(GqlQueries.fetchAllShops), variables: {'usersID': userid}));
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

    String getUsers = """query MyQuery {
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
    var _result = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': getUsers}));
    print('Response status: ${_result.statusCode}');
    print('Response body: ${_result.body}');

    // if (_result.hasException) {
    //   print('Fetch List Products failed');
    //   print(_result.exception.toString());
    // } else {
    print('____________________________________');
    // Get.log(_result.data.toString());
    var res = json.decode(_result.body)['data']["searchShops"]['items'];
    // print(_result.data);
    // if ((_result.data ?? {})['searchShops']['items'].isNotEmpty) {
    for (var _item in res) {
      print(_item);
      Shop _shop = Shop.IndexData(_item);
      Users? _user;
      await FetchUpdatedData(
        id: _shop.usersID!,
      ).then((userNew) async {
        _user = userNew;
      });
      Map<Shop, Users?> max = {_shop: _user};
      _shops.add(max);
    }
    // }
    // }
    // print(_shops);
    return _shops;
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
  searchProducts(filter: {shopID: {eq: "$shopId"}, _deleted: {ne: true}} sort: {direction: desc, field: created_on}) {
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

  Future<String?> addUserImage(String id, String image) async {
    print(image);

    // return await client!
    //     .query(QueryOptions(
    //         document: gql(GqlQueries.getUserVersionId),
    //         variables: {
    //       "id": id,
    //     }))
    //     .then((_userResponse) async {
    //   if (_userResponse.hasException) {
    //     return null;
    //   } else {
    //     var _version = _userResponse.data?["getUsers"]?["_version"] ?? 1;

    //   return await client!
    //       .mutate(MutationOptions(
    //     document: gql(GqlMutations.updateUserImage),
    //     variables: {'id': id, 'img_token': image, "_version": _version + 1},
    //   ))
    //       .then((_result) {
    //     if (_result.hasException) {
    //       print(_result.exception.toString());
    //       return null;
    //     } else {
    //       // print(_result.data);
    //       return _result.data?['updateUsers']['img_token'];
    //     }
    //   });
    // }
    // });
  }

  final GetStorage _storage = GetStorage();
  String? get token {
    final _token = _storage.read('token');
    if (_token != null) {
      return _token;
    } else {
      return null;
    }
  }

  static final AuthService _amplifyService = Get.find<AuthService>();

  Future<Users?> refreshUserDetails({
    required String id,
  }) async {
    if (AuthService.to.isAuthenticated) {
      // await client!
      //     .query(QueryOptions(
      //   document: gql(GqlQueries.getUserbyID),
      //   variables: <String, String>{
      //     'id': id,
      //   },
      // ))
      //     .then(
      //   (QueryResult<dynamic> _response) {
      //     // print(_response.data);
      //     if ((_response.data ?? {})["getUsers"] != null) {
      //       print("printing refreshed data : ${_response.data}");
      //       Users? _userData;
      //       _userData = Users.fromJson((_response.data ?? {})["getUsers"]);
      //       print("checking $_userData");
      //       return _userData;
      //     }
      //   },
      // );

      // print(id);
      // try {
      //   return await client!
      //       .query(
      //           QueryOptions(document: gql(GqlQueries.getUserbyID), variables: {
      //     'id': id,
      //   }))
      //       .then((_userResponse) async {
      //     if (_userResponse.hasException) {
      //       return null;
      //     } else {
      //       print("yeh yahan print ho rha hai ${_userResponse.data}");
      //       final _responseData = _userResponse.data;
      //       final Users _userData = Users.fromJson(_responseData!['getUsers']);
      //       // final Users _userData = Users();
      //       print("checking $_userData");
      //       return _userData;
      //     }
      //   });
      // } on amplify.ApiException catch (e) {
      //   print('Query failed: $e');
      // } catch (e) {
      //   print(e);
      // }

      // return null;
    }
  }

  Future<Users?> FetchUpdatedData({
    required String id,
  }) async {
    if (AuthService.to.isAuthenticated) {
      print(id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestUser = """query MyQuery {
          getUsers(id: "$id") {
            _version
            _deleted
      email
      applie_id
      fullname
      phn_number
      user_type
      id
      img_token
      isUserSecure
      managed_by
      saved_location
      radiusPreference
      current_lon
      current_lat
      current_language
          }
        }""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestUser}));
        print("Refrshing User details: \n");
        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getUsers"]["_version"];
        print(versionNo);
        Users? _userData;
        _userData = Users.fromJson(versionResopnseMap["data"]["getUsers"]);
        print("checking Refreshed Value $_userData");
        return _userData;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return null;
    }
    return null;
  }

  //invited users fetching
//   Future<List<InvitedUser>> FetchInvitedUserData({
//     required String id,
//     // required UserType userType,
//   }) async {
//     Get.log("Fetching Invited User Data");

//     List<InvitedUser> _userDataList = [];
//     print(id);
//     try {
//       var url = Uri.parse(
//           'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
//       String invitedUser = """query MyQuery {
//   syncInvitedUsers(filter: {usersID: {eq: "$id"}}) {
//     items {
//       _deleted
//       _lastChangedAt
//       _version
//       apple_id
//       createdAt
//       current_language
//       current_lat
//       current_lon
//       deleted_parent
//       email
//       fb_id
//       fullname
//       gmail_id
//       id
//       img_token
//       isUserSecure
//       phn_number
//       radiusPrefernce
//       status
//       saved_location
//       updatedAt
//       user_type
//       usersID
//     }
//   }
// }

// """;

//       var versionresponse = await http.post(
//         url,
//         headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
//         body: json.encode(
//           {
//             'query': invitedUser,
//           },
//         ),
//       );
//       // print("Refreshing User details for Invite User: \n");
//       // print('Response status: ${versionresponse.statusCode}');
//       // print('Response body: ${versionresponse.body}');
//       Map versionResopnseMap = jsonDecode(versionresponse.body);
//       var versionResopnseList =
//           versionResopnseMap["data"]["syncInvitedUsers"]["items"];
//       for (var i in versionResopnseList) {
//         _userDataList.add(InvitedUser.fromJson(i));
//       }
//       invitedUserCount = _userDataList.length;

//       // print("checking Refreshed Value $_userDataList");
//     } on amplify.ApiException catch (e) {
//       print('Query failed: $e');
//     } catch (e) {
//       print(e);
//     }

//     return _userDataList;
//   }

//   // fetching Banner Advertisment
//   Future<List<AdvertisementBanner>> FetchBannerData({
//     required String id,
//   }) async {
//     Get.log("Fetching Invited User Data");

//     List<AdvertisementBanner> _bannerDataList = [];
//     if (AuthService.to.isAuthenticated) {
//       print(id);
//       try {
//         var url = Uri.parse(
//             'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
//         String invitedUser = """query MyQuery {
//   listAdvertisementBanners {
//     items {
//       _deleted
//       _lastChangedAt
//       _version
//       createdAt
//       end_on
//       discription
//       id
//       img_token
//       is_active
//       lat
//       link_url
//       lon
//       start_from
//       updatedAt
//       usersID
//     }
//   }
// }
// """;

//         var response = await http.post(
//           url,
//           headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
//           body: json.encode(
//             {
//               'query': invitedUser,
//             },
//           ),
//         );
//         print("Refreshing User details for Invite User: \n");
//         print('Response status: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         Map ResopnseMap = jsonDecode(response.body);
//         var ResopnseList =
//             ResopnseMap["data"]["listAdvertisementBanners"]["items"];
//         for (var i in ResopnseList) {
//           _bannerDataList.add(AdvertisementBanner.fromJson(i));
//         }

//         print("checking Refreshed Value $_bannerDataList");
//       } on amplify.ApiException catch (e) {
//         print('Query failed: $e');
//       } catch (e) {
//         print(e);
//       }
//     }
//     return _bannerDataList;
//   }

  Future<bool> updateUserData(
      {required String id,
      required String fullname,
      required String img_token,
      required dynamic phone_number}) async {
    if (AuthService.to.isAuthenticated) {
      print(id);
      print("updted image url $img_token");
      print(fullname);
      // print(phone_number);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
          getUsers(id: "$id") {
            _version
          }
        }""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));

        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getUsers"]["_version"];
        print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
          updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
            id
            fullname
            _version
            img_token
            phn_number
          }
        }
        """;

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var decodedJson = json.decode(response.body);
        var jsonValue = decodedJson['data']['updateUsers'];
        print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> updateProductData(
      {required String id,
      required String product_name,
      required double price,
      required DateTime available_from,
      required DateTime expire_on,
      required double discount}) async {
    if (AuthService.to.isAuthenticated) {
      print(id);
      print(expire_on);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));

        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
        print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
          updateProduct(input: {id: "$id",name:"$product_name", price: $price, _version: $versionNo, available_from:"$available_from", expires_on:"$expire_on",discount:$discount}) {
            id
            name
            _version
            price
            available_from
            discount
          }
        }
        """;

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var decodedJson = json.decode(response.body);
        await CreateLogs(action: "$product_name Product Edited");
        // var jsonValue = decodedJson['data']['updateUsers'];
        // print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> updateUserSubCount({
    required String id,
    required int versionNo,
    required int mag_count,
    required int shop_count,
  }) async {
    if (AuthService.to.isAuthenticated) {
      print(mag_count.toString() + shop_count.toString());
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        // String latestVersionNo = """query MyQuery {
        //   getProduct(id: "$id") {
        //     _version
        //   }
        // }""";

        // var versionresponse = await http.post(url,
        //     headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        //     body: json.encode({'query': latestVersionNo}));

        // print('Response status: ${versionresponse.statusCode}');
        // print('Response body: ${versionresponse.body}');
        // Map versionResopnseMap = jsonDecode(versionresponse.body);

        // int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
        // print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
  updateUsers(input: {_version: $versionNo, id: "$id", mag_subscription_left: $mag_count, shops_subscription_left: $shop_count}) {
    id
  }
}
        """;

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body 22: ${response.body}');

        // var decodedJson = json.decode(response.body);
        // // await CreateLogs(action: "$product_name Product Edited");
        // printdecodedJson['data']['shops_subscription_left'];
        // print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> createSubLogs({
    required String id,
    required double price,
    required int mag_count,
    required int shop_count,
  }) async {
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        // String latestVersionNo = """query MyQuery {
        //   getProduct(id: "$id") {
        //     _version
        //   }
        // }""";

        // var versionresponse = await http.post(url,
        //     headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        //     body: json.encode({'query': latestVersionNo}));

        // print('Response status: ${versionresponse.statusCode}');
        // print('Response body: ${versionresponse.body}');
        // Map versionResopnseMap = jsonDecode(versionresponse.body);

        // int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
        // print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
  createSubscriptionLogs(input: {mag_count: $mag_count, price: $price, purchase_date: "${DateTime.now().toIso8601String()}", shop_count: $shop_count, usersID: "$id"}) {
    id
  }
}
        """;

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        // var decodedJson = json.decode(response.body);
        // await CreateLogs(action: "$product_name Product Edited");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
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
    if (AuthService.to.isAuthenticated) {
      print(id);
      print(expire_on);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));

        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
        print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
          updateProduct(input: {id: "$id",name:"$product_name", price: $price, _version: $versionNo, available_from:"$available_from", expires_on:"$expire_on",discount:$discount, start_date: "$startson"}) {
            id
            name
            _version
            price
            available_from
            discount
          }
        }
        """;

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var decodedJson = json.decode(response.body);
        await CreateLogs(action: "$product_name Product Edited");
        // var jsonValue = decodedJson['data']['updateUsers'];
        // print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> scheduleProductData(
      {required String id,
      required DateTime available_from,
      required DateTime expire_on}) async {
    print('\n \n Scheduling product for future');
    print(id);
    print(expire_on);
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

      var versionresponse = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': latestVersionNo}));

      print('Response status: ${versionresponse.statusCode}');
      print('Response body: ${versionresponse.body}');
      Map versionResopnseMap = jsonDecode(versionresponse.body);

      int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
      print(versionNo);
      //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
      String updateMutation = """mutation MyMutation {
          updateProduct(input: {id: "$id", _version: $versionNo, available_from:"$available_from", expires_on:"$expire_on",is_published: true  }) {
            id
            name
            _version
            price
            available_from
            discount
          }
        }
        """;

      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': updateMutation}));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var decodedJson = json.decode(response.body);
      await CreateLogs(action: " Product Scheduled");
      // var jsonValue = decodedJson['data']['updateUsers'];
      // print("new full name ${jsonValue['fullname']}");
      return true;
    } on Exception catch (e) {
      print('Query failed: $e');
    } catch (e) {
      print(e);
    }

    return false;
  }

//TODO: making schedule magazine live
  // Future<bool> CreateNewMagazine2(
  //     {required String id,
  //     required String img_token,
  //     required var offer_ends_on,
  //     required String title,
  //     required String Magazineurl}) async {
  //   print("expiry date of Magazine: ${offer_ends_on.runtimeType}");
  //   print("image url of magazine to be created: $img_token");
  //   return await client!
  //       .mutate(MutationOptions(
  //     document: gql(GqlMutations.CreateMagazine),
  //     variables: {
  //       'id': id,
  //       'img_token': img_token,
  //       "offer_ends_on": offer_ends_on,
  //       "thumbnail": img_token,
  //       "title": title,
  //       "website_url": Magazineurl
  //     },
  //   ))
  //       .then((_result) {
  //     if (_result.hasException) {
  //       print('Exception occured');
  //       print(_result.exception.toString());
  //       return false;
  //     } else {
  //       print(_result.data);
  //       return _result.data?['updateUsers']['img_token'];
  //     }
  //   });
  // }

  Future<bool> CreateNewOnlineMagazine({
    required String img_token,
    required var offer_ends_on,
    required var offer_starts_on,
    required String title,
    required String Magazineurl,
    required String thumbnail,
  }) async {
    if (AuthService.to.isAuthenticated) {
      print(offer_ends_on);
      print(offer_starts_on);
      print("updted image url $img_token");
      print(title);
      print(Magazineurl);
      DateTime rightnow = DateTime(DateTime.now() as int);
      String? id = AuthService.to.user.value?.id;
      print(id);
      var lat = AuthService.to.user()?.current_lat;
      var lon = AuthService.to.user()?.current_lon;
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

        String createMutation = """mutation MyMutation {
  createMagazines(input: {  img_tokens: "$img_token",offer_ends_on: "$offer_ends_on", thumbnail: "$thumbnail", title: "$title", website_url: "$Magazineurl", usersID: "$id", publish_from: "$offer_starts_on",lat: $lat, lon: $lon,uploaded_on:"$rightnow"}) {
    id
    thumbnail
    title
    website_url
  }
}
""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': createMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> CreateNewOfferMagazine({
    required List<String> img_token,
    required var offer_ends_on,
    required var offer_starts_on,
    required String title,
    required String thumbnail,
  }) async {
    if (AuthService.to.isAuthenticated) {
      print(offer_ends_on);
      print(offer_starts_on);
      print("updted image url $img_token");
      print(title);
      var lat = AuthService.to.user.value?.current_lat;
      var lon = AuthService.to.user.value?.current_lon;
      String imgToken = img_token.join(', ');
      DateTime rightnow = DateTime(DateTime.now() as int);
      String? id = AuthService.to.user.value?.id;
      print('lat: $lat');
      print('lon: $lon');
      print(id);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

        String createMutation = """mutation MyMutation {
  createMagazines(input: {  img_tokens: "$imgToken",offer_ends_on: "$offer_ends_on", thumbnail: "$thumbnail", title: "$title", usersID: "$id", publish_from: "$offer_starts_on",lat: $lat, lon: $lon,uploaded_on:"$rightnow"}) {
    id
    thumbnail
    title
    
  }
}
""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': createMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  // Create New banner
  Future<bool> CreateNewBanner(
      {required String id,
      required String img_token,
      required var offer_ends_on,
      required String title,
      required String Magazineurl}) async {
    if (AuthService.to.isAuthenticated) {
      print(offer_ends_on);
      print("updted image url $img_token");
      print(title);
      print(Magazineurl);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

        String createMutation = """mutation MyMutation {
  createAdvertisementBanner(input: {img_token: "$img_token", usersID: "$id", link_url: "$Magazineurl"}) {
    id
    link_url
  }
}
""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': createMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> CreateNewGreenProduct({
    required String img_token,
    // required ProductDealType deal_type,
    required String product_name,
    required String shopid,
    required String currency_type,
    required double price,
    required double offer_price,
    required var offer_ends_on,
    required var offer_available_from,
  }) async {
    if (AuthService.to.isAuthenticated) {
      print('creating new Green Deal product');
      print('Fresh Untill Date: $offer_ends_on');
      print('Visible on Mobile App: $offer_available_from');
      // print('deal_type.name: ${deal_type.name}');
      print("Shop ID: $shopid");
      print("updted image url $img_token");
      print("product_name: $product_name");
      print("currency_type: $currency_type");

      var lat = AuthService.to.user.value?.current_lat;
      var lon = AuthService.to.user.value?.current_lon;
      print('lat: $lat');
      print('lon: $lon');
      DateTime rightnow = DateTime(DateTime.now() as int);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

        String createMutation = """mutation MyMutation {
  createProduct(input: { img_token: "$img_token", name: "$product_name",  price: $price, discount: $offer_price,expires_on: "$offer_ends_on", shopID: "$shopid", deal_type: ,available_from:"$offer_available_from",created_on: "$rightnow", currency_type: "$currency_type" ,is_published: true  }) 
  {
    id
    img_token
    name
    price
  }
}""";

        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {'query': createMutation},
          ),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> CreateNewHotProduct({
    required String img_token,
    // required ProductDealType deal_type,
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
    if (AuthService.to.isAuthenticated) {
      print('creating new Hot Deal product');
      print('SKU $sku');
      print('Start Date: $offer_starts_on');
      print('End Date: $offer_ends_on');
      print('Deal Type: deal_type.name');
      print("Shop ID: $shopid");
      print("updted image url $img_token");
      // print("Creating Product deal Type $deal_type");
      // print("Creating Product deal Type $product_cat");
      print(product_name);
      print(offer_ends_on);
      var lat = AuthService.to.user.value?.current_lat;
      var lon = AuthService.to.user.value?.current_lon;
      DateTime rightnow = DateTime(DateTime.now() as int);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

        String createMutation = """mutation MyMutation {
  createProduct(input: { sku:"$sku",img_token: "$img_token", name: "$product_name",  price: $price, discount: $offer_price,expires_on: "$offer_ends_on", created_on: "$rightnow",shopID: "$shopid",available_from:"$offer_available_from", deal_type: ,currency_type: "$currency_type",start_date: "$offer_starts_on",is_published: true  }) 
  {
    shopID
    img_token
    name
    price
    deal_type
    expires_on
    created_on
  }
}""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': createMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<int> GetUserCount({
    // required UserStatus status,
    required UserType userType,
    required UserStatus status,
  }) async {
    int userCount = 0;
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String usercount =
            '''query MyQuery {listUsers(filter: {status: {eq: }, user_type: {eq: ${userType.name}}}) {
    items {
      id
      email
      fullname
      user_type
    }
  }
}''';
        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {
              'query': usercount,
            },
          ),
        );
        Map responseMap = json.decode(response.body);
        userCount = responseMap['data']['listUsers']['items'].length;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    print('$userCount ---------------************');
    return userCount;
  }

  Future<void> CreateinvitedUser(
      {String? emailId, required UserType user_type}) async {
    // String uType=EnumToString.convertToString(user_type);
    // print(uType);
    print(user_type.name);
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
    String? uid = AuthService.to.user.value?.id;
    print("uid is $uid");
    DateTime rightnow = DateTime(DateTime.now() as int);

    String createMutation = """mutation MyMutation {
  createInvitedUser(input: {email: "$emailId", usersID: "$uid", fullname: "$emailId",user_type: ${user_type.name}, status: PENDING}) {
    email
    _version
    usersID
  }
}

""";

    var response = await http.post(
      url,
      headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
      body: json.encode(
        {'query': createMutation},
      ),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print("Invited user Created");
  }

  Future<void> invitingUser({
    required List<String> inviteuser,
    required UserType user_type,
  }) async {
    for (var item in inviteuser) {
      var headers = {
        'authorizationToken': 'abc123',
        'Content-Type': 'text/plain'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://no01ccjb6e.execute-api.us-east-2.amazonaws.com/testing/invitation-mail'));
      request.body =
          '''{\r\n    "sender": "nsharma0619@gmail.com",\r\n    "recipient": "$item"\r\n}''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        await CreateinvitedUser(emailId: item, user_type: user_type);
        final FirebaseAuth _auth = FirebaseAuth.instance;
        _auth.createUserWithEmailAndPassword(email: item, password: "p@ssword");
        await CreateLogs(action: "invited user $item");
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  Future<List<ActivityLog>> fetchActivityLog() async {
    List<ActivityLog> _actionLogDataList = [];
    String? uid = AuthService.to.user.value?.id;
    print("uid ::::::: is $uid");
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String fetchactivity = """query MyQuery {
  searchActivityLogs(filter: {id: {eq: "$uid"}}) {
    items {
      _deleted
      _lastChangedAt
      _version
      actio
      brief_discription
      createdAt
      datetime
      id
      updatedAt
      usersID
    }
  }
}

""";
        var versionresponse = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {'query': fetchactivity},
          ),
        );

        Map versionResopnseMap = jsonDecode(versionresponse.body);

        var versionNo =
            versionResopnseMap["data"]["searchActivityLogs"]["items"];

        // ActivityLogItem? _activityData;
        for (var item in versionNo) {
          _actionLogDataList.add(ActivityLog.fromJson(item));
          // print(_actionLogDataList[item]);
        }
        print(_actionLogDataList);
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return _actionLogDataList;
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

  Future<bool> productDelete({
    required String id,
  }) async {
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));
        var versiono = json.decode(versionresponse.body);
        int v = versiono["data"]["getProduct"]["_version"];
        print(versiono);

        // var url = Uri.parse('https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String deleteproductquery =
            """mutation MyMutation { deleteProduct(input: {id: "$id", _version: $v}) {
    id
  }
}
""";
        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {'query': deleteproductquery},
          ),
        );
        print(response.body);
        await CreateLogs(action: "Product Deleted");
        // Map ResopnseMap = jsonDecode(response.body);

        // var versionNo = ResopnseMap["data"]["listActivityLogs"]["items"];

        // ActivityLogItem? _activityData;
        // for (var item in versionNo) {
        //   _actionLogDataList.add(ActivityLog.fromJson(item));
        //   // print(_actionLogDataList[item]);
        // }
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return false;
  }

  Future<bool> productUnpublish({
    required String id,
  }) async {
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

      var versionresponse = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': latestVersionNo}));
      var versiono = json.decode(versionresponse.body);
      int v = versiono["data"]["getProduct"]["_version"];
      print(versiono);

      // var url = Uri.parse('https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String productquery = """mutation MyMutation {
  updateProduct(input: {id: "$id", _version: $v, is_published: false}) {
    id
    name
    _version
    price
    available_from
    discount
    is_published
  }
}

""";
      var response = await http.post(
        url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode(
          {'query': productquery},
        ),
      );
      print("Product Unpublished");
      print(response.body);
      await CreateLogs(action: "Product Unpublished ");
      // Map ResopnseMap = jsonDecode(response.body);

      // var versionNo = ResopnseMap["data"]["listActivityLogs"]["items"];

      // ActivityLogItem? _activityData;
      // for (var item in versionNo) {
      //   _actionLogDataList.add(ActivityLog.fromJson(item));
      //   // print(_actionLogDataList[item]);
      // }
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print('Query failed: $e');
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> publishNow(String productId) async {
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String latestVersionNo = """query MyQuery {
          getProduct(id: "$productId") {
            _version
          }
        }""";

      var versionresponse = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': latestVersionNo}));

      print('Response status: ${versionresponse.statusCode}');
      print('Response body: ${versionresponse.body}');
      Map versionResopnseMap = jsonDecode(versionresponse.body);

      int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
      print(versionNo);
      DateTime rightnow = DateTime(DateTime.now() as int);
      print("Making changes in Publishing Product Making it live now");
      print("Version No: $versionNo");
      print("Right now: $rightnow");
      print("productId: $productId");
      String publishMutation = """mutation MyMutation {
  updateProduct(input: {_version: $versionNo, id: "$productId", available_from: "$rightnow", is_published: true}) {
    available_from
  }
}
          """;
      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': publishMutation}));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<List<SubscriptionLogs>> fetchSubcriptionslogs(
      {required String id}) async {
    List<SubscriptionLogs> sublogs = [];
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String fetchsub = '''
query MyQuery {
  searchSubscriptionLogs(filter: {usersID: {eq: "b64bb912-8417-40de-a2d6-c329e579c1ec"}}) {
    items {
      createdAt
      mag_count
      price
      purchase_date
      shop_count
      updatedAt
      usersID
      id
      _version
      _lastChangedAt
      _deleted
    }
  }
}
''';
      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': fetchsub}));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      Map versionResopnseMap = jsonDecode(response.body);

      var iterator =
          versionResopnseMap["data"]["searchSubscriptionLogs"]["items"];
      for (var item in iterator) {
        sublogs.add(SubscriptionLogs.fromJson(item));
      }
    } catch (e) {
      print(e);
    }
    return sublogs;
  }

  Future<bool> ReduceShopSubCount(
      {required String id, required int shopC, required int magC}) async {
    if (AuthService.to.isAuthenticated) {
      print(id);
      // print(phone_number);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
  getUsers(id: "$id") {
    _version
    mag_subscription_left
    shops_subscription_left
  }
}
""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));

        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getUsers"]["_version"];
        int shopsub =
            versionResopnseMap["data"]["getUsers"]["shops_subscription_left"];
        int magsub =
            versionResopnseMap["data"]["getUsers"]["mag_subscription_left"];
        await CreateNewSubcriptionsLogs(userid: id, shopCount: shopC);
        int updatedshopSub = shopsub + shopC;
        int updatedmagsub = magsub + magC;
        print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
  updateUsers(input: {id: "$id", _version: $versionNo, mag_subscription_left: $updatedmagsub, shops_subscription_left: $updatedshopSub}) {
    id
    fullname
    _version
    img_token
    phn_number
  }
}""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var decodedJson = json.decode(response.body);
        var jsonValue = decodedJson['data']['updateUsers'];
        print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> updateShopSubCount(
      {required String id, required int shopC, required int magC}) async {
    if (AuthService.to.isAuthenticated) {
      print(id);
      // print(phone_number);
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
  getUsers(id: "$id") {
    _version
    mag_subscription_left
    shops_subscription_left
  }
}
""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));

        print('Response status: ${versionresponse.statusCode}');
        print('Response body: ${versionresponse.body}');
        Map versionResopnseMap = jsonDecode(versionresponse.body);

        int versionNo = versionResopnseMap["data"]["getUsers"]["_version"];
        int shopsub =
            versionResopnseMap["data"]["getUsers"]["shops_subscription_left"];
        int magsub =
            versionResopnseMap["data"]["getUsers"]["mag_subscription_left"];
        await CreateNewSubcriptionsLogs(userid: id, shopCount: shopC);
        int updatedshopSub = shopsub + shopC;
        int updatedmagsub = magsub + magC;
        print(versionNo);
        //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
        String updateMutation = """mutation MyMutation {
  updateUsers(input: {id: "$id", _version: $versionNo, mag_subscription_left: $updatedmagsub, shops_subscription_left: $updatedshopSub}) {
    id
    fullname
    _version
    img_token
    phn_number
  }
}""";

        var response = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': updateMutation}));
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        var decodedJson = json.decode(response.body);
        var jsonValue = decodedJson['data']['updateUsers'];
        print("new full name ${jsonValue['fullname']}");
        return true;
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    } else {
      return false;
    }
    return false;
  }

  Future<bool> CreateNewSubcriptionsLogs(
      {required String userid, required int shopCount}) async {
    DateTime rightnow = DateTime(DateTime.now() as int);
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String createmag = """mutation MyMutation {
  createSubscriptionLogs(input: {usersID: "$userid", shop_count: $shopCount, price: 150, purchase_date: "$rightnow", mag_count: 0}) {
    id
    mag_count
    price
  }
}""";

      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': createmag}));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<List<Map<ActivityLog, Users?>>> FetchActivityLogsDetails(
      String id) async {
    List<Map<ActivityLog, Users?>> _logs = [];
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');

    String activity = """query MyQuery {
  searchActivityLogs(filter: {usersID: {eq: "$id"}}, sort: {direction: desc, field: datetime}) {
    items {
      id
      usersID
      _version
      updatedAt
      datetime
      createdAt
      brief_discription
      actio
      _deleted
      _lastChangedAt
    }
  }
}



""";

    var response = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': activity}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var res = json.decode(response.body)['data']["searchActivityLogs"]['items'];
    for (var item in res) {
      print(item["usersID"]);
      var id = item["usersID"];
      ActivityLog log = ActivityLog.fromJson(item);
      Users? _user;
      await FetchUpdatedData(
        id: id,
      ).then((userNew) async {
        _user = userNew;
      });
      Map<ActivityLog, Users?> max = {log: _user};
      _logs.add(max);
    }
    Get.log("All Fetched Shops Are: $_logs");
    return _logs;
  }

  Future<bool> publishNowMag(String MagId) async {
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String latestVersionNo = """query MyQuery {
          getMagazines(id: "$MagId") {
            _version
          }
        }""";

      var versionresponse = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': latestVersionNo}));

      print('Response status: ${versionresponse.statusCode}');
      print('Response body: ${versionresponse.body}');
      Map versionResopnseMap = jsonDecode(versionresponse.body);

      int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
      print(versionNo);
      DateTime rightnow = DateTime(DateTime.now() as int);
      print("Making changes in Publishing Magazine Making it live now");
      print("Version No: $versionNo");
      print("Right now: $rightnow");
      print("productId: $MagId");
      String publishMutation = """mutation MyMutation {
  updateMagazines(input: {_version: $versionNo, id: "$MagId", available_from: "$rightnow"}) {
    available_from
  }
}""";
      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': publishMutation}));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<void> CreateLogs({String? action}) async {}

  Future<bool> updateProductStatus(String id, bool isPublished) async {
    var url = Uri.parse(
        'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
    String? uid = AuthService.to.user.value?.id;
    print("uid is $uid");
    DateTime rightnow = DateTime(DateTime.now() as int);
    String latestVersionNo = """query MyQuery {
          getProduct(id: "$id") {
            _version
          }
        }""";

    var versionresponse = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': latestVersionNo}));

    print('Response status: ${versionresponse.statusCode}');
    print('Response body: ${versionresponse.body}');
    Map versionResopnseMap = jsonDecode(versionresponse.body);

    int versionNo = versionResopnseMap["data"]["getProduct"]["_version"];
    print(versionNo);
    //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
    String updateMutation = """mutation MyMutation {
          updateProduct(input: {id: "$id", _version: $versionNo, is_published: $isPublished}) {
            id
            name
            _version
            price
            available_from
            discount
          }
        }
        """;

    var response = await http.post(url,
        headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
        body: json.encode({'query': updateMutation}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var decodedJson = json.decode(response.body);
    await CreateLogs(action: " Product Edited");
    // var jsonValue = decodedJson['data']['updateUsers'];
    // print("new full name ${jsonValue['fullname']}");
    return true;
  }

  String DateTimeToString({required DateTime date}) {
    DateTime CompleteDate = DateTime.parse(date.toString());
    return DateFormat('yyyy-MM-dd hh:mm a').format(CompleteDate).toString();
  }

  Future<bool> MagazineDelete({
    required String id,
  }) async {
    if (AuthService.to.isAuthenticated) {
      try {
        var url = Uri.parse(
            'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String latestVersionNo = """query MyQuery {
  getMagazines(id: "$id") {
    _version
  }
}""";

        var versionresponse = await http.post(url,
            headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
            body: json.encode({'query': latestVersionNo}));
        var versiono = json.decode(versionresponse.body);
        int v = versiono["data"]["getMagazines"]["_version"];
        print(versiono);

        // var url = Uri.parse('https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
        String deleteMagquery =
            """mutation MyMutation { deleteMagazines(input: {id: "$id", _version: $v}) {
    id
  }
}

""";
        var response = await http.post(
          url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode(
            {'query': deleteMagquery},
          ),
        );
        print(response.body);
        await CreateLogs(action: "Magazine Deleted");
        // Map ResopnseMap = jsonDecode(response.body);

        // var versionNo = ResopnseMap["data"]["listActivityLogs"]["items"];

        // ActivityLogItem? _activityData;
        // for (var item in versionNo) {
        //   _actionLogDataList.add(ActivityLog.fromJson(item));
        //   // print(_actionLogDataList[item]);
        // }
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } on Exception catch (e) {
        print('Query failed: $e');
      } catch (e) {
        print(e);
      }
    }
    return false;
  }

  FetchInvitedUserData({String? id}) {}
}
