import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_agent/controllers/customerscontroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:telephony/telephony.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class CashIn extends StatefulWidget {
  const CashIn({Key? key}) : super(key: key);

  @override
  State<CashIn> createState() => _CashInState();
}

class _CashInState extends State<CashIn> {
  final CustomersController controller = Get.find();
  bool isPosting = false;
  final telephony = Telephony.instance;
  sendSMS() {
    telephony.sendSms(
      to: "0593380008",
      message: "The Lord bless you and keep you",
    );
  }

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final List networks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone",
  ];

  var _currentSelectedNetwork = "Select Network";

  final List depositTypes = ["Select deposit type", "Loading", "Direct"];

  var _currentSelectedDepositType = "Select deposit type";

  late final TextEditingController _amountController;
  late final TextEditingController _cashReceivedController;
  late final TextEditingController _amountReceivedController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _depositorNameController;
  late final TextEditingController _depositorNumberController;
  // late final TextEditingController _d200Controller;
  // late final TextEditingController _d100Controller;
  // late final TextEditingController _d50Controller;
  // late final TextEditingController _d20Controller;
  // late final TextEditingController _d10Controller;
  // late final TextEditingController _d5Controller;
  // late final TextEditingController _d2Controller;
  // late final TextEditingController _d1Controller;
  //
  // late int d200 = 0;
  // late int d100 = 0;
  // late int d50 = 0;
  // late int d20 = 0;
  // late int d10 = 0;
  // late int d5 = 0;
  // late int d2 = 0;
  // late int d1 = 0;
  // late int total = 0;
  bool amountNotEqualTotal = false;
  FocusNode amountFocusNode = FocusNode();
  FocusNode cashReceivedFocusNode = FocusNode();
  FocusNode amountReceivedFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();
  FocusNode depositorNameFocusNode = FocusNode();
  FocusNode depositorNumberFocusNode = FocusNode();
  // FocusNode d200FocusNode = FocusNode();
  // FocusNode d100FocusNode = FocusNode();
  // FocusNode d50FocusNode = FocusNode();
  // FocusNode d20FocusNode = FocusNode();
  // FocusNode d10FocusNode = FocusNode();
  // FocusNode d5FocusNode = FocusNode();
  // FocusNode d2FocusNode = FocusNode();
  // FocusNode d1FocusNode = FocusNode();
  bool isCustomer = false;
  bool isDirect = false;
  bool isMtnLoading = false;
  double totalNow = 0.0;
  bool amountIsNotEmpty = false;
  double commission = 0.0;

  Future<void> dialCashInMtn(String customerNumber, String amount) async {
    UssdAdvanced.multisessionUssd(
        code: "*171*3*1*$customerNumber*$customerNumber*$amount#",
        subscriptionId: 1);
  }

  late String uToken = "";
  final storage = GetStorage();
  bool isLoading = true;

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
  late List allFraudsters = [];
  bool isFraudster = false;
  late int oTP = 0;
  bool hasOTP = false;
  bool sentOTP = false;
  final SendSmsController sendSms = SendSmsController();

  generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }

  Future<void> getAllFraudsters() async {
    try {
      const url = "https://fnetagents.xyz/get_all_fraudsters/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allFraudsters.assignAll(jsonData);
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  ProfileController profileController = Get.find();

  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";
  late String userEmail = "";
  late String agentUsername = "";
  late String companyName = "";
  late String userId = "";
  late String agentPhone = "";
  List profileDetails = [];

  Future<void> fetchOwnersDetails() async {
    final postUrl =
        "https://fnetagents.xyz/get_supervisor_with_code/${profileController.ownerCode}/";
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
      ownerDetails.assignAll(allPosts);
      for (var i in ownerDetails) {
        ownerId = i['id'].toString();
        ownerUsername = i['username'];
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
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

  processMomoDeposit() async {
    const registerUrl = "https://fnetagents.xyz/post_momo_deposit/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "owner": ownerId,
      "agent": profileController.userId,
      "depositor_name": _depositorNameController.text.trim(),
      "depositor_number": _depositorNumberController.text.trim(),
      "network": _currentSelectedNetwork,
      "type": _currentSelectedDepositType,
      "amount_sent": _amountController.text.trim(),
      "cash_received": _currentSelectedDepositType == "Loading"
          ? _amountController.text.trim()
          : _cashReceivedController.text.trim(),
      "customer": _customerPhoneController.text.trim(),
      // "d_200": _d200Controller.text.trim(),
      // "d_100": _d100Controller.text.trim(),
      // "d_50": _d50Controller.text.trim(),
      // "d_20": _d20Controller.text.trim(),
      // "d_10": _d10Controller.text.trim(),
      // "d_5": _d5Controller.text.trim(),
      // "d_2": _d2Controller.text.trim(),
      // "d_1": _d1Controller.text.trim(),
    });

    if (res.statusCode == 201) {
      if (_currentSelectedDepositType == "Direct") {
        String num = _depositorNumberController.text.replaceFirst("0", '+233');
        if(companyName == "Fnet Enterprise"){
          sendSms.sendMySms(num, "FNET","Your deposit of ${_amountController.text.trim()} by ${profileController.companyName} was successful.For more information please call ${profileController.companyNumber}.Thank you for working with Easy Agent.");
        }
        else{
          sendSms.sendMySms(num, "EasyAgent","Your deposit of ${_amountController.text.trim()} by ${profileController.companyName} was successful.For more information please call ${profileController.companyNumber}.Thank you for working with Easy Agent.");
        }
        // sendSms.sendMySms(num, "EasyAgent",
        //     "Your deposit of ${_amountController.text.trim()} by ${profileController.companyName} was successful.For more information please call ${profileController.companyNumber}.Thank you for working with Easy Agent.");
      }
      if (_currentSelectedNetwork == "Mtn") {
        mtn = mtnNow - double.parse(_amountController.text);
        physical = physicalNow + double.parse(_amountController.text);
        //
        airteltigo = airtelTigoNow;
        vodafone = vodafoneNow;
      }
      if (_currentSelectedNetwork == "AirtelTigo") {
        airteltigo = airtelTigoNow - double.parse(_amountController.text);
        physical = physicalNow + double.parse(_amountController.text);
        //
        mtn = mtnNow;
        vodafone = vodafoneNow;
      }
      if (_currentSelectedNetwork == "Vodafone") {
        vodafone = vodafoneNow - double.parse(_amountController.text);
        physical = physicalNow + double.parse(_amountController.text);
        //
        mtn = mtnNow;
        airteltigo = airtelTigoNow;
      }
      addAccountsToday();

      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      if (_currentSelectedNetwork == "Mtn") {
        dialCashInMtn(_customerPhoneController.text.trim(),
            _amountController.text.trim());
      }

      Get.offAll(() => const Dashboard());
    } else {
      if (kDebugMode) {
        print(res.body);
      }
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
      "agent": profileController.userId,
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
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchOwnersDetails();
    generate5digit();
    getUserDetails(uToken);
    _amountController = TextEditingController();
    _cashReceivedController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _depositorNameController = TextEditingController();
    _depositorNumberController = TextEditingController();
    // _d200Controller = TextEditingController();
    // _d100Controller = TextEditingController();
    // _d50Controller = TextEditingController();
    // _d20Controller = TextEditingController();
    // _d10Controller = TextEditingController();
    // _d5Controller = TextEditingController();
    // _d2Controller = TextEditingController();
    // _d1Controller = TextEditingController();
    _amountReceivedController = TextEditingController();
    controller.getAllCustomers(uToken);
    controller.getAllFraudsters(uToken);
    fetchAccountBalance();
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _customerPhoneController.dispose();
    _depositorNameController.dispose();
    _depositorNumberController.dispose();
    // _d200Controller.dispose();
    // _d100Controller.dispose();
    // _d50Controller.dispose();
    // _d20Controller.dispose();
    // _d10Controller.dispose();
    // _d5Controller.dispose();
    // _d2Controller.dispose();
    // _d1Controller.dispose();
    _amountReceivedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cash In",
              style: TextStyle(fontWeight: FontWeight.bold)),
          // actions: [
          //   TextButton(onPressed: () { sendSMS(); },child: Text("Hello"),)
          // ],
        ),
        body: isLoading
            ? const LoadingUi()
            : ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      "Note: Please make sure to allow Easy Agent access in your phones accessibility before proceeding",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: warning),
                    ),
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
                              onChanged: (value) {
                                if (value.length == 10 &&
                                    controller.fraudsterNumbers
                                        .contains(value)) {
                                  setState(() {
                                    isFraudster = true;
                                  });
                                  Get.snackbar("Customer Error",
                                      "This customer is in the fraud lists.",
                                      colorText: defaultWhite,
                                      snackPosition: SnackPosition.TOP,
                                      duration: const Duration(seconds: 10),
                                      backgroundColor: warning);
                                  Get.defaultDialog(
                                      buttonColor: primaryColor,
                                      title: "Fraud Alert",
                                      middleText:
                                          "This customer is in the fraud list,continue",
                                      confirm: RawMaterialButton(
                                          shape: const StadiumBorder(),
                                          fillColor: secondaryColor,
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: const Text(
                                            "Yes",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                      cancel: RawMaterialButton(
                                          shape: const StadiumBorder(),
                                          fillColor: secondaryColor,
                                          onPressed: () {
                                            Get.offAll(() => const Dashboard());
                                          },
                                          child: const Text(
                                            "No",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )));
                                } else {
                                  setState(() {
                                    isFraudster = false;
                                  });
                                }
                              },
                              controller: _customerPhoneController,
                              focusNode: customerPhoneFocusNode,
                              cursorRadius: const Radius.elliptical(10, 10),
                              cursorWidth: 10,
                              cursorColor: secondaryColor,
                              decoration:
                                  buildInputDecoration("Customer's Number"),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter customer's number";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey, width: 1)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: DropdownButton(
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: networks.map((dropDownStringItem) {
                                    return DropdownMenuItem(
                                      value: dropDownStringItem,
                                      child: Text(dropDownStringItem),
                                    );
                                  }).toList(),
                                  onChanged: (newValueSelected) {
                                    _onDropDownItemSelectedNetwork(
                                        newValueSelected);
                                    if (newValueSelected == "Mtn") {
                                      setState(() {
                                        isMtn = true;
                                      });
                                    } else {
                                      setState(() {
                                        isMtn = false;
                                      });
                                    }
                                  },
                                  value: _currentSelectedNetwork,
                                ),
                              ),
                            ),
                          ),
                          isMtn
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey, width: 1)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        items: depositTypes
                                            .map((dropDownStringItem) {
                                          return DropdownMenuItem(
                                            value: dropDownStringItem,
                                            child: Text(dropDownStringItem),
                                          );
                                        }).toList(),
                                        onChanged: (newValueSelected) {
                                          _onDropDownItemSelectedDepositType(
                                              newValueSelected);
                                          if (newValueSelected == "Direct") {
                                            setState(() {
                                              isDirect = true;
                                              isMtnLoading = false;
                                              sentOTP = false;
                                            });
                                          }
                                          if (newValueSelected == "Loading") {
                                            String num =
                                                _customerPhoneController.text
                                                    .replaceFirst("0", '+233');
                                            sendSms.sendMySms(num, "EasyAgent",
                                                "Your code $oTP");
                                            setState(() {
                                              isDirect = false;
                                              isMtnLoading = true;
                                              sentOTP = true;
                                              _cashReceivedController.text =
                                                  _amountController.text;
                                            });
                                          }
                                        },
                                        value: _currentSelectedDepositType,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          sentOTP && !hasOTP
                              ? const Text(
                                  "An OTP was sent to the customers phone,enter it here",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                )
                              : Container(),
                          sentOTP && !hasOTP
                              ? const SizedBox(
                                  height: 20,
                                )
                              : Container(),
                          sentOTP && !hasOTP
                              ? Pinput(
                                  // defaultPinTheme: defaultPinTheme,
                                  androidSmsAutofillMethod:
                                      AndroidSmsAutofillMethod.smsRetrieverApi,
                                  validator: (pin) {
                                    if (pin?.length == 4 &&
                                        pin == oTP.toString()) {
                                      setState(() {
                                        hasOTP = true;
                                      });
                                    } else {
                                      setState(() {
                                        hasOTP = false;
                                      });
                                      Get.snackbar("Code Error",
                                          "you entered an invalid code",
                                          colorText: defaultWhite,
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: warning,
                                          duration: const Duration(seconds: 5));
                                    }
                                    return null;
                                  },
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          isDirect
                              ? Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: TextFormField(
                                        controller: _depositorNameController,
                                        focusNode: depositorNameFocusNode,
                                        cursorRadius:
                                            const Radius.elliptical(10, 10),
                                        cursorWidth: 10,
                                        cursorColor: secondaryColor,
                                        decoration: buildInputDecoration(
                                            "Depositor's Name"),
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter depositors name";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: TextFormField(
                                        controller: _depositorNumberController,
                                        focusNode: depositorNumberFocusNode,
                                        cursorRadius:
                                            const Radius.elliptical(10, 10),
                                        cursorWidth: 10,
                                        cursorColor: secondaryColor,
                                        decoration: buildInputDecoration(
                                            "Depositor's Number"),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter depositors number";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                if (value.length > 1 &&
                                    value != "" &&
                                    _currentSelectedDepositType == "Loading") {
                                  setState(() {
                                    amountIsNotEmpty = true;
                                  });
                                }
                                if (value == "") {
                                  setState(() {
                                    amountIsNotEmpty = false;
                                  });
                                }
                              },
                              controller: _amountController,
                              focusNode: amountFocusNode,
                              cursorRadius: const Radius.elliptical(10, 10),
                              cursorWidth: 10,
                              cursorColor: secondaryColor,
                              decoration: buildInputDecoration("Amount Sent"),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter amount";
                                }
                                return null;
                              },
                            ),
                          ),
                          isDirect
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      if (value.length > 1 && value != "") {
                                        setState(() {
                                          amountIsNotEmpty = true;
                                        });
                                      }
                                      if (value == "") {
                                        setState(() {
                                          amountIsNotEmpty = false;
                                        });
                                      }
                                    },
                                    controller: _cashReceivedController,
                                    focusNode: cashReceivedFocusNode,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    cursorColor: secondaryColor,
                                    decoration:
                                        buildInputDecoration("Cash Received"),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty && isMtnLoading) {
                                        return "Please enter cash received";
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              : Container(),
                          isDirect
                              ? _cashReceivedController.text != "" &&
                                      double.parse(
                                              _cashReceivedController.text) >
                                          double.parse(_amountController.text)
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          const Text("Commission is : "),
                                          Text(
                                              "${double.parse(_cashReceivedController.text) - double.parse(_amountController.text)}"),
                                        ],
                                      ),
                                    )
                                  : Container()
                              : Container(),
                          // amountIsNotEmpty
                          //     ? Column(
                          //         children: [
                          //           Row(
                          //             children: [
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d200 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                             dt = int.parse(value) * 200;
                          //                             d200 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d200FocusNode,
                          //                         controller: _d200Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "200 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d200.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //               const SizedBox(
                          //                 width: 10,
                          //               ),
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 100;
                          //                           // setState(() {
                          //                           //   d100 = dt;
                          //                           // });
                          //
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d100 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 100;
                          //                               d100 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         controller: _d100Controller,
                          //                         focusNode: d100FocusNode,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "100 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d100.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //           Row(
                          //             children: [
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 50;
                          //                           // setState(() {
                          //                           //   d50 = dt;
                          //                           // });
                          //
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d50 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 50;
                          //                               d50 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d50FocusNode,
                          //                         controller: _d50Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "50 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d50.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //               const SizedBox(
                          //                 width: 10,
                          //               ),
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 20;
                          //                           // setState(() {
                          //                           //   d20 = dt;
                          //                           // });
                          //                           //
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d20 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 20;
                          //                               d20 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d20FocusNode,
                          //                         controller: _d20Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "20 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d20.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //           Row(
                          //             children: [
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 10;
                          //                           // setState(() {
                          //                           //   d10 = dt;
                          //                           // });
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d10 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 10;
                          //                               d10 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d10FocusNode,
                          //                         controller: _d10Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "10 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d10.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //               const SizedBox(
                          //                 width: 10,
                          //               ),
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 5;
                          //                           // setState(() {
                          //                           //   d5 = dt;
                          //                           // });
                          //
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d5 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 5;
                          //                               d5 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d5FocusNode,
                          //                         controller: _d5Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "5 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d5.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //           Row(
                          //             children: [
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 2;
                          //                           // setState(() {
                          //                           //   d2 = dt;
                          //                           // });
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d2 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 2;
                          //                               d2 = dt;
                          //                             });
                          //                           }
                          //
                          //                         },
                          //                         focusNode: d2FocusNode,
                          //                         controller: _d2Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "2GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d2.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //               const SizedBox(
                          //                 width: 10,
                          //               ),
                          //               Expanded(
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.only(
                          //                       bottom: 10.0),
                          //                   child: Column(
                          //                     children: [
                          //                       TextFormField(
                          //                         onChanged: (value) {
                          //                           // var dt =
                          //                           //     int.parse(value) * 1;
                          //                           // setState(() {
                          //                           //   d1 = dt;
                          //                           // });
                          //                           var dt = 0;
                          //                           if(value.isEmpty){
                          //                             setState(() {
                          //                               dt = 0;
                          //                               d1 = 0;
                          //                             });
                          //                           }
                          //                           else{
                          //                             setState(() {
                          //                               dt = int.parse(value) * 1;
                          //                               d1 = dt;
                          //                             });
                          //                           }
                          //                         },
                          //                         focusNode: d1FocusNode,
                          //                         controller: _d1Controller,
                          //                         cursorColor: secondaryColor,
                          //                         cursorRadius:
                          //                             const Radius.elliptical(
                          //                                 10, 10),
                          //                         cursorWidth: 10,
                          //                         decoration:
                          //                             buildInputDecoration(
                          //                                 "1 GHC Notes"),
                          //                         keyboardType:
                          //                             TextInputType.number,
                          //                       ),
                          //                       Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 12.0,
                          //                                 bottom: 12),
                          //                         child: Text(
                          //                           d1.toString(),
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //           Row(
                          //             children: [
                          //               Expanded(
                          //                   child: amountNotEqualTotal
                          //                       ? Text(
                          //                           "TOTAL: $total",
                          //                           style: const TextStyle(
                          //                               fontWeight:
                          //                                   FontWeight.bold,
                          //                               color: Colors.red,
                          //                               fontSize: 20),
                          //                         )
                          //                       : const Text("")),
                          //               const SizedBox(
                          //                 width: 10,
                          //               ),
                          //               const Expanded(child: Text(""))
                          //             ],
                          //           ),
                          //         ],
                          //       )
                          //     : Container(),
                          const SizedBox(
                            height: 30,
                          ),
                          isPosting
                              ? const LoadingUi()
                              : amountIsNotEmpty && !isFraudster
                                  ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RawMaterialButton(
                              fillColor: secondaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              onPressed: (){
                                _startPosting();
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);
                                if (_currentSelectedDepositType ==
                                    "Loading") {
                                  _cashReceivedController.text =
                                      _amountController.text;
                                }

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (!_formKey.currentState!
                                    .validate()) {
                                  return;
                                } else {
                                  // var mainTotal = d200 +
                                  //     d100 +
                                  //     d50 +
                                  //     d20 +
                                  //     d10 +
                                  //     d5 +
                                  //     d2 +
                                  //     d1;
                                  if (_currentSelectedDepositType ==
                                      "Select deposit type" &&
                                      _currentSelectedNetwork ==
                                          "Mtn") {
                                    Get.snackbar(
                                        "Network or Type Error",
                                        "please select network and type",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  } else if (_currentSelectedNetwork ==
                                      "Select Network") {
                                    Get.snackbar("Network Error",
                                        "please select network",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  } else if (_currentSelectedNetwork ==
                                      "Mtn" &&
                                      double.parse(
                                          _amountController.text) >
                                          mtnNow) {
                                    Get.snackbar("Amount Error",
                                        "Amount is greater than your Mtn Ecash,please check",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  } else if (_currentSelectedNetwork ==
                                      "AirtelTigo" &&
                                      double.parse(
                                          _amountController.text) >
                                          airtelTigoNow) {
                                    Get.snackbar("Amount Error",
                                        "Amount is greater than your AirtelTigo Ecash,please check",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  } else if (_currentSelectedNetwork ==
                                      "Vodafone" &&
                                      double.parse(
                                          _amountController.text) >
                                          vodafoneNow) {
                                    Get.snackbar("Amount Error",
                                        "Amount is greater than your Vodafone Ecash,please check",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  }
                                  else if (double.parse(_cashReceivedController.text) < double.parse(_amountController.text)) {
                                    Get.snackbar("Amount Error",
                                        "Cash received cannot be less than amount",
                                        colorText: defaultWhite,
                                        backgroundColor: warning,
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                        duration:
                                        const Duration(seconds: 5));
                                    return;
                                  }

                                  else {
                                    processMomoDeposit();
                                  }
                                }
                              },child: const Text("Send",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                            ),
                          )
                                  : Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ));
  }

  void _onDropDownItemSelectedNetwork(newValueSelected) {
    setState(() {
      _currentSelectedNetwork = newValueSelected;
    });
  }

  void _onDropDownItemSelectedDepositType(newValueSelected) {
    setState(() {
      _currentSelectedDepositType = newValueSelected;
    });
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

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: secondaryColor),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
