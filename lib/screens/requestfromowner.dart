import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../controllers/profilecontroller.dart';
import '../widgets/loadingui.dart';
import 'dashboard.dart';

class RequestFromOwner extends StatefulWidget {
  const RequestFromOwner({Key? key}) : super(key: key);

  @override
  State<RequestFromOwner> createState() => _RequestFromOwnerState();
}

class _RequestFromOwnerState extends State<RequestFromOwner> {
  bool isPosting = false;
  bool isLoading = true;
  final ProfileController controller = Get.find();

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  bool isInterBank = false;
  bool isOtherBank = false;
  bool isBank = false;
  bool isNetwork = false;

  final List networks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone",
  ];
  final List requestType = [
    "Select request type",
    "Network",
    "Bank",
    "Cash"
  ];

  var _currentSelectedRequestType = "Select request type";
  var _currentSelectedNetwork = "Select Network";
  late final TextEditingController _amountController;
  FocusNode amountFocusNode = FocusNode();

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
  late String uToken = "";
  final storage = GetStorage();
  late List supervisorDetails = [];
  late List requestLimitDetails = [];
  late String supervisorId = "";
  late int requestLimit = 0;
  final _formKey = GlobalKey<FormState>();
  late List allRequests = [];
  bool canRequestAgain = false;
  bool requestFinished = false;

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
      supervisorDetails.assignAll(allPosts);
      for(var i in supervisorDetails){
        supervisorId = i['id'].toString();
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }
  Future<void> fetchMyRequestsLimit() async {
    const postUrl = "https://fnetagents.xyz/get_all_my_request_limit/";
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
      requestLimitDetails.assignAll(allPosts);

      for(var i in requestLimitDetails){
        requestLimit = i['request_limit'];
      }
      setState(() {
        isLoading = false;
      });

    } else {
      // print(res.body);
    }
  }

  Future<void>fetchAllRequestsToday()async{
    const url = "https://fnetagents.xyz/get_all_my_requests_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allRequests = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
    });
  }

  processRequest() async {
    const registerUrl = "https://fnetagents.xyz/agent_request_from_owner/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },
        body: {
          "owner": supervisorId,
          "agent" : controller.userId,
          "network": _currentSelectedNetwork,
          "bank": _currentSelectedBank,
          "amount": _amountController.text.trim(),
          "cash": _currentSelectedRequestType == "Cash" ? _amountController.text.trim() : "0.0",
        });

    if (res.statusCode == 201) {

      Get.snackbar("Congratulations", "request sent for approval",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      Get.offAll(()=> const Dashboard());
    } else {

      Get.snackbar("Request Error", "something went wrong please try again",
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
    _amountController = TextEditingController();
    fetchOwnersDetails();
    fetchMyRequestsLimit();
    fetchAllRequestsToday();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request"),
      ),
      body:isLoading ? const LoadingUi() :  ListView(
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
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select request type"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: requestType.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedRequestType(newValueSelected);
                            if(newValueSelected == "Network"){
                              setState(() {
                                isNetwork = true;
                                isBank = false;
                              });
                            }
                            if(newValueSelected == "Bank"){
                              setState(() {
                                isNetwork = false;
                                isBank = true;
                              });
                            }
                          },
                          value: _currentSelectedRequestType,
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
                          hint: const Text("Select network"),
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
                  ) : Container(),

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
                          if(isBank && _currentSelectedBank == "Select bank"){
                            Get.snackbar("Bank Error", "please select bank",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                            return;
                          }
                          if(isNetwork && _currentSelectedNetwork == "Select Network"){
                            Get.snackbar("Network Error", "please select network",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                            return;
                          }
                          else{
                            processRequest();
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

  void _onDropDownItemSelectedNetwork(newValueSelected) {
    setState(() {
      _currentSelectedNetwork = newValueSelected;
    });
  }

  void _onDropDownItemSelectedRequestType(newValueSelected) {
    setState(() {
      _currentSelectedRequestType = newValueSelected;
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
