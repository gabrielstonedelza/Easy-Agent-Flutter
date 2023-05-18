import 'dart:async';
import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../customers/registercustomer.dart';


class BankWithdrawal extends StatefulWidget {
  const BankWithdrawal({Key? key}) : super(key: key);

  @override
  State<BankWithdrawal> createState() => _BankWithdrawalState();
}

class _BankWithdrawalState extends State<BankWithdrawal> {
  final CustomersController controller = Get.find();
  final List bankType = [
    "Select bank type",
    "Interbank",
    "Easy Banking"
  ];
  var _currentSelectedBankType = "Select bank type";
  final List banks = [
    "Select bank",
    "Access Bank",
    "Cal Bank",
    "Fidelity Bank",
    "Ecobank",
    "Pan Africa",
    "First Bank of Nigeria",
    "SGSSB",
    "Adansi rural bank",
    "Kwumawuman Bank",
    "Omini bank",
  ];
  final List interBanks = [
    "Select bank",
    "Pan Africa",
    "SGSSB",
    "Atwima Rural Bank",
    "Omnibsic Bank",
    "Omini bank",
    "Stanbic Bank",
    "First Bank of Nigeria",
    "Adehyeman Savings and loans",
    "ARB Apex Bank Limited",
    "Absa Bank",
    "Agriculture Development bank",
    "Bank of Africa",
    "Bank of Ghana",
    "Consolidated Bank Ghana",
    "First Atlantic Bank",
    "First National Bank",
    "G-Money",
    "GCB BanK LTD",
    "Ghana Pay",
    "GHL Bank Ltd",
    "National Investment Bank",
    "Opportunity International Savings And Loans",
    "Prudential Bank",
    "Republic Bank Ltd",
    "Sahel Sahara Bank",
    "Sinapi Aba Savings and Loans",
    "Societe Generale Ghana Ltd",
    "Standard Chartered",
    "universal Merchant Bank",
    "Zenith Bank",
  ];
  final List otherBanks = [
    "Select bank",
    "GT Bank",
    "Access Bank",
    "Cal Bank",
    "Fidelity Bank",
    "Ecobank",
  ];
  var _currentSelectedBank = "Select bank";
  final List withDrawalTypes = [
    "Select Withdrawal Type",
    "POS",
    "Mobile App"
  ];

  var _currrentWithDrawalType = "Select Withdrawal Type";
  bool isInterBank = false;
  bool isOtherBank = false;

  bool amountIsNotEmpty = false;
  bool isPosting = false;
  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isPosting = false;
    });
  }

  bool userExists = false;
  late List allCustomers = [];
  bool isLoading = true;
  late List customersPhone = [];

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneController;
  bool hasAmount = false;
  late final TextEditingController _d200Controller;
  late final TextEditingController _d100Controller;
  late final TextEditingController _d50Controller;
  late final TextEditingController _d20Controller;
  late final TextEditingController _d10Controller;
  late final TextEditingController _d5Controller;
  late final TextEditingController _d2Controller;
  late final TextEditingController _d1Controller;

  FocusNode d200FocusNode = FocusNode();
  FocusNode d100FocusNode = FocusNode();
  FocusNode d50FocusNode = FocusNode();
  FocusNode d20FocusNode = FocusNode();
  FocusNode d10FocusNode = FocusNode();
  FocusNode d5FocusNode = FocusNode();
  FocusNode d2FocusNode = FocusNode();
  FocusNode d1FocusNode = FocusNode();
  bool amountNotEqualTotal = false;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneFocusNode = FocusNode();

  late int d200 = 0;
  late int d100 = 0;
  late int d50 = 0;
  late int d20 = 0;
  late int d10 = 0;
  late int d5 = 0;
  late int d2 = 0;
  late int d1 = 0;
  late int total = 0;

  late List allFraudsters = [];
  bool isFraudster = false;

  Future<void> getAllFraudsters() async {
    const url = "https://fnetagents.xyz/get_all_fraudsters/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allFraudsters.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }


  processWithdraw(context) async {
    const registerUrl = "https://fnetagents.xyz/post_bank_withdrawal/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer": _customerPhoneController.text.trim(),
      "bank": _currentSelectedBank,
      "withdrawal_type": _currrentWithDrawalType,
      "amount": _amountController.text,
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
      Get.snackbar("Success", "Withdrawal successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {
      print(res.body);
      Get.snackbar("Withdraw Error", "Something happened,try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
    getAllFraudsters();
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
        backgroundColor: secondaryColor,
        title: const Text("Bank Withdrawal"),
      ),
      body:isLoading ? const LoadingUi() : ListView(
        children: [
          const SizedBox(height: 30),
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
                        if(value.length == 10 && allFraudsters.contains(value)){
                          setState(() {
                            isFraudster = true;
                          });
                          Get.snackbar("Customer Error", "This customer is in the fraud lists.",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 10),
                              backgroundColor: warning);
                          return;
                        }
                        else{
                          setState(() {
                            isFraudster = false;
                          });
                        }
                        if (value.length == 10 &&
                            controller.customersNumbers.contains(value)) {
                          Get.snackbar("Success", "Customer is registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 5),
                              backgroundColor: snackBackground);

                        } else if (value.length == 10 &&
                            !controller.customersNumbers.contains(value)) {
                          Get.snackbar(
                              "Customer Error", "Customer is not registered",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: warning);

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
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: bankType.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedBankType(newValueSelected);
                            if(_currentSelectedBankType == "Interbank"){
                              setState(() {
                                isInterBank = true;
                                isOtherBank = false;
                              });
                            }
                            if(_currentSelectedBankType == "Easy Banking"){
                              setState(() {
                                isOtherBank = true;
                                isInterBank = false;
                              });
                            }
                          },
                          value: _currentSelectedBankType,
                        ),
                      ),
                    ),
                  ),
                  isInterBank ? Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: interBanks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
                        ),
                      ),
                    ),
                  ) : Container(),
                  isOtherBank ?  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: otherBanks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
                        ),
                      ),
                    ),
                  ) : Container(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select withdrawal type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: withDrawalTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedIdWithDrawalType(newValueSelected);
                          },
                          value: _currrentWithDrawalType,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length > 1 && value != ""){
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
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a amount";
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
                        else if(_currentSelectedBank == "Select Bank"){
                          Get.snackbar("Bank Error", "please select bank",
                              colorText: defaultWhite,
                              backgroundColor: warning,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 5));
                          return;
                        }
                        else{
                          processWithdraw(context);
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }


  void _onDropDownItemSelectedIdWithDrawalType(newValueSelected) {
    setState(() {
      _currrentWithDrawalType = newValueSelected;
    });
  }

  void _onDropDownItemSelectedBankType(newValueSelected) {
    setState(() {
      _currentSelectedBankType = newValueSelected;
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

