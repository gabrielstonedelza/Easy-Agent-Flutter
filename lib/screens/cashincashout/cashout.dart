import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_agent/controllers/customerscontroller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pinput/pinput.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../customers/registercustomer.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class CashOut extends StatefulWidget {
  const CashOut({Key? key}) : super(key: key);

  @override
  State<CashOut> createState() => _CashOutState();
}

class _CashOutState extends State<CashOut> {
  final CustomersController controller = Get.find();
  bool isPosting = false;

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

  late final TextEditingController _cashPaidController;
  late final TextEditingController _amountReceivedController;
  late final TextEditingController _customerPhoneController;

  bool amountNotEqualTotal = false;
  FocusNode cashPaidFocusNode = FocusNode();
  FocusNode amountReceivedFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();
  bool isCustomer = false;
  bool isDirect = false;
  double totalNow = 0.0;
  bool amountIsNotEmpty = false;
  final SendSmsController sendSms = SendSmsController();

  Future<void> dialCashOutMtn(String customerNumber, String amount) async {
    UssdAdvanced.multisessionUssd(
        code: "*171*2*1*$customerNumber*$customerNumber*$amount#",
        subscriptionId: 1);
  }

  late List accountBalanceDetailsToday = [];
  bool isLoading = true;
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

  late String uToken = "";
  final storage = GetStorage();
  bool isDeCustomer = false;
  late List myCustomerDetails = [];
  late String customerName = "";
  late String cUniqueCode = "";
  late String customerPic = "";
  late int oTP = 0;

  bool isFraudster = false;

