import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/InvitedUser.dart';
import '../../../../models/Product.dart';
import '../../../../models/Shop.dart';
import '../../../../models/UserType.dart';
import '../../../../models/Users.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/fetch_data.dart';
import '../../../../services/update_data.dart';

class ShopListingController extends GetxController {
  //TODO: Implement ShopListingController
  final RxList<InvitedUser> invitedUsers = <InvitedUser>[].obs;
  final RxList<String> addedShops = <String>[].obs;
  final RxList<InvitedUser> allUninvitedShops = <InvitedUser>[].obs;
  final RxBool isInviting = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isProductLoading = false.obs;
  final DataService _dataService = DataService.to;
  final FetchService _fetchService = FetchService.to;
  final RxList<Product> products = RxList<Product>();
  final RxList<Users?> userinfo = RxList<Users>();
  final RxBool isloadinglist = false.obs;
  final RxBool isEditing = false.obs;
  final AuthService userService = AuthService.to;
  // final countofsubs =
  //     AuthService.to.user.value?.shops_subscription_left!.toInt();
  int index = 0;
  final FormGroup editForm1 = FormGroup(
    {
      'shop_name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'shop_user_id': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'shop_address': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'invited_email': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'invited_name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );

  final FormGroup productEditForm = FormGroup(
    {
      'product_name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'product_user_id': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'product_address': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'product_email': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );
  void removeSHOP(InvitedUser cp) {
    addedShops.remove(cp);
    allUninvitedShops.add(cp);
  }

  void removeSHOP2(String email) {
    addedShops.remove(email);
  }
  // void addSHOP(InvitedUser cp) {
  //   addedShops.add(cp);
  //   allUninvitedShops.remove(cp);
  // }

  void addSHOP2(String email) {
    var emailLIst = email.split(',').toList();
    // emailLIst.forEach((element) {
    //   addedShops.add(element);
    // });
    addedShops.addAll(emailLIst);
    // addedShops.add(email);
  }

  void editProduct() {
    String? id = AuthService.to.user.value?.id;

    String? updated_product_name =
        productEditForm.value['product_name'].toString();
    String updated_product_date =
        productEditForm.value['product_user_id'].toString();
  }

  final RxBool showShopDetails = false.obs;
  final RxBool createNewShop = false.obs;
  final RxList<Shop> allShops = <Shop>[].obs;
  final RxList<Map<Shop, Users?>> allShops1 = <Map<Shop, Users?>>[].obs;
  final Rx<Shop> shopdetails = Shop().obs;

  final count = 0.obs;
  @override
  void onInit() {
    // isLoading(true);

    _fetchData();
    super.onInit();
  }

  void _fetchData() async {
    // if (_dataService.client != null) {

    await _fetchAllShops();
    await fetchAllUserInfo();
    await _fetchAllInvitedUser();

    // }
  }

  Future<void> _fetchAllShops() async {
    allShops1.clear();
    // shopdetail
    await Future.delayed(1000.milliseconds, () async {
      await _dataService.FetchShopIds()
          .then((List<Map<Shop, Users?>> _shopresponse) {
        allShops1(_shopresponse);
      });
    });
    isLoading(false);
  }

  Future<void> _fetchAllInvitedUser() async {
    invitedUsers.clear();
    // shopdetail
    isloadinglist(true);
    await Future.delayed(1000.milliseconds, () async {
      //TODO: check usertype
      await _dataService.FetchInvitedUserData(
        id: userService.user.value!.id,
      ).then((List<InvitedUser> _shopresponse) {
        invitedUsers(_shopresponse);
      });
      isloadinglist(false);
      isLoading(false);
    });
  }

  Future<bool> fetchAllProductsbyCat(String catid) async {
    isProductLoading(true);
    products.clear();
    return await _fetchService
        .fetchAllProductsByShop(catid)
        .then((List<Product> _productresponse) {
      products.addAll(_productresponse);
      isProductLoading(false);
      return products.isEmpty ? false : true;
    });
  }

  Future<void> sendInvittion() async {
    // isLoading(true);

    await Future.delayed(1000.milliseconds, () async {
      await _dataService.invitingUser(
        inviteuser: addedShops.toList(),
        user_type: UserType.SHOP_ADMIN,
      );
    });

    // isLoading(false);
    addedShops.clear();
    _fetchAllInvitedUser();
  }

  Future<void> fetchAllUserInfo() async {
    for (var item in allShops) {
      await _dataService.FetchUpdatedData(
        id: item.usersID!,
      ).then((_userInforesponse) async {
        userinfo.add(_userInforesponse);
      });
    }
  }

  Future<void> fetchUserInfo(String id) async {
    userinfo.clear();
    await _dataService.FetchUpdatedData(
      id: userService.user.value!.id!,
    ).then((_userInforesponse) async {
      userinfo.add(_userInforesponse);
    });
  }

  Future<void> deleteshop(String shopId) async {
    isLoading(true);
    allShops1.clear();
    // shopdetail
    await Future.delayed(1000.milliseconds, () async {
      await UpdateService.to.deleteShop(shopId: shopId);
      isLoading(false);
    });
    Get.snackbar(
      "Shop Deleted",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
    _fetchAllShops();
  }

  @override
  void onReady() {
    _fetchData();
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;

  void createProduct() {}
}
