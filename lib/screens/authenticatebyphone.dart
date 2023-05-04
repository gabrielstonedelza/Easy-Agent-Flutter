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


  generate5digit(){
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }

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
      for(var i in profileDetails){
        userId = i['id'].toString();
        agentPhone = i['phone_number'];
      }

      setState(() {
        isLoading = false;
      });
    }
    else{
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

  void startTimer(){
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if(seconds > 0){
          setState(() {
            seconds --;
          });
        }
        else{
          stopTimer(reset: false);
          setState(() {
            isCompleted = true;
          });
        }
      });
  }

  void resetTimer(){
    setState(() {
      seconds = maxSeconds;
    });
  }

  void stopTimer({bool reset = true}){
    if(reset){
      resetTimer();
    }
    timer?.cancel();
  }

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getUserDetails(uToken);
    startTimer();
    generate5digit();
    Timer(const Duration(seconds: 10), () {
      String num = agentPhone.replaceFirst("0", '+233');
      sendSms.sendMySms(num, "Easy Agent","Your code $oTP");
      // print(authController.phoneBrand);
      // print(authController.phoneModel);
      // print(authController.phoneId);
      // print(authController.phoneFingerprint);
    }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadow,
      body: isLoading  ? const LoadingUi() : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/images/74569-two-factor-authentication.json",width: 300,height: 300),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child:Text("A code was sent to your phone,please enter the code here.",style:TextStyle(color:defaultWhite))
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Form(
              key: formKey,
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
                androidSmsAutofillMethod:  AndroidSmsAutofillMethod.smsRetrieverApi,
                validator: (pin) {
                  if (pin?.length == 4 && pin == oTP.toString()){
                    storage.write("phoneAuthenticated", "Authenticated");
                    authController.authenticatePhone(uToken,authController.phoneId,authController.phoneModel,authController.phoneBrand,authController.phoneFingerprint);
                    tpController.startFreeTrial(uToken);
                    Get.offAll(()=> const Dashboard());
                  }
                  else{
                    Get.snackbar("Code Error", "you entered an invalid code",
                        colorText: defaultWhite,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: warning,
                        duration: const Duration(seconds: 5));
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive code?",style:TextStyle(color:defaultWhite)),
                const SizedBox(width: 20,),
               isCompleted ? TextButton(
                 onPressed: (){
                   String num = agentPhone.replaceFirst("0", '+233');
                   sendSms.sendMySms(num, "Easy Agent","Your code $oTP");
                   Get.snackbar(
                       "Check Phone","code was sent again",
                     backgroundColor: snackBackground,
                     colorText: defaultWhite,
                     duration: const Duration(seconds: 5)
                   );
                   startTimer();
                   resetTimer();
                   setState(() {
                     isResent = true;
                     isCompleted = false;
                   });
                 },
                 child: const Text("Resend Code",style:TextStyle(color:secondaryColor)),
               ) : Text("00:${seconds.toString()}",style:const TextStyle(color:defaultWhite)),
              ],
            ),
          )
        ],
      ),
    );
  }
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
