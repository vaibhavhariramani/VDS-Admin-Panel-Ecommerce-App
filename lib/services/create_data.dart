import 'dart:convert';

import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class CreateService extends GetxService {
  static CreateService get to => Get.find<CreateService>();

  Future<bool> CreateNewGreenProduct({
    required String sku,
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
      print('SKU $sku');
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
  createProduct(input: { sku:"$sku",img_token: "$img_token", name: "$product_name",  price: $price, discount: $offer_price,expires_on: "$offer_ends_on", shopID: "$shopid", deal_type: ,available_from:"$offer_available_from",created_on: "$rightnow", currency_type: "$currency_type",is_published: true }) 
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
}
