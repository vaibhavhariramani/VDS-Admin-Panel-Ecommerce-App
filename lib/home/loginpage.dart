import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdsadmin/home/dashboard.dart';
import 'package:vdsadmin/models/product_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_colors.dart';
import '../theme_controller.dart';
import '../utils/authentication.dart';
import '../widgets/google_sign_in_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
  static Future<bool> checkUser(User user) async {
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
  late final Future<void> _autoLoginCheck;

  @override
  void initState() {
    super.initState();
    _autoLoginCheck = Authentication.initializeFirebase(context: context);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: mode == ThemeMode.dark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: ThemeController.toggle,
              );
            },
          ),
        ],
      ),
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
                          'assets/images/imageLogin.png',
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
                            'Enter Email',
                            'Email',
                            username,
                            const Icon(
                              Icons.email_outlined,
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
                                style: ButtonStyle(
                                  padding:
                                      WidgetStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(10)),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          const Color(0xffF3AB0D)),
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  )),
                                ),
                                onPressed: _login,
                                child: Text(
                                  "Login".toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const Center(child: Text('OR')),
                  FutureBuilder(
                    future: _autoLoginCheck,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error initializing Firebase');
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
    if (username.text.isEmpty || pass.text.isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final String email = username.text.trim();
    final String password = pass.text;

    try {
      final authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User user = authResult.user!;
      bool isAdmin = await checkUser(user);
      if (isAdmin) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String fullname = user.displayName ?? email;
        prefs.setString('email', email);
        prefs.setBool('user', true);
        prefs.setString('username', email);
        prefs.setString('fullname', fullname);
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      MasterproductListForBilling: productList,
                    )));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This account is not authorized as an employee.'),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                e.message ?? 'Login failed. Check your email and password.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Check your email and password.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