  fetchCustomer(String customerPhone) async {
    final url =
        "https://fnetagents.xyz/customer_details_by_phone/$customerPhone/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      myCustomerDetails = json.decode(jsonData);
      for (var i in myCustomerDetails) {
        setState(() {
          customerName = i['name'];
          cUniqueCode = i['unique_code'];
          customerPic = i['get_customer_pic'];
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  ProfileController profileController = Get.find();
  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";

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

  processMomoWithdrawal() async {
    const registerUrl = "https://fnetagents.xyz/post_momo_withdrawal/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "owner": ownerId,
      "agent": profileController.userId,
      "network": _currentSelectedNetwork,
      "cash_paid": _cashPaidController.text.trim(),
      "amount_received": _amountReceivedController.text.trim(),
      "customer": _customerPhoneController.text.trim(),
    });

    if (res.statusCode == 201) {
      if (_currentSelectedNetwork == "Mtn") {
        mtn = mtnNow + double.parse(_cashPaidController.text);
        physical = physicalNow - double.parse(_cashPaidController.text);
        //
        airteltigo = airtelTigoNow;
        vodafone = vodafoneNow;
      }
      if (_currentSelectedNetwork == "AirtelTigo") {
        airteltigo = airtelTigoNow + double.parse(_cashPaidController.text);
        physical = physicalNow - double.parse(_cashPaidController.text);
        mtn = mtnNow;
        vodafone = vodafoneNow;
      }
      if (_currentSelectedNetwork == "Vodafone") {
        vodafone = vodafoneNow + double.parse(_cashPaidController.text);
        physical = physicalNow - double.parse(_cashPaidController.text);
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
        dialCashOutMtn(_customerPhoneController.text.trim(),
            _amountReceivedController.text.trim());
      }

      Get.offAll(() => const Dashboard());
    } else {
      // print(res.body);
      Get.snackbar("Withdrawal Error", "something went wrong please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
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
      Get.snackbar("Success", "Your accounts was updated",
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

  bool hasOTP = false;
  bool sentOTP = false;

  generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(9000) + 1000;
    oTP = rand.toInt();
  }

  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;
  bool isCompleted = false;
  bool isResent = false;

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

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    startTimer();
    generate5digit();
    fetchOwnersDetails();
    // getAllFraudsters();
    _cashPaidController = TextEditingController();
    _amountReceivedController = TextEditingController();
    _customerPhoneController = TextEditingController();
    controller.getAllCustomers(uToken);
    controller.getAllFraudsters(uToken);
    fetchAccountBalance();
  }

  @override
  void dispose() {
    super.dispose();
    _cashPaidController.dispose();
    _customerPhoneController.dispose();
    _amountReceivedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Out",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Note: Please make sure to allow Easy Agent access in your phones accessibility before proceeding",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: warning),
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
                                  controller.fraudsterNumbers.contains(value)) {
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
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    cancel: RawMaterialButton(
                                        shape: const StadiumBorder(),
                                        fillColor: secondaryColor,
                                        onPressed: () {
                                          Get.offAll(() => const Dashboard());
                                        },
                                        child: const Text(
                                          "No",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              } else {
                                setState(() {
                                  isFraudster = false;
                                });
                              }
                              if (!isFraudster &&
                                  value.length == 10 &&
                                  controller.customersNumbers.contains(value)) {
                                Get.snackbar(
                                    "Success", "Customer is registered",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: snackBackground);
                                String num = _customerPhoneController.text
                                    .replaceFirst("0", '+233');
                                sendSms.sendMySms(
                                    num, "EasyAgent", "Your code $oTP");
                                setState(() {
                                  isCustomer = true;
                                  sentOTP = true;
                                  fetchCustomer(_customerPhoneController.text);
                                });
                              } else if (!isFraudster &&
                                  value.length == 10 &&
                                  !controller.customersNumbers
                                      .contains(value)) {
                                Get.snackbar("Customer Error",
                                    "Customer is not registered",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red);
                                setState(() {
                                  isCustomer = false;
                                  sentOTP = false;
                                });
                                Get.defaultDialog(
                                    buttonColor: primaryColor,
                                    title: "Confirm customer",
                                    middleText:
                                        "Customer is not registered,register him",
                                    confirm: RawMaterialButton(
                                        shape: const StadiumBorder(),
                                        fillColor: secondaryColor,
                                        onPressed: () {
                                          Get.to(() =>
                                              const CustomerRegistration());
                                        },
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    cancel: RawMaterialButton(
                                        shape: const StadiumBorder(),
                                        fillColor: secondaryColor,
                                        onPressed: () {
                                          setState(() {
                                            hasOTP = true;
                                          });
                                          Get.back();
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        )));
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
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
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
                                },
                                value: _currentSelectedNetwork,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        sentOTP && !hasOTP
                            ? const Text(
                                "An OTP was sent to the customers phone,enter it here",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              )
                            : Container(),
                        const SizedBox(
                          height: 20,
                        ),
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

                                    showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          SingleChildScrollView(
                                        controller:
                                            ModalScrollController.of(context),
                                        child: SizedBox(
                                          height: 300,
                                          child: Card(
                                              elevation: 12,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.network(
                                                  customerPic,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 300,
                                                ),
                                              )),
                                        ),
                                      ),
                                    );
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
                          height: 20,
                        ),
                        sentOTP && !hasOTP
                            ? Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Didn't receive code?"),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    isCompleted
                                        ? TextButton(
                                            onPressed: () {
                                              String num =
                                                  _customerPhoneController.text
                                                      .replaceFirst(
                                                          "0", '+233');
                                              sendSms.sendMySms(
                                                  num,
                                                  "EasyAgent",
                                                  "Your code $oTP");
                                              Get.snackbar("Check Phone",
                                                  "code was sent again",
                                                  backgroundColor:
                                                      snackBackground,
                                                  colorText: defaultWhite,
                                                  duration: const Duration(
                                                      seconds: 5));
                                              startTimer();
                                              resetTimer();
                                              setState(() {
                                                isResent = true;
                                                isCompleted = false;
                                              });
                                            },
                                            child: const Text("Resend Code",
                                                style: TextStyle(
                                                    color: secondaryColor)),
                                          )
                                        : Text("00:${seconds.toString()}"),
                                  ],
                                ),
                              )
                            : Container(),
                        hasOTP
                            ? Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: TextFormField(
                                      controller: _amountReceivedController,
                                      focusNode: amountReceivedFocusNode,
                                      cursorRadius:
                                          const Radius.elliptical(10, 10),
                                      cursorWidth: 10,
                                      cursorColor: secondaryColor,
                                      decoration: buildInputDecoration(
                                          "Cash Out GHC"),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please enter amount received";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
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
                                      controller: _cashPaidController,
                                      focusNode: cashPaidFocusNode,
                                      cursorRadius:
                                          const Radius.elliptical(10, 10),
                                      cursorWidth: 10,
                                      cursorColor: secondaryColor,
                                      decoration: buildInputDecoration(
                                          "Cash Paid GHC "),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please enter amount";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  _amountReceivedController.text != "" &&
                                          _cashPaidController.text != "" &&
                                          double.parse(_amountReceivedController
                                                  .text) >
                                              double.parse(
                                                  _cashPaidController.text)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            children: [
                                              const Text("Commission is : "),
                                              Text(
                                                  "${double.parse(_amountReceivedController.text) - double.parse(_cashPaidController.text)}"),
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              )
                            : Container(),
                        hasOTP
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // amountIsNotEmpty
                                  //     ? Column(
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d200 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 200;
                                  //                         d200 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d200FocusNode,
                                  //                   controller: _d200Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "200 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d200.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 100;
                                  //                     // setState(() {
                                  //                     //   d100 = dt;
                                  //                     // });
                                  //
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d100 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 100;
                                  //                         d100 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   controller: _d100Controller,
                                  //                   focusNode: d100FocusNode,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "100 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d100.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     Row(
                                  //       children: [
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 50;
                                  //                     // setState(() {
                                  //                     //   d50 = dt;
                                  //                     // });
                                  //
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d50 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 50;
                                  //                         d50 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d50FocusNode,
                                  //                   controller: _d50Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "50 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d50.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 20;
                                  //                     // setState(() {
                                  //                     //   d20 = dt;
                                  //                     // });
                                  //                     //
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d20 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 20;
                                  //                         d20 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d20FocusNode,
                                  //                   controller: _d20Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "20 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d20.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     Row(
                                  //       children: [
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 10;
                                  //                     // setState(() {
                                  //                     //   d10 = dt;
                                  //                     // });
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d10 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 10;
                                  //                         d10 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d10FocusNode,
                                  //                   controller: _d10Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "10 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d10.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 5;
                                  //                     // setState(() {
                                  //                     //   d5 = dt;
                                  //                     // });
                                  //
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d5 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 5;
                                  //                         d5 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d5FocusNode,
                                  //                   controller: _d5Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "5 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d5.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     Row(
                                  //       children: [
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 2;
                                  //                     // setState(() {
                                  //                     //   d2 = dt;
                                  //                     // });
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d2 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 2;
                                  //                         d2 = dt;
                                  //                       });
                                  //                     }
                                  //
                                  //                   },
                                  //                   focusNode: d2FocusNode,
                                  //                   controller: _d2Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "2GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d2.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         Expanded(
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 bottom: 10.0),
                                  //             child: Column(
                                  //               children: [
                                  //                 TextFormField(
                                  //                   onChanged: (value) {
                                  //                     // var dt =
                                  //                     //     int.parse(value) * 1;
                                  //                     // setState(() {
                                  //                     //   d1 = dt;
                                  //                     // });
                                  //                     var dt = 0;
                                  //                     if(value.isEmpty){
                                  //                       setState(() {
                                  //                         dt = 0;
                                  //                         d1 = 0;
                                  //                       });
                                  //                     }
                                  //                     else{
                                  //                       setState(() {
                                  //                         dt = int.parse(value) * 1;
                                  //                         d1 = dt;
                                  //                       });
                                  //                     }
                                  //                   },
                                  //                   focusNode: d1FocusNode,
                                  //                   controller: _d1Controller,
                                  //                   cursorColor: secondaryColor,
                                  //                   cursorRadius:
                                  //                   const Radius.elliptical(
                                  //                       10, 10),
                                  //                   cursorWidth: 10,
                                  //                   decoration:
                                  //                   buildInputDecoration(
                                  //                       "1 GHC Notes"),
                                  //                   keyboardType:
                                  //                   TextInputType.number,
                                  //                 ),
                                  //                 Padding(
                                  //                   padding:
                                  //                   const EdgeInsets.only(
                                  //                       top: 12.0,
                                  //                       bottom: 12),
                                  //                   child: Text(
                                  //                     d1.toString(),
                                  //                     style: const TextStyle(
                                  //                         fontWeight:
                                  //                         FontWeight.bold),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     Row(
                                  //       children: [
                                  //         Expanded(
                                  //             child: amountNotEqualTotal
                                  //                 ? Text(
                                  //               "TOTAL: $total",
                                  //               style: const TextStyle(
                                  //                   fontWeight:
                                  //                   FontWeight.bold,
                                  //                   color: Colors.red,
                                  //                   fontSize: 20),
                                  //             )
                                  //                 : const Text("")),
                                  //         const SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         const Expanded(child: Text(""))
                                  //       ],
                                  //     ),
                                  //   ],
                                  // )
                                  //     : Container(),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  isPosting
                                      ? const LoadingUi()
                                      : amountIsNotEmpty && !isFraudster
                                          ?Padding(
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

                                        if (!currentFocus
                                            .hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        } else {

                                           if (_currentSelectedNetwork ==
                                              "Select Network") {
                                            Get.snackbar(
                                                "Network or Type Error",
                                                "please select network and type",
                                                colorText: defaultWhite,
                                                backgroundColor:
                                                warning,
                                                snackPosition:
                                                SnackPosition
                                                    .BOTTOM,
                                                duration:
                                                const Duration(
                                                    seconds: 5));
                                            return;
                                          } else if (_currentSelectedNetwork ==
                                              "Mtn" &&
                                              int.parse(
                                                  _cashPaidController
                                                      .text) >
                                                  mtnNow) {
                                            Get.snackbar("Amount Error",
                                                "Amount is greater than your Mtn Ecash,please check",
                                                colorText: defaultWhite,
                                                backgroundColor:
                                                warning,
                                                snackPosition:
                                                SnackPosition
                                                    .BOTTOM,
                                                duration:
                                                const Duration(
                                                    seconds: 5));
                                            return;
                                          } else if (_currentSelectedNetwork ==
                                              "AirtelTigo" &&
                                              int.parse(
                                                  _cashPaidController
                                                      .text) >
                                                  airtelTigoNow) {
                                            Get.snackbar("Amount Error",
                                                "Amount is greater than your AirtelTigo Ecash,please check",
                                                colorText: defaultWhite,
                                                backgroundColor:
                                                warning,
                                                snackPosition:
                                                SnackPosition
                                                    .BOTTOM,
                                                duration:
                                                const Duration(
                                                    seconds: 5));
                                            return;
                                          } else if (_currentSelectedNetwork ==
                                              "Vodafone" &&
                                              int.parse(
                                                  _cashPaidController
                                                      .text) >
                                                  vodafoneNow) {
                                            Get.snackbar("Amount Error",
                                                "Amount is greater than your Vodafone Ecash,please check",
                                                colorText: defaultWhite,
                                                backgroundColor:
                                                warning,
                                                snackPosition:
                                                SnackPosition
                                                    .BOTTOM,
                                                duration:
                                                const Duration(
                                                    seconds: 5));
                                            return;
                                          }
                                           else if (double.parse(_cashPaidController.text) > double.parse(_amountReceivedController.text)) {
                                             Get.snackbar("Amount Error",
                                                 "Cash paid cannot be greater than amount received",
                                                 colorText: defaultWhite,
                                                 backgroundColor: warning,
                                                 snackPosition:
                                                 SnackPosition.BOTTOM,
                                                 duration:
                                                 const Duration(seconds: 5));
                                             return;
                                           }

                                           else {
                                            processMomoWithdrawal();
                                          }
                                        }
                                      },child: const Text("Save",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                                    ),
                                  )
                                          : Container(),
                                ],
                              )
                            : Container(),

                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  void _onDropDownItemSelectedNetwork(newValueSelected) {
    setState(() {
      _currentSelectedNetwork = newValueSelected;
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
