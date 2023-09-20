import 'dart:convert';

import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class UpdateService extends GetxService {
  static UpdateService get to => Get.find<UpdateService>();

  Future<bool> updateUserImage({
    required String img_token,
  }) async {
    String? id = AuthService.to.user.value!.id;
    print("updted image url $img_token");
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
          updateUsers(input: {id: "$id", img_token: "$img_token", _version: $versionNo,}) {
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
    return false;
  }

  Future<bool> deleteShop({
    required String shopId,
  }) async {
    String? id = AuthService.to.user.value!.id;
    print("updted image url $shopId");
    try {
      var url = Uri.parse(
          'https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql');
      String latestVersionNo = """query MyQuery {
          getShop(id: "$shopId") {
            _version
          }
        }""";

      var versionresponse = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': latestVersionNo}));

      print('Response status: ${versionresponse.statusCode}');
      print('Response body: ${versionresponse.body}');
      Map versionResopnseMap = jsonDecode(versionresponse.body);

      int versionNo = versionResopnseMap["data"]["getShop"]["_version"];
      print(versionNo);
      //updateUsers(input: {id: "$id", fullname: "$fullname", img_token: "$img_token", _version: $versionNo, phn_number: "$phone_number"}) {
      String updateMutation = """mutation MyMutation {
  updateShop(input: {_version: $versionNo, id: "$shopId", is_deleted: true}) {
    id
  }
}
        """;

      var response = await http.post(url,
          headers: {'x-api-key': 'da2-qah2nlfghjd6hlve2dn7r5pi3a'},
          body: json.encode({'query': updateMutation}));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var decodedJson = json.decode(response.body);
      var jsonValue = decodedJson['data']['updateShop'];
      // print("new full name ${jsonValue['fullname']}");
      print('delete shop ${jsonValue}');
      return true;
    } on Exception catch (e) {
      print('Query failed: $e');
    } catch (e) {
      print(e);
    }
    return false;
  }
}
