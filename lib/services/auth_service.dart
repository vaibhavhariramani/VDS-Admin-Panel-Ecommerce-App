import 'dart:js';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdsadmin/models/UserType.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app/modules/auth/widgets/authentication_files/authentication.dart';
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
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  Rx<Users?> appUser = Rx<Users?>(null);
  // GraphQLClient? client;

  String? authToken;
  // static final _amplify = Amplify;
  // APICategory api = _amplify.API;

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

  void enableOrDisableRoutes(Users user) {
    FlutterDashboardNavService.to.enabledRoutes.clear();
    if ((user.user_type ?? UserType.ADMIN) == UserType.ADMIN) {
      FlutterDashboardNavService.to.enabledRoutes.addAll(const [
        "Dashboard", //Firstpage alsways need to be enabled
        "Country Partners",
        // "Users",
        "Merchants",
        "Action Log",
        "Subscriptions",
        "Banner Ads"
      ]);
    }
    if ((user.user_type ?? UserType.SHOP_ADMIN) == UserType.SHOP_ADMIN) {
      FlutterDashboardNavService.to.enabledRoutes.addAll(const [
        "Dashboard", //Firstpage alsways need to be enabled
        "Master List",
        "Scheduled Products",
        "Hot Deals",
        "Published Products",
        "Product Listing",

        // "Magazine",
        // "Registration"
      ]);
    }
    if ((user.user_type ?? UserType.MERCHANT) == UserType.MERCHANT) {
      FlutterDashboardNavService.to.enabledRoutes.addAll(const [
        "Dashboard", //Firstpage alsways need to be enabled
        "Shop Listing",
        "Magazine",
        "Subscriptions",
        "Action Log",
      ]);
    }
    if ((user.user_type ?? UserType.AFFILIATES) == UserType.AFFILIATES) {
      FlutterDashboardNavService.to.enabledRoutes.addAll(const [
        "Dashboard",
        "Merchants", //Firstpage alsways need to be enabled
        "Subscriptions",
        "Action Log",
      ]);
    }
    if ((user.user_type ?? UserType.COUNTRY_HEAD) == UserType.COUNTRY_HEAD) {
      FlutterDashboardNavService.to.enabledRoutes.addAll(const [
        "Dashboard",
        "Merchants", //Firstpage alsways need to be enabled
        "Subscriptions",
        "Action Log",
        "Banner Ads",
      ]);
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

  @override
  void onInit() {
    // removeAuthToken();
    ever(user, (Users? _user) {
      if (_user != null) {
        loggedUser = _user.user_type;
        userType(_user.user_type ?? UserType.ADMIN);
        enableOrDisableRoutes(user.value!);
      }
    });
    _getGqlClient();
    super.onInit();
  }

  void _getGqlClient() async {
    // client = await GqlHelper.getClient();
    getLogedInUserDetails();
  }

  void getLogedInUserDetails() async {
    if (isAuthenticated) {
      readAuthToken();
      print(authToken);
      if (authToken != null) {
        // await client!
        //     .query(QueryOptions(
        //   document: gql(GqlQueries.getUserbyID),
        //   variables: <String, String>{
        //     'id': authToken!,
        //   },
        // ))
        //     .then(
        //   (QueryResult<dynamic> _response) {
        //     // print(_response.data);
        //     if ((_response.data ?? {})["getUsers"] != null) {
        //       Users? _userData;
        //       _userData = Users.fromJson((_response.data ?? {})["getUsers"]);
        //       user(_userData);
        //     }
        //   },
        // );
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
        print(
            "Not Fetching User Details from AWS Amplify instead of that filling google firebase user details in user");
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
            await DataService.to.CreateLogs(action: "User Logged in");
            return _userExists;
          } else {
            BotToast.showText(text: 'No User Found'.tr);
            // return await _createUserInDatabase(
            //   credentials: credential,
            // );
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
    Get.resetRootNavigator();
    await Future.delayed(2.seconds, () {
      Get.rootDelegate.toNamed(Routes.LOGIN);
    });
  }

  Future<bool> checkUser(
      {required String? email, required Rx<User?> userData}) async {
    if (email != null) {
      print("got user creds");
      print("${userData.value?.email}");
      print("${userData.value}");
      Users? temp = Users(
          id: "123",
          fullname: "",
          img_token: "",
          phn_number: "",
          gmail_id: "",
          fb_id: "",
          applie_id: "",
          email: "",
          phonepinID: "",
          user_type: UserType.ADMIN,
          current_language: "",
          current_lat: 0.0,
          isUserSecure: true,
          radiusPreference: 0.0,
          saved_location: "",
          current_lon: 0.0,
          managed_by: "");
      user(temp).obs;
      _storage.write('token', temp.id);
      print("User Details Updated");
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
        print("---> Password : ${credential!['password']} <----");
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
              FacebookAuthProvider.credential(loginResult.accessToken!.token);
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
    late String _mutationDoc;

    switch (loginProvider) {
      case "register":
        print("creating account with: ${loginProvider}");
        print("with credentials : ${credentials}");
        // _mutationDoc = CustomMutations.createAndUpdateUserByEmail;
        break;
      case "google":
        // _mutationDoc = CustomMutations.createAndUpdateUserByGmailId;
        break;
      case "facebook":
        // _mutationDoc = CustomMutations.createAndUpdateuserByFacebookId;
        break;
      case "apple":
        // _mutationDoc = CustomMutations.createAndUpdateUserByAppleId;
        break;
    }
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
    if (
        // _amplifyService.isAmlifyConfigured.value &&
        token != null) {
      try {
        // final amplify.GraphQLOperation _operation = _amplifyService.api.query(
        //   request: amplify.GraphQLRequest(
        //     document: CustomQueries.getUserbyID,
        //     variables: {
        //       'id': token,
        //     },
        //   ),
        // );
        // return await _operation.response.then(
        //   (_response) {
        //     final _responseData = jsonDecode(_response.data);
        //     final Users _userData = Users.fromJson(_responseData['getUsers']);
        appUser = Users(fullname: user?.displayName).obs;
        //     print(_userData);
        //     return amplifyUser.value;
        //   },
        // );

        // } on amplify.ApiException catch (e) {
        //   print('Query failed: $e');
      } catch (e) {
        print(e);
      }
      return appUser.value;
    }
    return appUser.value;
  }

  Future<bool> _checkUser({
    required String loginProvider,
    required String email,
  }) async {
    // final amplify.GraphQLOperation _operation = _amplifyService.api.query(
    //   request: amplify.GraphQLRequest(
    //     document: CustomQueries.getUserbyEmail,
    //     variables: {'email': email},
    //   ),
    // );
    // return await _operation.response.then(
    //   (_response) async {
    //     var _responseData = jsonDecode(_response.data);
    //     while (!(_responseData['listUsers']['nextToken'] == null ||
    //         _responseData['listUsers']['items'].isNotEmpty)) {
    //       Get.log(1.toString());
    //       await _amplifyService.api
    //           .query(
    //             request: amplify.GraphQLRequest(
    //               document: CustomQueries.getUserbyEmailwithToken,
    //               variables: {
    //                 'email': email,
    //                 'nextToken': _responseData['listUsers']['nextToken'],
    //               },
    //             ),
    //           )
    //           .response
    //           .then((value) => _responseData = jsonDecode(value.data));
    //     }
    //     if (_responseData['listUsers']['items'].isNotEmpty) {
    //       Users? _userData;
    //       for (var _userItem in _responseData['listUsers']['items']) {
    //         if (_userItem['_deleted'] == null) {
    //           _userData = Users.fromJson(_userItem);
    //           amplifyUser(_userData);
    //           _storage.write('token', _userData.id);
    //           print('From email chek : $_userData');
    //           return true;
    //         }
    //       }
    //       return false;
    //     } else {
    //       print('from check');
    //       return false;
    //     }
    //   },
    // );
    return true;
  }

  Future<bool> _saveUser({
    required Users payload,
    //  String mutationDocument,
  }) async {
    // if (
    //   // _amplifyService.isAmlifyConfigured.value
    //   ) {
    //   try {
    //     final amplify.GraphQLOperation _operation = _amplifyService.api.mutate(
    //       request: amplify.GraphQLRequest(
    //         document: mutationDocument,
    //         variables: payload.toJson(),
    //       ),
    //     );
    //     return await _operation.response.then(
    //       (_response) {
    //         final _responseData = jsonDecode(_response.data);
    //         final Users _userData =
    //             Users.fromJson(_responseData['createUsers']);
    //         amplifyUser(_userData);
    //         _storage.write('token', _userData.id);
    //         print(_userData);
    //         BotToast.showText(
    //           text: 'Registration Successful'.tr,
    //           duration: 2.seconds,
    //         );
    //         refreshUserDetails();
    //         return true;
    //       },
    //     );
    //   } on amplify.ApiException catch (e) {
    //     print('Query failed: $e');
    //   } catch (e) {
    //     print(e);
    //   }
    // } else {
    //   return false;
    // }
    return false;
  }

  // Future<bool> _createUserInDatabase(Map<String, dynamic> credential) async {
  //   return false;
  // }
}
