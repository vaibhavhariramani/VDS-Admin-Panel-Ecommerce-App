import 'dart:async';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdsadmin/home/dashboard.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_colors.dart';
import '../utils/authentication.dart';
import '../widgets/google_sign_in_button.dart';
import 'data_assisten.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
  static Future<bool> checkUser(User user) async {
    if (user == null) {
      return false;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      bool isAdmin = userData['isAdmin'] ?? false;
      return isAdmin;
    } else {
      return false;
    }
  }
}

class _LoginState extends State<Login> {
  TextEditingController username = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool isLoading = false;
  List<ProductData> productList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    username.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    form(String title, String hint, TextEditingController controller, Icon ic) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.black)),
              child: TextFormField(
                controller: controller,
                showCursor: true,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  hintText: hint,
                  prefixIcon: ic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const Text(
                  //   "Please Login",
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  // ),
                  Stack(children: [
                    Center(
                      child: Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          'images/imageLogin.png',
                          height: 500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          form(
                            'Enter Username',
                            'Username',
                            username,
                            const Icon(
                              Icons.person_outline,
                            ),
                          ),
                          form(
                            'Enter Password',
                            'Password',
                            pass,
                            const Icon(
                              Icons.lock_outline,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                child: const Column(
                                  children: [
                                    Text(
                                      "Forget Password ?",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "Login".toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(10)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xffF3AB0D)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  )),
                                ),
                                onPressed: _login,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  Center(child: Text('OR')),
                  FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return GoogleSignInButton();
                      }
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomColors.firebaseOrange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FutureOr<bool> checkUser(User user) async {
    if (user == null) {
      return false;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Admins')
        .doc(user.uid)
        .get();
    print("fetched user details from Admins");
    print(userDoc);
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print("Users admin status is : |${userData['isAdmin']}");
      bool isAdmin = userData['isAdmin'] ?? false;
      return isAdmin;
    } else {
      return false;
    }
  }

  FutureOr<void> _login() async {
    if (username.text.isNotEmpty && pass.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Future.delayed(const Duration(seconds: 1), () async {
        if (username.text.contains("@")) {
          try {
            String? email = username.text;
            String? password = pass.text;
            final authResult = await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);
            User user = authResult.user!;
            print(user);
            bool isAdmin = await checkUser(user);
            if (isAdmin) {
              String? fullname = user.displayName;
              String? username = user.displayName;
              prefs.setString('email', email);
              prefs.setBool('user', true);
              prefs.setString('username', username!);
              prefs.setString('fullname', fullname!);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                            MasterproductListForBilling: productList,
                          )));
            }
          } catch (e) {
            print(e.toString());
            return null;
          }
        } else {
          for (int id = 0; id < dataAssisten.length; id++) {
            if (username.text == dataAssisten[id]["UserName"] &&
                pass.text == dataAssisten[id]["PassWord"]) {
              String? fullname;
              String? username;
              fullname = dataAssisten[id]["FullName"] as String?;
              username = dataAssisten[id]["UserName"] as String?;
              prefs.setBool('user', true);
              prefs.setString('username', username!);
              prefs.setString('fullname', fullname!);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                            MasterproductListForBilling: productList,
                          )));
            }
          }
        }
      });
    }
  }
}
