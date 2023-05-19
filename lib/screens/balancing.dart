
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../widgets/loadingui.dart';
import '../controllers/profilecontroller.dart';
import 'dashboard.dart';


class ReBalancing extends StatefulWidget {
  const ReBalancing({Key? key}) : super(key: key);

  @override
  State<ReBalancing> createState() => _ReBalancingState();
}

class _ReBalancingState extends State<ReBalancing> {
  bool isPosting = false;
  bool isLoading = true;
  late List allAccounts = [];
  late List allMyRegisteredBanks = [
    "Select bank",
  ];
  late List allMyRegisteredAccountNumbers = [
    "Select account number",
  ];
  late List allMyRegisteredAccountNames = [
    "Select account name"
  ];

  Future<void> getAllMyAccounts(String token) async {
    const completedRides = "https://fnetagents.xyz/get_my_accounts/";
    var link = Uri.parse(completedRides);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allAccounts.assignAll(jsonData);

      for(var i in allAccounts){
        if(!allMyRegisteredBanks.contains(i['bank'])){
          allMyRegisteredBanks.add(i['bank']);
        }
        if(!allMyRegisteredAccountNumbers.contains(i['account_number'])){
          allMyRegisteredAccountNumbers.add(i['account_number']);
        }
        if(!allMyRegisteredAccountNames.contains(i['account_name'])){
          allMyRegisteredAccountNames.add(i['account_name']);
        }
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

  var _currentSelectedBank = "Select bank";
  var _currentAccountNumberSelected = "Select account number";
  var _currentAccountNameSelected = "Select account name";

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

  FocusNode amountFocusNode = FocusNode();


  late String uToken = "";
  final storage = GetStorage();
  final List networks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone",
  ];
  final List exchangeTypes = [
    "Select exchange type",
    "Bank",
    "Mobile Network"
  ];
  bool isBank = false;
  bool isNetwork = false;

  var _currentSelectedNetwork = "Select Network";
  var _currentSelectedExchangeType = "Select exchange type";
  ProfileController profileController = Get.find();
  late List ownerDetails = [];
  late String ownerId = "";
  late String ownerUsername = "";

  Future<void> fetchOwnersDetails() async {
    final postUrl = "https://fnetagents.xyz/get_supervisor_with_code/${profileController.ownerCode}/";
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


  processBalancing() async {
    const registerUrl = "https://fnetagents.xyz/request_for_re_balancing/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "owner": ownerId,
      "agent": profileController.userId,
      "amount": _amountController.text.trim(),
      "bank": _currentSelectedBank,
      "network": _currentSelectedNetwork,
      "account_number": _currentAccountNumberSelected,
      "account_name": _currentAccountNameSelected,
    });

    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));

      Get.offAll(()=> const Dashboard());
    } else {
      Get.snackbar("Balancing Error", "something went wrong please try again",
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
    getAllMyAccounts(uToken);
    fetchOwnersDetails();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request ReBalancing",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            onPressed: (){
              Get.offAll(()=> const Dashboard());
            },
            icon: const Icon(Icons.home_filled,size: 30,),
          )
        ],
      ),
      body: isLoading ? const LoadingUi() : ListView(
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
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: exchangeTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedExchangeType(newValueSelected);
                            if(newValueSelected == "Bank") {
                              setState(() {
                                isBank = true;
                                isNetwork = false;
                              });
                            }
                            if(newValueSelected == "Mobile Network") {
                              setState(() {
                                isNetwork = true;
                                isBank = false;
                              });
                            }

                          },
                          value: _currentSelectedExchangeType,
                        ),
                      ),
                    ),
                  ),
                 isNetwork ? Padding(
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
                  ) : Container(),
                 isBank ? Padding(
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
                          items: allMyRegisteredBanks.map((dropDownStringItem) {
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
                    ),) : Container(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select account number"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: allMyRegisteredAccountNumbers.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedAccountNumber(newValueSelected);
                          },
                          value: _currentAccountNumberSelected,
                        ),
                      ),
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
                          isExpanded: true,
                          underline: const SizedBox(),
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: allMyRegisteredAccountNames.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedAccountName(newValueSelected);
                          },
                          value: _currentAccountNameSelected,
                        ),
                      ),
                    ),
                  ),
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
                        processBalancing();
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
                  ),
                  const SizedBox(height: 30,),
                  const Center(
                    child: Text("Click on the home button to go your dashboard if you decide not proceed."),
                  )
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

  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }
  void _onDropDownItemSelectedAccountNumber(newValueSelected) {
    setState(() {
      _currentAccountNumberSelected = newValueSelected;
    });
  }
  void _onDropDownItemSelectedAccountName(newValueSelected) {
    setState(() {
      _currentAccountNameSelected = newValueSelected;
    });
  }
  void _onDropDownItemSelectedExchangeType(newValueSelected) {
    setState(() {
      _currentSelectedExchangeType = newValueSelected;
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
