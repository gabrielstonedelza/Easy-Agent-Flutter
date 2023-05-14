import 'package:easy_agent/controllers/logincontroller.dart';
import 'package:easy_agent/screens/preregistration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../controllers/authphonecontroller.dart';
import '../widgets/loadingui.dart';
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
  late final TextEditingController _agentCodeController;
  late final TextEditingController _passwordController;
  FocusNode agentCodeFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  final AuthPhoneController authController = Get.find();
  final storage = GetStorage();
  late String uToken = "";

  final Uri _url = Uri.parse('https://fnetagents.xyz/password-reset/');


  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _agentCodeController = TextEditingController();
    _passwordController = TextEditingController();
    controller.getAllAgents();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    authController.fetchAuthPhone(uToken);
  }

  @override
  void dispose() {
    super.dispose();
    _agentCodeController.dispose();
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
              onPressed: (){
                Get.to(() => const LoginAboutPage());
              },
              child: const Text("About",style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(right:8.0),
          //   child: TextButton(
          //       onPressed: () {
          //         Get.to(() => const AgentPreRegistration());
          //       },
          //       child: const Text(
          //         "Register",
          //         style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),
          //       )),
          // )
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 60,),
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
                      controller: _agentCodeController,
                      focusNode: agentCodeFocusNode,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Agent Code"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter agent code";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
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
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                 isPosting  ? const LoadingUi() :
                 NeoPopTiltedButton(
                   isFloating: true,
                   onTapUp: () {
                     _startPosting();
                     FocusScopeNode currentFocus = FocusScope.of(context);

                     if (!currentFocus.hasPrimaryFocus) {
                       currentFocus.unfocus();
                     }
                     if (!_formKey.currentState!.validate()) {
                       return;
                     } else {
                       controller.loginUser(_agentCodeController.text.trim(),
                         _passwordController.text.trim(),);
                       storage.write("phoneAuthenticated", "Authenticated");
                       storage.write("phoneId", authController.phoneId);
                       storage.write("phoneModel", authController.phoneModel);
                       storage.write("phoneBrand", authController.phoneBrand);
                       storage.write("phoneFingerprint", authController.phoneFingerprint);
                       authController.authenticatePhone(uToken,authController.phoneId,authController.phoneModel,authController.phoneBrand,authController.phoneFingerprint);
                     }
                   },
                   decoration: const NeoPopTiltedButtonDecoration(
                     color: secondaryColor,
                     plunkColor: Color.fromRGBO(255, 235, 52, 1),
                     shadowColor: Color.fromRGBO(36, 36, 36, 1),
                     showShimmer: true,
                   ),
                   child: const Padding(
                     padding: EdgeInsets.symmetric(
                       horizontal: 70.0,
                       vertical: 15,
                     ),
                     child: Text('Login',style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 20,
                         color: Colors.white)),
                   ),
                 ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () async{
                await _launchInBrowser();
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),
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
