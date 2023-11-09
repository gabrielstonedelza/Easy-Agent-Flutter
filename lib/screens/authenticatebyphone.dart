import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:easy_agent/screens/sendsms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../controllers/authphonecontroller.dart';
import '../controllers/profilecontroller.dart';
import '../controllers/trialandmonthlypaymentcontroller.dart';
import '../widgets/loadingui.dart';
import 'login.dart';

class AuthenticateByPhone extends StatefulWidget {
  const AuthenticateByPhone({Key? key}) : super(key: key);

  @override
  State<AuthenticateByPhone> createState() => _AuthenticateByPhoneState();
}

class _AuthenticateByPhoneState extends State<AuthenticateByPhone> {
  final storage = GetStorage();
  bool hasAccountsToday = false;
  bool isLoading = true;
  late String uToken = "";
  final ProfileController controller = Get.find();
  late int oTP = 0;
  final SendSmsController sendSms = SendSmsController();
  late String userId = "";
  late String agentPhone = "";
  List profileDetails = [];
  final AuthPhoneController authController = Get.find();
  final TrialAndMonthlyPaymentController tpController = Get.find();

  generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }

  late String userEmail = "";
  late String agentUsername = "";
  late String companyName = "";

  Future<void> getUserDetails(String token) async {
    const profileLink = "https://fnetagents.xyz/get_user_details/";
    var link = Uri.parse(profileLink);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      profileDetails = jsonData;
      for (var i in profileDetails) {
        userId = i['id'].toString();
        agentPhone = i['phone_number'];
        userEmail = i['email'];
        companyName = i['company_name'];
      }

      setState(() {
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  final formKey = GlobalKey<FormState>();
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;
  bool isCompleted = false;
  bool isResent = false;

<<<<<<< HEAD
  // void startTimer() {
  //   timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (seconds > 0) {
  //       setState(() {
  //         seconds--;
  //       });
  //     } else {
  //       stopTimer(reset: false);
  //       setState(() {
  //         isCompleted = true;
  //       });
  //     }
  //   });
  // }
  //
  // void resetTimer() {
  //   setState(() {
  //     seconds = maxSeconds;
  //   });
  // }
  //
  // void stopTimer({bool reset = true}) {
  //   if (reset) {
  //     resetTimer();
  //   }
  //   timer?.cancel();
  // }

=======
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer(reset: false);
        setState(() {
          isCompleted = true;
        });
      }
    });
  }

  void resetTimer() {
    setState(() {
      seconds = maxSeconds;
    });
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    timer?.cancel();
  }

>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
  Future<void> logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");

    const logoutUrl = "https://www.fnetagents.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);

    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization":
          "Token $uToken" // Make sure to define and assign a value to uToken
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);

      storage.remove("token");
      storage.remove("agent_code");
      Get.offAll(() => const LoginView()); // Remove the const keyword
    }
  }

  Timer? myTimer;

  Future<void> sendOtp() async {
    final deUrl =
        "https://fnetagents.xyz/send_otp/$oTP/$userEmail/$agentUsername/";
    var link = Uri.parse(deUrl);
    http.Response response = await http.post(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {}
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    if (storage.read("agent_code") != null) {
      setState(() {
        agentUsername = storage.read("agent_code");
      });
    }
    getUserDetails(uToken);
    // startTimer();
    generate5digit();
    authController.fetchAuthPhone();

    // Timer(const Duration(seconds: 10), () {
    //   String num = agentPhone.replaceFirst("0", '+233');
    //   if (companyName == "Fnet Enterprise") {
    //     sendSms.sendMySms(num, "FNET", "Your code $oTP");
    //     sendOtp();
    //   } else {
    //     sendOtp();
    //     sendSms.sendMySms(num, "EasyAgent", "Your code $oTP");
    //     sendOtp();
    //   }
    // });

    myTimer = Timer(const Duration(seconds: 10), () {
      String num = agentPhone.replaceFirst("0", '+233');
      if (companyName == "Fnet Enterprise") {
        sendSms.sendMySms(num, "FNET", "Your code $oTP");
        sendOtp();
      } else {
<<<<<<< HEAD
        sendOtp();
=======
>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
        sendSms.sendMySms(num, "EasyAgent", "Your code $oTP");
        sendOtp();
      }
    });
  }

<<<<<<< HEAD
  @override
  void dispose() {
    // Cancel the timer when the widget is disposed.
    myTimer?.cancel();
    super.dispose();
  }

=======
>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadow,
      body: isLoading
          ? const LoadingUi()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 3,
                    child: Lottie.asset(
                        "assets/images/74569-two-factor-authentication.json",
                        width: 300,
                        height: 300)),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            "A code was sent to your phone and your email,please enter the code here.",
                            style: TextStyle(color: defaultWhite))),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Form(
                      key: formKey,
                      child: Pinput(
                        defaultPinTheme: defaultPinTheme,
                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsRetrieverApi,
                        validator: (pin) {
                          if (pin?.length == 4 && pin == oTP.toString()) {
                            storage.write(
                                "phoneAuthenticated", "Authenticated");
                            storage.write("phoneId", authController.phoneId);
                            storage.write(
                                "phoneModel", authController.phoneModel);
                            storage.write(
                                "phoneBrand", authController.phoneBrand);
                            storage.write("phoneFingerprint",
                                authController.phoneFingerprint);
                            // tpController.startFreeTrial(uToken);
                            authController.authenticatePhone(
                                uToken,
                                authController.phoneId,
                                authController.phoneModel,
                                authController.phoneBrand,
                                authController.phoneFingerprint);
                            Get.offAll(() => const Dashboard());
                          } else {
                            Get.snackbar(
                                "Code Error", "you entered an invalid code",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: warning,
                                duration: const Duration(seconds: 5));
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive code?",
                            style: TextStyle(color: defaultWhite)),
                        const SizedBox(
                          width: 20,
                        ),
<<<<<<< HEAD
                        TextButton(
                          onPressed: () {
                            String num = agentPhone.replaceFirst("0", '+233');
                            if (companyName == "Fnet Enterprise") {
                              sendSms.sendMySms(num, "FNET", "Your code $oTP");
                              sendOtp();
                            } else {
                              sendSms.sendMySms(
                                  num, "EasyAgent", "Your code $oTP");
                              sendOtp();
                            }
                            sendOtp();
                            Get.snackbar("Check Phone", "code was sent again",
                                backgroundColor: snackBackground,
                                colorText: defaultWhite,
                                duration: const Duration(seconds: 5));
                          },
                          child: const Text("Resend Code",
                              style: TextStyle(color: secondaryColor)),
                        )
=======
                        isCompleted
                            ? TextButton(
                                onPressed: () {
                                  String num =
                                      agentPhone.replaceFirst("0", '+233');
                                  if (companyName == "Fnet Enterprise") {
                                    sendSms.sendMySms(
                                        num, "FNET", "Your code $oTP");
                                    sendOtp();
                                  } else {
                                    sendSms.sendMySms(
                                        num, "EasyAgent", "Your code $oTP");
                                    sendOtp();
                                  }
                                  sendOtp();
                                  Get.snackbar(
                                      "Check Phone", "code was sent again",
                                      backgroundColor: snackBackground,
                                      colorText: defaultWhite,
                                      duration: const Duration(seconds: 5));
                                  startTimer();
                                  resetTimer();
                                  setState(() {
                                    isResent = true;
                                    isCompleted = false;
                                  });
                                },
                                child: const Text("Resend Code",
                                    style: TextStyle(color: secondaryColor)),
                              )
                            : Text("00:${seconds.toString()}",
                                style: const TextStyle(color: defaultWhite)),
>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
