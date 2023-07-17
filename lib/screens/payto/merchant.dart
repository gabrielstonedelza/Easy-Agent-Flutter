import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/customerscontroller.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class PayToMerchant extends StatefulWidget {
  const PayToMerchant({Key? key}) : super(key: key);

  @override
  State<PayToMerchant> createState() => _PayToMerchantState();
}

class _PayToMerchantState extends State<PayToMerchant> {
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

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _merchantIdController;
  late final TextEditingController _referenceController;
  late final TextEditingController _depositorPhoneController;

  late String uToken = "";
  final storage = GetStorage();
  bool isLoading = false;
  FocusNode amountFocusNode = FocusNode();
  FocusNode agentPhoneFocusNode = FocusNode();
  FocusNode merchantIdFocusNode = FocusNode();
  FocusNode referenceFocusNode = FocusNode();
  FocusNode depositorPhoneFocusNode = FocusNode();

  Future<void> dialPayToMerchant(String merchantId,String amount,String reference) async {
    UssdAdvanced.multisessionUssd(code: "*171*1*2*$merchantId*$amount*$reference#",subscriptionId: 1);
  }

  late List accountBalanceDetailsToday = [];
  late List lastItem = [];
  late double physical = 0.0;
  late double mtn = 0.0;
  late double airteltigo = 0.0;
  late double vodafone = 0.0;
  late double eCash = 0.0;
  late double mtnNow = 0.0;
  late double airtelTigoNow = 0.0;
  late double vodafoneNow = 0.0;
  late double physicalNow = 0.0;
  late double eCashNow = 0.0;
  bool isMtn = false;
  final CustomersController controller = Get.find();
  final SendSmsController sendSms = SendSmsController();
  late String userEmail = "";
  late String agentUsername = "";
  late String companyName = "";
  late String userId = "";
  late String agentPhone = "";
  List profileDetails = [];

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
        userEmail = i['email'];
        companyName = i['company_name'];
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


  processPayToMerchant() async {
    const registerUrl = "https://fnetagents.xyz/add_pay_to/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "amount": _amountController.text.trim(),
      "customer": _merchantIdController.text.trim(),
      "depositor_number": _depositorPhoneController.text.trim(),
      "pay_to_type": "Merchant",
      "reference": _referenceController.text.trim(),
    });

    if (res.statusCode == 201) {
      mtn = mtnNow - double.parse(_amountController.text);
      physical = physicalNow + double.parse(_amountController.text);
      airteltigo = airtelTigoNow;
      vodafone = vodafoneNow;

      addAccountsToday();
      String num = _depositorPhoneController.text.replaceFirst("0", '+233');
      if(companyName == "Fnet Enterprise"){
        sendSms.sendMySms(num, "FNET","Amount GHC${_amountController.text} paid to merchant id ${_merchantIdController.text} transaction was successful,.");
      }
      else{
        sendSms.sendMySms(num, "EasyAgent","Amount GHC${_amountController.text} paid to merchant id ${_merchantIdController.text} transaction was successful,.");
      }
      // sendSms.sendMySms(num, "EasyAgent","Amount GHC${_amountController.text} paid to merchant id ${_merchantIdController.text} transaction was successful,");

      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      dialPayToMerchant(_merchantIdController.text.trim(),_amountController.text.trim(),_referenceController.text.trim());

      Get.offAll(() => const Dashboard());
    } else {

      Get.snackbar("Deposit Error", "something went wrong please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  Future<void> fetchAccountBalance() async {
    const postUrl =
        "https://fnetagents.xyz/get_my_account_balance_started_today/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      accountBalanceDetailsToday.assignAll(allPosts);
      setState(() {
        isLoading = false;
        lastItem.assign(accountBalanceDetailsToday.last);
        physicalNow = double.parse(lastItem[0]['physical']);
        mtnNow = double.parse(lastItem[0]['mtn_e_cash']);
        airtelTigoNow = double.parse(lastItem[0]['tigo_airtel_e_cash']);
        vodafoneNow = double.parse(lastItem[0]['vodafone_e_cash']);
        eCashNow = double.parse(lastItem[0]['mtn_e_cash']) +
            double.parse(lastItem[0]['tigo_airtel_e_cash']) +
            double.parse(lastItem[0]['vodafone_e_cash']);
      });
    } else {
      // print(res.body);
    }
  }

  final ProfileController profileController = Get.find();
  addAccountsToday() async {
    const accountUrl = "https://fnetagents.xyz/add_balance_to_start/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physical.toString(),
      "mtn_e_cash": mtn.toString(),
      "tigo_airtel_e_cash": airteltigo.toString(),
      "vodafone_e_cash": vodafone.toString(),
      "isStarted": "True",
      "agent": profileController.userId
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You accounts is updated",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);

      // Get.offAll(() => const Dashboard());
    } else {
      Get.snackbar("Account", "something happened",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    _amountController = TextEditingController();
    _merchantIdController = TextEditingController();
    _referenceController = TextEditingController();
    _depositorPhoneController = TextEditingController();
    fetchAccountBalance();
    getUserDetails(uToken);
    controller.getAllFraudsters(uToken);
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _merchantIdController.dispose();
    _referenceController.dispose();
    _depositorPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay to merchant",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: snackBackground,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(18.0),
            child: Text("Note: Please make sure to allow Easy Agent access in your phones accessibility before proceeding",style: TextStyle(fontWeight: FontWeight.bold,color: warning),),
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
                      controller: _merchantIdController,
                      focusNode: merchantIdFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Merchant Id"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter merchant id";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
                      focusNode: amountFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _referenceController,
                      focusNode: referenceFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Reference"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter reference";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _depositorPhoneController,
                      focusNode: depositorPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Depositor Phone"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter phone";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30,),
                  isPosting  ? const LoadingUi() :

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawMaterialButton(
                      fillColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      onPressed: (){
                        _startPosting();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (!_formKey.currentState!.validate()) {
                          return;
                        } else {
                          if(int.parse(_amountController.text) > mtnNow){
                            Get.snackbar("Amount Error", "Amount is greater than your Mtn Ecash,please check",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                            return;
                          }
                          else{
                            processPayToMerchant();
                          }
                        }
                      },child: const Text("Send",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            ),
          )

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
