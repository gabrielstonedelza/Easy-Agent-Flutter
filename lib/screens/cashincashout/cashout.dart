
import 'dart:async';

import 'package:easy_agent/controllers/customerscontroller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../widgets/loadingui.dart';
import '../customers/registercustomer.dart';
import '../dashboard.dart';

class CashOut extends StatefulWidget {
  const CashOut({Key? key}) : super(key: key);

  @override
  State<CashOut> createState() => _CashOutState();
}

class _CashOutState extends State<CashOut> {
  final CustomersController controller = Get.find();
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
  final List networks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone",
  ];

  var _currentSelectedNetwork = "Select Network";

  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _d200Controller;
  late final TextEditingController _d100Controller;
  late final TextEditingController _d50Controller;
  late final TextEditingController _d20Controller;
  late final TextEditingController _d10Controller;
  late final TextEditingController _d5Controller;
  late final TextEditingController _d2Controller;
  late final TextEditingController _d1Controller;

  late int d200 = 0;
  late int d100 = 0;
  late int d50 = 0;
  late int d20 = 0;
  late int d10 = 0;
  late int d5 = 0;
  late int d2 = 0;
  late int d1 = 0;
  late int total = 0;
  bool amountNotEqualTotal = false;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();
  FocusNode d200FocusNode = FocusNode();
  FocusNode d100FocusNode = FocusNode();
  FocusNode d50FocusNode = FocusNode();
  FocusNode d20FocusNode = FocusNode();
  FocusNode d10FocusNode = FocusNode();
  FocusNode d5FocusNode = FocusNode();
  FocusNode d2FocusNode = FocusNode();
  FocusNode d1FocusNode = FocusNode();
  bool isCustomer = false;
  bool isDirect = false;
  double totalNow = 0.0;
  bool amountIsNotEmpty = false;

  Future<void> dialCashOutMtn(String customerNumber,String amount) async {
    UssdAdvanced.multisessionUssd(code: "*171*2*1*$customerNumber*$customerNumber*$amount#",subscriptionId: 1);
  }

  late String uToken = "";
  final storage = GetStorage();

  processMomoWithdrawal() async {
    const registerUrl = "https://fnetagents.xyz/post_momo_withdrawal/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "network": _currentSelectedNetwork,
      "amount": _amountController.text.trim(),
      "customer": _customerPhoneController.text.trim(),
      "d_200": _d200Controller.text.trim(),
      "d_100": _d100Controller.text.trim(),
      "d_50": _d50Controller.text.trim(),
      "d_20": _d20Controller.text.trim(),
      "d_10": _d10Controller.text.trim(),
      "d_5": _d5Controller.text.trim(),
      "d_2": _d2Controller.text.trim(),
      "d_1": _d1Controller.text.trim(),
    });

    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      dialCashOutMtn(_customerPhoneController.text.trim(),_amountController.text.trim());

      Get.offAll(()=> const Dashboard());
    } else {
      Get.snackbar("Withdrawal Error", "something went wrong please try again",
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
    _customerPhoneController = TextEditingController();
    _d200Controller = TextEditingController();
    _d100Controller = TextEditingController();
    _d50Controller = TextEditingController();
    _d20Controller = TextEditingController();
    _d10Controller = TextEditingController();
    _d5Controller = TextEditingController();
    _d2Controller = TextEditingController();
    _d1Controller = TextEditingController();
    controller.getAllCustomers(uToken);
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _customerPhoneController.dispose();
    _d200Controller.dispose();
    _d100Controller.dispose();
    _d50Controller.dispose();
    _d20Controller.dispose();
    _d10Controller.dispose();
    _d5Controller.dispose();
    _d2Controller.dispose();
    _d1Controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Out",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: secondaryColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
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
                            _onDropDownItemSelectedNetwork(newValueSelected);
                            if(newValueSelected == "Customer") {
                              setState(() {

                              });
                            }
                          },
                          value: _currentSelectedNetwork,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        if (value.length == 10 &&
                            controller.customersNumbers.contains(value)) {
                          Get.snackbar("Success", "Customer is registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 5),
                              backgroundColor: snackBackground);

                          setState(() {
                            isCustomer = true;
                          });
                        } else if (value.length == 10 &&
                            !controller.customersNumbers.contains(value)) {
                          Get.snackbar(
                              "Customer Error", "Customer is not registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: warning);
                          setState(() {
                            isCustomer = false;
                          });
                          Timer(const Duration(seconds: 3),
                                  () => Get.to(() => const CustomerRegistration()));
                        }
                      },
                      controller: _customerPhoneController,
                      focusNode: customerPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Customer's Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer's number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length > 3 && value != ""){
                          setState(() {
                            amountIsNotEmpty = true;
                          });
                        }
                        if(value == ""){
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
                      decoration: buildInputDecoration("Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                      },
                    ),
                  ),
                  amountIsNotEmpty ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 200;
                                      setState(() {
                                        d200 = dt;
                                      });
                                    },
                                    focusNode: d200FocusNode,
                                    controller: _d200Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("200 GHC Notes"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d200.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 100;
                                      setState(() {
                                        d100 = dt;
                                      });
                                    },
                                    controller: _d100Controller,
                                    focusNode: d100FocusNode,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("100 GHC Notes"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d100.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 50;
                                      setState(() {
                                        d50 = dt;
                                      });
                                    },
                                    focusNode: d50FocusNode,
                                    controller: _d50Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("50 GHC Notes"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d50.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 20;
                                      setState(() {
                                        d20 = dt;
                                      });
                                    },
                                    focusNode: d20FocusNode,
                                    controller: _d20Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("20 GHC Notes"),
                                    keyboardType: TextInputType.number,

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d20.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 10;
                                      setState(() {
                                        d10 = dt;
                                      });
                                    },
                                    focusNode: d10FocusNode,
                                    controller: _d10Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("10 GHC Notes"),
                                    keyboardType: TextInputType.number,

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d10.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 5;
                                      setState(() {
                                        d5 = dt;
                                      });
                                    },
                                    focusNode: d5FocusNode,
                                    controller: _d5Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("5 GHC Notes"),
                                    keyboardType: TextInputType.number,

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d5.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 2;
                                      setState(() {
                                        d2 = dt;
                                      });
                                    },
                                    focusNode: d2FocusNode,
                                    controller: _d2Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("2GHC Notes"),
                                    keyboardType: TextInputType.number,

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d2.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    onChanged: (value) {
                                      var dt = int.parse(value) * 1;
                                      setState(() {
                                        d1 = dt;
                                      });
                                    },
                                    focusNode: d1FocusNode,
                                    controller: _d1Controller,
                                    cursorColor: secondaryColor,
                                    cursorRadius: const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: buildInputDecoration("1 GHC Notes"),
                                    keyboardType: TextInputType.number,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                    child: Text(d1.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: amountNotEqualTotal ? Text("TOTAL: $total",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),) : const Text("")
                          ),
                          const SizedBox(width: 10,),
                          const Expanded(
                              child:  Text("")
                          )
                        ],
                      ),
                    ],
                  ) : Container(),
                  const SizedBox(height: 30,),
                  isPosting  ? const LoadingUi() :
                  isCustomer ? NeoPopTiltedButton(
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
                        var mainTotal = d200 + d100 + d50 + d20 + d10 + d5 + d2 + d1;
                        if(int.parse(_amountController.text) != mainTotal){
                          Get.snackbar("Total Error", "Your total should be equal to the amount",
                              colorText: defaultWhite,
                              backgroundColor: warning,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 5)
                          );
                          setState(() {
                            total = mainTotal;
                            amountNotEqualTotal = true;
                          });
                          return;
                        }
                        else if(_currentSelectedNetwork == "Select Network"){
                          Get.snackbar("Network or Type Error", "please select network and type",
                              colorText: defaultWhite,
                              backgroundColor: warning,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 5));
                          return;
                        }
                        else{
                          processMomoWithdrawal();
                        }
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
                      child: Text('Send',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                    ),
                  ) : Container(),
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
}
