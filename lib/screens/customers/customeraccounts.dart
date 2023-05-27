import 'dart:async';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/customers/registercustomer.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../sendsms.dart';


class CustomerAccountRegistration extends StatefulWidget {
  const CustomerAccountRegistration({Key? key}) : super(key: key);

  @override
  State<CustomerAccountRegistration> createState() => _UserRegistration();
}

class _UserRegistration extends State<CustomerAccountRegistration> {
  final CustomersController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  bool isPosting = false;
  late List allCustomers = [];
  bool isLoading = true;
  late List customersPhones = [];
  late List customersNames = [];
  late List customersAccountNumbers = [];
  bool isInSystem = false;

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final SendSmsController sendSms = SendSmsController();
  bool isInterBank = false;
  bool isOtherBank = false;

  final List bankType = [
    "Select bank type",
    "Interbank",
    "Easy Banking"
  ];
  var _currentSelectedBankType = "Select bank type";

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

  late final TextEditingController phone;
  late final TextEditingController accountName;
  late final TextEditingController accountNumber;

  FocusNode customerPhoneFocusNode = FocusNode();
  FocusNode branchFocusNode = FocusNode();
  FocusNode accountNumberFocusNode = FocusNode();
  FocusNode accountNameFocusNode = FocusNode();


  registerCustomerAccount()async{
    const registerUrl = "https://fnetagents.xyz/register_customer_accounts/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "account_number": accountNumber.text.trim(),
      "bank": _currentSelectedBank,
      "customer": phone.text.trim(),
      "account_name": accountName.text.trim(),

    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Accounts added successfully",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground);
      Get.offAll(()=>const Dashboard());
    }
    else{

      Get.snackbar("Error", "Sorry,something happened,please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }

    phone = TextEditingController();
    accountName = TextEditingController();
    accountNumber = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();

    phone.dispose();
    accountName.dispose();
    accountNumber.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Add customer accounts"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 10 && controller.customersNumbers.contains(value)){
                          Get.snackbar("Success", "Customer is in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackBackground);
                          setState(() {
                            isInSystem = true;
                          });
                        }
                        else if(value.length == 10 && !controller.customersNumbers.contains(value)){
                          Get.snackbar("Customer Error", "Customer is not in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red);
                          setState(() {
                            isInSystem = false;
                          });
                          Timer(const Duration(seconds: 3),()=> Get.to(()=> const CustomerRegistration()));
                        }
                      },
                      controller: phone,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Customer's Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      focusNode: accountNumberFocusNode,
                      controller: accountNumber,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Account Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter account number";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      focusNode: accountNameFocusNode,
                      controller: accountName,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Account Name"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter account name";
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
                        registerCustomerAccount();
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
                      child: Text('Save',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
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
