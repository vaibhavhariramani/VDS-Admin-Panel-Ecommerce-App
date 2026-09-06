import 'dart:js';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdsadmin/models/UserType.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app/modules/auth/widgets/authentication_files/authentication.dart';
import '../app/modules/billing/controllers/billing_controller.dart';
import '../app/modules/home/controllers/home_controller.dart';
import '../app/modules/products/hot_deals/controllers/hot_deals_controller.dart';
import '../app/modules/products/master_list/controllers/master_list_controller.dart';
import '../app/modules/products/products_listing/controllers/products_listing_controller.dart';
import '../app/modules/products/published_products/controllers/published_products_controller.dart';
import '../app/modules/products/scheduled_products/controllers/scheduled_products_controller.dart';
import '../app/modules/storefront/controllers/storefront_controller.dart';
import '../app/routes/app_pages.dart';
import '../models/Users.dart';
import 'data_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final GetStorage _storage = GetStorage();

  Rx<UserType> logedInUserType = Rx<UserType>(UserType.ADMIN);

  final Rx<Users?> user = Rx<Users?>(null);

  final Rx<User?> firebaseUser = Rx<User?>(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore Collection = FirebaseFirestore.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  Rx<Users?> appUser = Rx<Users?>(null);

  String? authToken;

  final Rx<UserType> userType = Rx<UserType>(UserType.ADMIN);

  String? readAuthToken() {
    String? _token = _storage.read('token');
    return _token;
  }

  bool saveAuthToken(String _token) {
    _storage.write('token', _token);
    return true;
  }

  bool removeAuthToken() {
    _storage.remove('token');
    return true;
  }

  bool get isAuthenticated {
    authToken = readAuthToken();
    if (authToken != null) {
      return true;
    } else {
      return false;
    }
  }

  /// Nav-menu visibility only — this is a convenience for hiding items the
  /// signed-in user shouldn't see, not an authorization boundary. Actual
  /// access control is [hasPermission] plus (eventually) Firestore
  /// security rules; never trust this list server-side.
  ///
  /// Keyed on the user's actual [UserType] with a `switch`, not the old
  /// `user.user_type ?? UserType.X` pattern repeated per branch: that
  /// pattern meant a user with a `null` user_type (a missing/malformed
  /// profile) satisfied *every* branch's null-coalesced check at once and
  /// walked away with every role's routes enabled simultaneously — the
  /// most fail-open outcome possible. A `null`/unrecognized type here now
  /// gets no routes at all.
  void enableOrDisableRoutes(Users user) {
    final navRoutes = FlutterDashboardNavService.to.enabledRoutes;
    navRoutes.clear();
    switch (user.user_type) {
      case UserType.ADMIN:
        navRoutes.addAll(const [
          "Dashboard", //Firstpage alsways need to be enabled
          "Country Partners",
          // "Users",
          "Merchants",
          "Action Log",
          "Subscriptions",
          "Banner Ads"
        ]);
        break;
      case UserType.SHOP_ADMIN:
        navRoutes.addAll(const [
          "Dashboard", //Firstpage alsways need to be enabled - stays pinned first, rest alphabetical
          "Billing",
          "Customers",
          "Master List",
          "Orders",
          "Product Listing",
          "Published Products",
          "Scheduled Products",
          "Storefront",

          // "Magazine",
          // "Registration"
        ]);
        break;
      case UserType.MERCHANT: // Region Admin — see UserTypeLabel.
        navRoutes.addAll(const [
          "Dashboard", //Firstpage alsways need to be enabled
          "Shop Listing",
          "Magazine",
          "Subscriptions",
          "Action Log",
        ]);
        break;
      case UserType.AFFILIATES:
        navRoutes.addAll(const [
          "Dashboard",
          "Merchants", //Firstpage alsways need to be enabled
          "Subscriptions",
          "Action Log",
        ]);
        break;
      case UserType.COUNTRY_HEAD:
        navRoutes.addAll(const [
          "Dashboard", //Firstpage alsways need to be enabled
          "Merchants",
          "Subscriptions",
          "Action Log",
          "Banner Ads",
        ]);
        break;
      case UserType.CUSTOMER:
      case UserType.RIDER:
      case null:
        // No admin-panel routes for a customer or rider account (riders
        // use the separate Delivery app, not this panel) or an
        // unrecognized/missing profile — fail closed, not open.
        break;
    }
  }

  /// `FlutterDashboardNavService`'s own listener only reacts to *future*
  /// changes to `enabledRoutes` (it registers via `ever(enabledRoutes, ...)`
  /// in its own `onInit()`) — if this runs even slightly before that
  /// listener is live, the write is silently missed and the sidebar stays
  /// empty until something else touches `enabledRoutes`, which on a plain
  /// page refresh might be never. That's the "nav bar disappeared on
  /// refresh" bug: [_applyCachedRoleForInstantNav] used to call
  /// [enableOrDisableRoutes] exactly once. Re-applying a few times a short
  /// delay apart is idempotent (same route list each time) and guarantees
  /// at least one application lands after the listener is registered,
  /// without needing to know its exact registration timing.
  Future<void> _reapplyRoutesReliably(Users forUser) async {
    for (int attempt = 0; attempt < 5; attempt++) {
      enableOrDisableRoutes(forUser);
      Get.forceAppUpdate();
      if (attempt < 4) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  UserType? loggedUser;
  String? get token {
    final _token = _storage.read('token');
    if (_token != null) {
      return _token;
    } else {
      return null;
    }
  }

  void removeToken() {
    _storage.remove('token');
  }

  static const String _cachedRoleKey = 'cachedUserTypeName';

  /// GetX singletons that resolve the signed-in Shop Admin's shopId once
  /// (in onInit()) and cache it in an instance field/Rx - a plain
  /// `Get.lazyPut` instance isn't recreated just because a *different*
  /// user logs in on top of it in the same browser tab, so without this,
  /// switching accounts (logout, then log in as another Shop Admin)
  /// carried the previous shop's products/orders/dashboard data straight
  /// into the new session. Deleting them here forces each to be rebuilt
  /// fresh - via its GetPage binding - the next time its page is opened,
  /// so onInit() reruns fetchShopId() for whoever is actually signed in.
  void _resetShopScopedControllers() {
    Get.delete<BillingController>();
    Get.delete<HomeController>();
    Get.delete<StorefrontController>();
    Get.delete<MasterListController>();
    Get.delete<ScheduledProductsController>();
    Get.delete<HotDealsController>();
    Get.delete<ProductsListingController>();
    Get.delete<PublishedProductsController>();
  }

  @override
  void onInit() {
    ever(user, (Users? _user) {
      if (_user != null) {
        _resetShopScopedControllers();
        loggedUser = _user.user_type;
        userType(_user.user_type ?? UserType.ADMIN);
        _reapplyRoutesReliably(user.value!);
        // Remember the role so a future refresh can render the nav
        // instantly (see _applyCachedRoleForInstantNav) instead of showing
        // an empty sidebar for the second or so the profile re-fetch takes.
        if (_user.user_type != null) {
          _storage.write(_cachedRoleKey, _user.user_type!.name);
        }
      }
    });
    // Defer the startup user-restore fetch until after the first frame.
    // FlutterDashboardNavService registers its own `ever(enabledRoutes, ...)`
    // listener during its onInit(), which normally runs while that first
    // frame is being built. `ever` only reacts to *future* changes, so if
    // enableOrDisableRoutes() (triggered by the fetch above resolving) ran
    // before that listener was registered, the nav menu would silently stay
    // empty after a refresh even though the user is authenticated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyCachedRoleForInstantNav();
      getLogedInUserDetails();
    });
    super.onInit();
  }

  /// Renders the nav menu immediately from the last-known role cached
  /// locally, before the authoritative Firestore profile fetch
  /// (`getLogedInUserDetails`) has had a chance to complete. Without this,
  /// every page refresh showed an empty sidebar for however long that
  /// fetch's network round trip took, then popped the real routes in —
  /// jarring on a slow connection and pointless when the role essentially
  /// never changes between refreshes. This is purely a rendering
  /// optimization: `getLogedInUserDetails()` still runs right after and its
  /// `ever(user, ...)` callback re-applies (and corrects, if anything
  /// changed) the authoritative routes.
  void _applyCachedRoleForInstantNav() {
    if (!isAuthenticated || user.value != null) return;
    final String? cachedRoleName = _storage.read(_cachedRoleKey);
    if (cachedRoleName == null) return;
    final UserType? cachedType = getUserTypeFromString(cachedRoleName);
    if (cachedType == null) return;
    _reapplyRoutesReliably(Users(user_type: cachedType));
  }

  Future<void> getLogedInUserDetails() async {
    if (isAuthenticated && user.value == null) {
      readAuthToken();
      if (authToken != null) {
        final Users fetchedUser = await fetchUserDetails(authToken);
        user(fetchedUser);
        // The dashboard shell (drawer/nav menu) has already been built by
        // this point on a page refresh, and it reads the nav-service route
        // list as a one-off snapshot rather than reactively — so populating
        // enabledRoutes above (via the `ever(user, ...)` listener) isn't
        // picked up on its own. Force a rebuild so the restored session's
        // nav items actually show up instead of leaving the sidebar empty.
        Get.forceAppUpdate();
      }
    }
  }

  String _errorText = "";

  Future<UserCredential?> _getUserCredentials(
      Map<String, dynamic> credential) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: credential['email'], password: credential["password"]);
    } on FirebaseAuthException catch (e) {
      _errorText = '${e.code.replaceAll('-', ' ').capitalize}';
    } catch (e) {
      _errorText = 'Firebase Login Error :  ${e.toString()}';
    }
  }

  Future<bool> login(Map<String, dynamic> credential) async {
    print("login function in auth getting email id $credential");
    return await _getUserCredentials(credential)
        .then((UserCredential? _userCreds) async {
      // print(_userCreds);
      if (_userCreds != null) {
        print("User exist on Google Firebase: $_userCreds");
        firebaseUser(_userCreds.user!);
        return await checkUser(
                email: firebaseUser.value?.providerData[0].email ??
                    firebaseUser.value?.email,
                userData: firebaseUser)
            .then((bool _userExists) async {
          print("Does User exist ?");
          print(_userExists);
          if (_userExists) {
            BotToast.showText(
              text: 'Login Success'.tr,
              duration: 2.seconds,
            );
            // Fire-and-forget: the activity log write shouldn't hold up
            // navigation into the dashboard.
            DataService.to.CreateLogs(action: "User Logged in");
            return _userExists;
          } else {
            BotToast.showText(text: 'No User Found'.tr);
            return false;
          }
        });
      } else {
        BotToast.showText(text: _errorText);
        return false;
      }
    });
  }

  Future<bool> register(Map<String, dynamic> registrationPayload) async {
    return false;
  }

  Future<void> logout() async {
    user(null);
    await _auth.signOut();
    removeAuthToken();
    // The cached role (see _applyCachedRoleForInstantNav) is only meant to
    // survive a refresh of the *same* signed-in session, not a logout - a
    // stale role here would flash the previous account's nav items for an
    // instant if a different user (or the same one) logs back in. (Not
    // clearing `enabledRoutes` itself: an empty list there means "show
    // every route" as far as `FlutterDashboardNavService` is concerned -
    // the next real login's `ever(user, ...)` callback overwrites it with
    // the correct list anyway.)
    _storage.remove(_cachedRoleKey);
    Get.resetRootNavigator();
    await Future.delayed(2.seconds, () {
      Get.rootDelegate.toNamed(Routes.LOGIN);
    });
  }

  Future<bool> checkUser(
      {required String? email, required Rx<User?> userData}) async {
    if (email != null) {
      final Users? responseUser = await fetchUserDetails(userData.value?.uid);
      user(responseUser);
      _storage.write('token', responseUser?.id);
      return true;
    } else {
      BotToast.showText(text: 'No User Found'.tr);
      return false;
    }
  }

  Future<bool> globalLogin({
    required String loginby,
    Map<String, dynamic>? credential,
  }) async {
    _errorText = 'User not found'.tr;
    return await getUserCredentials(
      loginby,
      credential,
    ).then(
      (_userCreds) async {
        print(_userCreds.toString());
        Get.log(_userCreds.toString());
        if (_userCreds != null) {
          firebaseUser(_userCreds.user!);
          print("User added to User profile in app");
          return await _checkUser(
            loginProvider: loginby,
            email: firebaseUser.value?.providerData[0].email ??
                "${firebaseUser.value!.phoneNumber}@gmail.com",
          ).then((userExists) async {
            if (userExists) {
              BotToast.showText(
                text: 'Login Success'.tr,
                duration: 2.seconds,
              );
              refreshUserDetails(user: firebaseUser.value);
              return userExists;
            } else {
              return await createUserInDatabase(
                loginProvider: loginby,
                credentials: credential,
              );
            }
          });
        } else {
          BotToast.showText(
            text: _errorText,
            duration: 2.seconds,
          );
          return false;
        }
      },
    );
  }

  Future<UserCredential?> getUserCredentials(
      String loginby, Map<String, dynamic>? credential) async {
    // FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential? userCredential;
    User? user;
    try {
      if (loginby == "login") {
        print("loginging user credentials");
        print("---> User email Id: ${credential!['email']} <----");
        print("---> Password : ${credential['password']} <----");
        try {
          userCredential = await _auth.signInWithEmailAndPassword(
              email: credential['email'], password: credential["password"]!);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context as BuildContext).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
        return userCredential;
      }

      if (loginby == "register") {
        return await _auth.createUserWithEmailAndPassword(
            email: credential!['email'], password: credential["password"]);
      }

      if (loginby == "google") {
        // final GoogleSignInAccount? googleSignInAccount =
        //     await _googleSignIn.signIn();
        // if (googleSignInAccount != null) {
        //   final GoogleSignInAuthentication googleSignInAuthentication =
        //       await googleSignInAccount.authentication;
        //   final firebase_auth.AuthCredential googleAuthCredential =
        //       firebase_auth.GoogleAuthProvider.credential(
        //     idToken: googleSignInAuthentication.idToken,
        //     accessToken: googleSignInAuthentication.accessToken,
        //   );
        //   return await firebase_auth.FirebaseAuth.instance
        //       .signInWithCredential(googleAuthCredential);
        // }
        if (kIsWeb) {
          GoogleAuthProvider authProvider = GoogleAuthProvider();

          try {
            userCredential = await _auth.signInWithPopup(authProvider);

            user = userCredential.user;
          } catch (e) {
            print(e);
          }
        } else {
          final GoogleSignIn googleSignIn = GoogleSignIn();

          final GoogleSignInAccount? googleSignInAccount =
              await googleSignIn.signIn();

          if (googleSignInAccount != null) {
            final GoogleSignInAuthentication googleSignInAuthentication =
                await googleSignInAccount.authentication;

            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication.accessToken,
              idToken: googleSignInAuthentication.idToken,
            );

            try {
              userCredential = await _auth.signInWithCredential(credential);

              user = userCredential.user;
            } on FirebaseAuthException catch (e) {
              if (e.code == 'account-exists-with-different-credential') {
                ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                  Authentication.customSnackBar(
                    content:
                        'The account already exists with a different credential',
                  ),
                );
              } else if (e.code == 'invalid-credential') {
                ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                  Authentication.customSnackBar(
                    content:
                        'Error occurred while accessing credentials. Try again.',
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                Authentication.customSnackBar(
                  content: 'Error occurred using Google Sign In. Try again.',
                ),
              );
            }
          }
        }

        // return user;
        return userCredential;
      }

      if (loginby == "facebook") {
        final LoginResult loginResult =
            await _facebookAuth.login(loginBehavior: LoginBehavior.webOnly);
        if (loginResult.accessToken != null) {
          Get.log(loginResult.accessToken.toString());
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(
                  loginResult.accessToken!.tokenString);
          return await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential);
        }
      }
    } on FirebaseAuthException catch (e) {
      _errorText = e.message ?? '';
      print(_errorText);
    } catch (e) {
      _errorText = e.toString();
      print(_errorText);
    }
  }

  Future<bool> createUserInDatabase({
    required String loginProvider,
    Map<String, dynamic>? credentials,
  }) async {
    print("creating account with: $loginProvider");
    print("with credentials : $credentials");
    Get.log("saving user");
    return await _saveUser(
      payload: Users(
        fullname: credentials?["name"] ??
            firebaseUser.value?.providerData[0].displayName,
        email: firebaseUser.value?.providerData[0].email,
        phn_number: credentials?['phone'] ??
            firebaseUser.value?.providerData[0].phoneNumber,
      ),
      // mutationDocument: _mutationDoc,
    );
  }

  Future<Users?> refreshUserDetails({required User? user}) async {
    if (token != null) {
      appUser = Users(fullname: user?.displayName).obs;
    }
    return appUser.value;
  }

  Future<bool> _checkUser({
    required String loginProvider,
    required String email,
  }) async {
    return true;
  }

  Future<bool> _saveUser({
    required Users payload,
  }) async {
    return false;
  }

  Future<Users> fetchUserDetails(String? uid) async {
    Users temp;
    CollectionReference UsersDB = Collection.collection('Users');
    print("*****************************");

    // A thrown read (permission-denied, transient network error, etc.)
    // used to propagate out of this Future uncaught — since the caller
    // (getLogedInUserDetails) doesn't await/catch it either, that silently
    // dropped the real profile fetch and left the nav menu stuck on
    // whatever the cached-role fast path had already applied, with no
    // retry. Treating a failed read the same as "no doc" keeps the
    // existing fail-closed behavior below instead of leaving this hanging.
    DocumentSnapshot<Object?>? querySnapshot;
    try {
      querySnapshot = await UsersDB.doc(uid).get();
    } catch (e) {
      print('Error fetching user doc for $uid: $e');
    }
    print(querySnapshot);
    if (querySnapshot != null && querySnapshot.data() != null) {
      // Assuming 'email' is a unique field, so there should be at most one document
      var userDataMap = querySnapshot.data() as Map<String, dynamic>;
      print(userDataMap);
      print("*****************************");
      print("Are we here ?");
      // Explicit per-user grants, if an admin has set any — `permissions`
      // is absent on every user doc that predates this field, in which
      // case Users.effectivePermissions falls back to the role default.
      final List<dynamic>? permissionsRaw =
          userDataMap['permissions'] as List<dynamic>?;
      final Set<String>? permissions =
          permissionsRaw?.map((dynamic p) => p.toString()).toSet();
      // Create your Users object with the fetched data
      temp = Users(
          id: userDataMap['id'],
          fullname: userDataMap['fullname'],
          img_token: userDataMap['imgToken'],
          phn_number: userDataMap['phone'] ?? "",
          gmail_id: "",
          fb_id: "",
          applie_id: "",
          email: userDataMap['email'] ?? "",
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
          shops: [],
          permissions: permissions);
      print("----------------------------------------------");
      print("User Type: ${temp.user_type}");
      print(temp.fullname);
    } else {
      // Fail closed: a missing/unreadable profile gets no role and no
      // permissions (see [Users.hasPermission] / [enableOrDisableRoutes]),
      // rather than the ADMIN fallback this used to have — a broken
      // profile read should never be more privileged than a working one.
      print("Error fetching user details:");

      temp = Users(
          id: "123",
          fullname: "",
          img_token: "",
          phn_number: "",
          gmail_id: "",
          fb_id: "",
          applie_id: "",
          email: "",
          phonepinID: "",
          user_type: null,
          current_language: "",
          current_lat: 0.0,
          isUserSecure: true,
          radiusPreference: 0.0,
          saved_location: "",
          current_lon: 0.0,
          managed_by: "");
      print("User Details Updated");
      BotToast.showText(text: 'No User Found'.tr);
    }
    return temp;
  }

  bool hasPermission(String permission) =>
      user.value?.hasPermission(permission) ?? false;
}

/// Returns `null` for an unrecognized/missing role string instead of
/// throwing, so a malformed `userType` field fails closed (no role, see
/// the `case null` branch in [AuthService.enableOrDisableRoutes]) rather
/// than crashing the profile fetch entirely.
UserType? getUserTypeFromString(String userTypeString) {
  switch (userTypeString) {
    case 'ADMIN':
      return UserType.ADMIN;
    case 'MERCHANT':
      return UserType.MERCHANT;
    case 'CUSTOMER':
      return UserType.CUSTOMER;
    case 'AFFILIATES':
      return UserType.AFFILIATES;
    case 'COUNTRY_HEAD':
      return UserType.COUNTRY_HEAD;
    case 'SHOP_ADMIN':
      return UserType.SHOP_ADMIN;
    case 'RIDER':
      return UserType.RIDER;
    default:
      return null;
  }
}
