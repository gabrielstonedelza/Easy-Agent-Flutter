import 'dart:async';
import 'dart:convert';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../sendsms.dart';
import 'mybankaccounts.dart';



class AddToMyAccount extends StatefulWidget {
  const AddToMyAccount({Key? key}) : super(key: key);

  @override
  _AddToUserAccount createState() => _AddToUserAccount();
}

class _AddToUserAccount extends State<AddToMyAccount> {
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

  List newBanks = [
    "Select bank",
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
  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";

  Future<void> fetchOwnersDetails() async {
    final postUrl = "https://fnetagents.xyz/get_supervisor_with_code/${controller.ownerCode}/";
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
      for(var i in ownerDetails){
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

  late final TextEditingController _accountNumberController = TextEditingController();
  late final TextEditingController phone = TextEditingController();
  late final TextEditingController accountName = TextEditingController();
  late final TextEditingController mtnLinkedNum = TextEditingController();


  addToAccount()async{
    const registerUrl = "https://fnetagents.xyz/add_to_agent_accounts/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "account_number": _accountNumberController.text,
      "bank": _currentSelectedBank,
      "account_name": accountName.text,
      "phone": phone.text,
      "mtn_linked_number": mtnLinkedNum.text,
      "owner": ownerId,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Account was added successfully",
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 10),
          backgroundColor: snackBackground);
      Get.offAll(() => const Dashboard());
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

    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchOwnersDetails();
    fetchMyAccounts();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: secondaryColor,
        title: const Text("Add bank accounts"),
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
                      controller: accountName,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter account name",
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
                      controller: _accountNumberController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter account number",
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
                      controller: phone,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter phone number",
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
                          hint: const Text("Select bank"),
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
                          labelText: "Linked Num",
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
                        addToAccount();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: secondaryColor,
                    splashColor: defaultWhite,
                    child: const Text(
                      "Save",
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.to(() => const MyBankAccounts());
        },
        child: const Text("Accs",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                // fontSize: 20,
                color: Colors.white)),
      ),
    );
  }
  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }

}
