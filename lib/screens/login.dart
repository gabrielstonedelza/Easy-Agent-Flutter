import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_agent/controllers/logincontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../controllers/authphonecontroller.dart';
import 'loginabout.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.find();
  bool isObscured = true;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  late final TextEditingController _passwordController;
  FocusNode agentCodeFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  final AuthPhoneController authController = Get.find();
  final storage = GetStorage();
  late String uToken = "";
  bool isLoading = false;

  final Uri _url = Uri.parse('https://fnetagents.xyz/password-reset/');
  late List authPhoneDetails = [];
  late List authPhoneDetailsForAgent = [];
  late List authPhoneUsernameDetailsForAgent = [];
  late String phoneModel = "";
  late String phoneId = "";
  late String phoneBrand = "";
  late String phoneFingerprint = "";
  bool isDeUser = false;
  bool canLogin = false;

  Future<void> fetchDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    phoneModel = androidInfo.model;
    phoneId = androidInfo.id;
    phoneBrand = androidInfo.brand;
    phoneFingerprint = androidInfo.fingerprint;
  }

  Future<void> fetchAuthPhone() async {
    const postUrl = "https://fnetagents.xyz/get_all_auth_phones/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      authPhoneDetails.assignAll(allPosts);

      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }

  Future<void> fetchAgentAuthPhone() async {
    final postUrl =
        "https://fnetagents.xyz/get_all_auth_phone_agent_by_phone_id/$phoneId/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      authPhoneDetailsForAgent.assignAll(allPosts);
      setState(() {
        isLoading = false;
      });
      for (var i in authPhoneDetailsForAgent) {
        if (authPhoneDetailsForAgent.isNotEmpty &&
            i['get_agent_username'] == usernameController.text.trim() &&
            i['finger_print'] == phoneFingerprint &&
            i['phone_id'] == phoneId) {
          setState(() {
            canLogin = true;
          });
        }
        if (i['get_agent_username'] != usernameController.text.trim() &&
            i['finger_print'] == phoneFingerprint &&
            i['phone_id'] == phoneId) {
          setState(() {
            canLogin = false;
          });
          Get.snackbar("Device Auth Error 😝😜🤪",
              "This device is registered to another user,please use another device,thank you.",
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              backgroundColor: warning,
              duration: const Duration(seconds: 10));
          Get.offAll(() => const LoginView());
        }
      }
    }
  }

  Future<void> fetchAgentAuthPhoneWithUsername() async {
    final postUrl =
        "https://fnetagents.xyz/get_auth_phone_by_username/${usernameController.text.trim()}/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      authPhoneUsernameDetailsForAgent.assignAll(allPosts);
      setState(() {
        isLoading = false;
      });
      for (var i in authPhoneUsernameDetailsForAgent) {
        if (authPhoneUsernameDetailsForAgent.isNotEmpty &&
            i['get_agent_username'] == usernameController.text.trim() &&
            i['finger_print'] != phoneFingerprint &&
            i['phone_id'] != phoneId) {
          Get.snackbar("Device Auth Error 😝😜🤪",
              "This device is not your authenticated device,please login with your authenticated device.",
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              backgroundColor: warning,
              duration: const Duration(seconds: 10));
          Get.offAll(() => const LoginView());
        }
        // if(i['get_agent_username'] != usernameController.text.trim() && i['finger_print'] == phoneFingerprint && i['phone_id'] == phoneId){
        //   setState(() {
        //     canLogin = false;
        //   });
        //   Get.snackbar("Device Auth Error 😝😜🤪", "This device is registered to another user,please use another device,thank you.",
        //       colorText: Colors.white,
        //       snackPosition: SnackPosition.TOP,
        //       backgroundColor: warning,
        //       duration: const Duration(seconds: 10));
        //   Get.offAll(() => const LoginView());
        // }
      }
    }
  }

  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    _passwordController = TextEditingController();
    controller.getAllAgents();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchDeviceInfo();
    fetchAuthPhone();
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: TextButton(
              onPressed: () {
                Get.to(() => const LoginAboutPage());
              },
              child: const Text(
                "About",
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 60,
          ),
          Image.asset(
            "assets/images/forapp.png",
            width: 100,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: usernameController,
                      focusNode: agentCodeFocusNode,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Username"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter username";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        if (value.length > 1) {
                          fetchAgentAuthPhone();
                          fetchAgentAuthPhoneWithUsername();
                        }
                      },
                      controller: _passwordController,
                      focusNode: passwordFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorColor: secondaryColor,
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: secondaryColor),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: Icon(
                              isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: secondaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      obscureText: isObscured,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  controller.isLoggingIn
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RawMaterialButton(
                            fillColor: snackBackground,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onPressed: () {},
                            child: const Text(
                              "Logging you in please wait",
                              style: TextStyle(
                                  color: defaultWhite,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RawMaterialButton(
                            fillColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onPressed: () {
                              controller.isLoggingIn = true;
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (!_formKey.currentState!.validate()) {
                                return;
                              } else {
                                controller.loginUser(
                                  usernameController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: defaultWhite,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () async {
                await _launchInBrowser();
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
