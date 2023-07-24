import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../sendsms.dart';


class UpdateMyAccount extends StatefulWidget {
  final id;
  final acc_num;
  final acc_name;
  final bank;
  final phone_num;
  final linkedNum;
  const UpdateMyAccount({Key? key,required this.id,required this.acc_num,required this.acc_name,required this.bank,required this.phone_num,required this.linkedNum}) : super(key: key);

  @override
  _AddToUserAccount createState() => _AddToUserAccount(id:this.id,acc_num: this.acc_num,acc_name: this.acc_name,bank:this.bank,phone_num: this.phone_num,linkedNum: this.linkedNum);
}

class _AddToUserAccount extends State<UpdateMyAccount> {
  final id;
  final acc_num;
  final acc_name;
  final bank;
  final phone_num;
  final linkedNum;
  _AddToUserAccount({required this.id,required this.acc_num,required this.acc_name,required this.bank,required this.phone_num,required this.linkedNum});
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
  late List allAccounts = [];
  bool isLoading = true;
  late List customersPhones = [];
  late List AccountNames = [];
  late List agentAccountNumbers = [];
  bool isInSystem = false;

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final SendSmsController sendSms = SendSmsController();
  bool isInterBank = false;
  bool isOtherBank = false;

  List newBanks = [
    "Zenith Bank",
    "ADB",
    "GN Bank",
    "GT Bank",
    "Fidelity Bank",
    "Access Bank",
    "Cal Bank",
    "Ecobank",
    "UBA",
    "Republic",
    "CBG",
    "First Atlantic",
    "Stanbic Bank",
    "GCB",
    "ABSA",
    "UMB",
    "FBN",
    "Bank Of Africa",
  ];

  var _currentSelectedBank = "Select bank";

  Future<void>fetchMyAccounts() async {
    const url = "https://fnetagents.xyz/get_agent_accounts/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allAccounts = json.decode(jsonData);
      for (var i in allAccounts) {
        AccountNames.add(i['account_name']);
        agentAccountNumbers.add(i['account_number']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  final ProfileController controller = Get.find();

  late final TextEditingController _accountNumberController;
  late final TextEditingController phone;
  late final TextEditingController accountName;
  late final TextEditingController mtnLinkedNum;


  updateAccount()async{
    final registerUrl = "https://fnetagents.xyz/update_agent_accounts_detail/$id/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "account_number": _accountNumberController.text,
      "bank": _currentSelectedBank,
      "account_name": accountName.text,
      "phone": phone.text,
      "mtn_linked_number": mtnLinkedNum.text,
    });
    if(res.statusCode == 200){
      Get.snackbar("Congratulations", "Your account was updated",
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 10),
          backgroundColor: snackBackground);
      // setState(() {
      //   _accountNumberController.text = "";
      //   accountName.text = "";
      //   mtnLinkedNum.text = "";
      //   _currentSelectedBank = "Select bank";
      // });
    }
    else{
      if (kDebugMode) {
        print(res.body);
      }
      Get.snackbar("Error", res.body.toString(),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMyAccounts();
    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }
    _accountNumberController = TextEditingController(text: acc_num);
    phone = TextEditingController(text: phone_num);
    accountName = TextEditingController(text: acc_name);
    mtnLinkedNum = TextEditingController(text: linkedNum);
    _currentSelectedBank = bank;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: secondaryColor,
        title: const Text("Update bank accounts"),
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
                      controller: _accountNumberController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Update account number",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter account number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: accountName,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Update account name",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter account name";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: phone,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Update phone number",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter phone number";
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

                          items: newBanks.map((dropDownStringItem) {
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: mtnLinkedNum,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Update Linked Num",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter mtn linked account number";
                        }
                      },
                    ),
                  ),

                  isPosting ? const LoadingUi() : RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        updateAccount();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: secondaryColor,
                    splashColor: defaultWhite,
                    child: const Text(
                      "Update",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
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

}
