import 'dart:async';

import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../../services/auth_service.dart';
import '../../../../../services/data_service.dart';
import '../../../../models/InvitedUser.dart';
import '../../../../models/UserType.dart';
import '../../../../models/Users.dart';
import '../../../../services/fetch_data.dart';

class MerchantsController extends GetxController {
  RxList<Users> userData = RxList<Users>();
  RxList<Users?> merchantsData = RxList<Users>();
  // final RxList<InviteMechantData> allInvitedMerchants =
  //     DemoData.DemoInvitedMerchants;
  // final RxList<String> addedMerchants = DemoData.DemoalreadyaddedMerchants.map(
  //     (element) => element.merchantEmail ?? "").toList().obs;

  RxList<InvitedUser> allInvitedMerchants = <InvitedUser>[].obs;
  RxList<String> addedMerchants = <String>[].obs;
  // final RxList<InviteMechantData> allUninvitedMerchants =
  //     DemoData.DemoNotaddedMerchants;
  RxBool isInviting = false.obs;
  RxBool isLoading = false.obs;
  RxBool shopGridView = false.obs;
  final DataService _dataService = DataService.to;
  final FetchService _fetchData = FetchService.to;
  final AuthService userService = AuthService.to;
  // final RxList<Users?> userinfo = RxList<Users>();
  // final RxBool showShopDetails = false.obs;
  // final RxBool createNewShop = false.obs;
  // final RxList<Shop> allShops = <Shop>[].obs;
  // final RxList<Map<Shop, Users?>> allShops1 = <Map<Shop, Users?>>[].obs;
  // final Rx<Shop> shopdetails = Shop().obs;

  final FormGroup editForm1 = FormGroup(
    {
      'merchant_name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'merchant_user_id': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'merchant_address': FormControl<String>(
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
  void removeMerchant2(String merchant_email) {
    addedMerchants.remove(merchant_email);
    // allUninvitedMerchants.add(merchant_email);
  }

  void addMerchant2(String merchant_email) {
    addedMerchants.add(merchant_email);
    // allUninvitedMerchants.remove(merchant_email);
  }
  // void removeMerchant(InviteMechantData merchant) {
  //   addedMerchants.remove(merchant);
  //   allUninvitedMerchants.add(merchant);
  // }

  // void addMerchant(InviteMechantData merchant) {
  //   addedMerchants.add(merchant);
  //   allUninvitedMerchants.remove(merchant);
  // }

  // @override
  // Future<void> onInit() async {
  //   // userData.addAll(DemoData.userData);
  //   // await _fetchAllMerchants();
  //   // await fetchAllUserInfo();
  //   await _fetchAllInvitedUser();
  //   super.onInit();
  // }

  @override
  void onInit() {
    _fetch();
    super.onInit();
  }

  void _fetch() async {
    await _fetchAllMerchants();
    await _fetchAllInvitedUser();
  }

  Future<void> _fetchAllMerchants() async {
    print("\n");
    print("Fetching All merchants ");
    merchantsData.clear();
    isLoading(true).obs;
    await Future.delayed(1000.milliseconds, () async {
      await _fetchData.fetchAllMERCANTS().then((RxList<Users?> response) {
        merchantsData = response;
      });

      isLoading(false);
    });
    print("Merchant Data is Fetched -----------");
    print(merchantsData.first);
    isLoading(false).obs;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  sendInvitation() async {
    await Future.delayed(1000.milliseconds, () async {
      await _dataService.invitingUser(
        inviteuser: addedMerchants.toList(),
        user_type: UserType.MERCHANT,
      );
    });

    // isLoading(false);
    addedMerchants.clear();
    _fetchAllInvitedUser();
  }

  Future<void> _fetchAllInvitedUser() async {
    allInvitedMerchants.clear();
    // shopdetail
    // isloadinglist(true);
    await Future.delayed(1000.milliseconds, () async {
      //TODO: check usertype
      await _dataService.FetchInvitedUserData(
        id: userService.user.value!.id,
      ).then((List<InvitedUser> _shopresponse) {
        allInvitedMerchants(_shopresponse);
      });
      // isloadinglist(false);
      // isLoading(false);
    });
  }
  // Future<void> _fetchAllMerchants() async {
  //   allShops1.clear();
  //   // shopdetail
  //   await Future.delayed(1000.milliseconds, () async {
  //     await _dataService.FetchShopIds().then((List<Map<Shop, Users?>> _shopresponse) {
  //       allShops1(_shopresponse);
  //     });
  //   });
  //   isLoading(false);
  // }
  // Future<void> fetchAllUserInfo() async {
  //   for (var item in allShops) {
  //     await _dataService.FetchUpdatedData(
  //       id: item.usersID!,
  //     ).then((_userInforesponse) async {
  //       userinfo.add(_userInforesponse);
  //     });
  //   }
  // }

  // Future<void> fetchUserInfo(String id) async {
  //   userinfo.clear();
  //   await _dataService.FetchUpdatedData(
  //     id: userService.user.value!.id,
  //   ).then((_userInforesponse) async {
  //     userinfo.add(_userInforesponse);
  //   });
  // }
}
