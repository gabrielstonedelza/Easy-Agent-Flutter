import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';

class UpdateAccountBalance extends StatefulWidget {
  const UpdateAccountBalance({Key? key}) : super(key: key);

  @override
  State<UpdateAccountBalance> createState() => _UpdateAccountBalanceState();
}

class _UpdateAccountBalanceState extends State<UpdateAccountBalance> {
  final ProfileController controller = Get.find();
  bool isPosting = false;
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  late final TextEditingController _amountController;
  late final TextEditingController physicalController;
  late final TextEditingController _mtnEcashController;
  late final TextEditingController _tigoAirtelEcashController;
  late final TextEditingController _vodafoneEcashController;

  final List mtnAction = [
    "Select Action",
    "Add",
    "Subtract",
  ];
  var _currentSelectedMtnAction = "Select Action";

  final List vodafoneAction = [
    "Select Action",
    "Add",
    "Subtract",
  ];
  var _currentSelectedVodafoneAction = "Select Action";

  final List airtelTigoAction = [
    "Select Action",
    "Add",
    "Subtract",
  ];
  var _currentSelectedTigoAirtelAction = "Select Action";

  final List physicalAction = [
    "Select Action",
    "Add",
    "Subtract",
  ];
  var _currentSelectedPhysicalAction = "Select Action";

  late String uToken = "";
  final storage = GetStorage();

  late List accountBalanceDetailsToday = [];
  late List lastItem = [];
  late double physical = 0.0;
  late double mtn = 0.0;
  late double airteltigo = 0.0;
  late double vodafone = 0.0;
  late double mtnNow = 0.0;
  late double airtelTigoNow = 0.0;
  late double vodafoneNow = 0.0;
  late double physicalNow = 0.0;
  bool isLoading = false;
  bool physicalSet = false;
  bool mtnSet = false;
  bool airtelTigoSet = false;
  bool vodafoneSet = false;
  late double total = 0.0;

  updateAccountsToday() async {
    const accountUrl = "https://fnetagents.xyz/add_balance_to_start/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physicalSet ? physical.toString() : physicalNow.toString(),
      "mtn_e_cash": mtnSet ? mtn.toString() : mtnNow.toString(),
      "tigo_airtel_e_cash": airtelTigoSet ? airteltigo.toString() : airtelTigoNow.toString(),
      "vodafone_e_cash": vodafoneSet ? vodafone.toString() : vodafoneNow.toString(),
      "isStarted": "True",
      "agent":controller.userId
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "Your accounts was updated",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {
      // print(response.body);
      Get.snackbar("Account", "something happened",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  Future<void> fetchAccountBalance() async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_started_today/";
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
      });
    } else {
      // print(res.body);
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
    physicalController = TextEditingController();
    _mtnEcashController = TextEditingController();
    _tigoAirtelEcashController = TextEditingController();
    _vodafoneEcashController = TextEditingController();
    fetchAccountBalance();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    physicalController.dispose();
    _mtnEcashController.dispose();
    _tigoAirtelEcashController.dispose();
    _vodafoneEcashController.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update accounts"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left:10.0),
                    child: Center(
                      child: Text("Please make sure to select action first so you enter amount",style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left:10),
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
                                items: physicalAction.map((dropDownStringItem) {
                                  return DropdownMenuItem(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  );
                                }).toList(),
                                onChanged: (newValueSelected) {
                                  _onDropDownItemSelectedPhysicalAction(
                                      newValueSelected);
                                },
                                value: _currentSelectedPhysicalAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0,left: 10),
                          child: TextFormField(
                            onChanged: (value){
                              if(_currentSelectedPhysicalAction == "Select Action"){
                                Get.snackbar("Action Error", "please select action.",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: warning);
                              }
                              else{
                                if(value.isNotEmpty && _currentSelectedPhysicalAction == "Add"){
                                  setState(() {
                                    physicalSet = true;
                                    physical = physicalNow + double.parse(value);
                                  });
                                }
                                else if(value.isNotEmpty && _currentSelectedPhysicalAction == "Subtract"){
                                  setState(() {
                                    physicalSet = true;
                                    physical = physicalNow - double.parse(value);
                                  });
                                }
                                else{
                                  setState(() {
                                    physicalSet = false;
                                  });
                                }
                              }
                            },
                            readOnly: _currentSelectedPhysicalAction == "Select Action" ? true : false,
                            controller: physicalController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("Cash = ${physicalNow.toString()}"),
                            keyboardType: TextInputType.number,
                            // validator: (value) {
                            //   if(value!.isEmpty){
                            //     return "Please enter your physical cash";
                            //   }
                            //   return null;
                            // },
                          ),
                        ),
                      ),
                    ],
                  ),
                  physicalSet ? Padding(
                    padding: const EdgeInsets.only(top:8.0,bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Physical now is =>"),
                        const SizedBox(width: 10,),
                        Text(physical.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ): Container(),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left:10),
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
                                items: mtnAction.map((dropDownStringItem) {
                                  return DropdownMenuItem(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  );
                                }).toList(),
                                onChanged: (newValueSelected) {
                                  _onDropDownItemSelectedMtnAction(
                                      newValueSelected);
                                },
                                value: _currentSelectedMtnAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            onChanged: (value){
                              if(_currentSelectedMtnAction == "Select Action"){
                                Get.snackbar("Action Error", "please select action.",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: warning);
                              }
                              else{
                                if(value.isNotEmpty && _currentSelectedMtnAction == "Add"){
                                  setState(() {
                                    mtnSet = true;
                                    mtn = mtnNow + double.parse(value);
                                  });
                                }
                                else if(value.isNotEmpty && _currentSelectedMtnAction == "Subtract"){
                                  setState(() {
                                    mtnSet = true;
                                    mtn = mtnNow - double.parse(value);
                                  });
                                }
                                else{
                                  setState(() {
                                    mtnSet = false;
                                  });
                                }
                              }

                            },
                            readOnly: _currentSelectedMtnAction == "Select Action" ? true : false,
                            controller: _mtnEcashController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("Mtn = ${mtnNow.toString()}"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  mtnSet ? Padding(
                    padding: const EdgeInsets.only(top:8.0,bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Mtn now is =>"),
                        const SizedBox(width: 10,),
                        Text(mtn.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ): Container(),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left:10),
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
                                items: airtelTigoAction.map((dropDownStringItem) {
                                  return DropdownMenuItem(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  );
                                }).toList(),
                                onChanged: (newValueSelected) {
                                  _onDropDownItemSelectedAirtelTigoAction(
                                      newValueSelected);
                                },
                                value: _currentSelectedTigoAirtelAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            onChanged: (value){
                              if(_currentSelectedTigoAirtelAction == "Select Action"){
                                Get.snackbar("Action Error", "please select action.",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: warning);
                              }
                              else{
                                if(value.isNotEmpty && _currentSelectedTigoAirtelAction == "Add"){
                                  setState(() {
                                    airtelTigoSet = true;
                                    airteltigo = airtelTigoNow + double.parse(value);
                                  });
                                }
                                else if(value.isNotEmpty && _currentSelectedTigoAirtelAction == "Subtract"){
                                  setState(() {
                                    airtelTigoSet = true;
                                    airteltigo = airtelTigoNow - double.parse(value);
                                  });
                                }
                                else{
                                  setState(() {
                                    airtelTigoSet = false;
                                  });
                                }
                              }

                            },
                            readOnly: _currentSelectedTigoAirtelAction == "Select Action" ? true : false,
                            controller: _tigoAirtelEcashController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("TigoAirtel = ${airtelTigoNow.toString()}"),
                            keyboardType: TextInputType.number,
                            // validator: (value) {
                            //   if(value!.isEmpty){
                            //     return "Please enter your tigoairtel ecash";
                            //   }
                            //   return null;
                            // },
                          ),
                        ),
                      ),
                    ],
                  ),
                  airtelTigoSet ? Padding(
                    padding: const EdgeInsets.only(top:8.0,bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("AirtelTigo now is =>"),
                        const SizedBox(width: 10,),
                        Text(airteltigo.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ): Container(),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left:10),
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
                                items: vodafoneAction.map((dropDownStringItem) {
                                  return DropdownMenuItem(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  );
                                }).toList(),
                                onChanged: (newValueSelected) {
                                  _onDropDownItemSelectedVodafoneAction(
                                      newValueSelected);
                                },
                                value: _currentSelectedVodafoneAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            onChanged: (value){

                              if(_currentSelectedVodafoneAction == "Select Action"){
                                Get.snackbar("Action Error", "please select action.",
                                    colorText: defaultWhite,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: warning);
                              }
                              else{
                                if(value.isNotEmpty && _currentSelectedVodafoneAction == "Add"){
                                  setState(() {
                                    vodafoneSet = true;
                                    vodafone = vodafoneNow + double.parse(value);
                                  });
                                }
                                else if(value.isNotEmpty && _currentSelectedVodafoneAction == "Subtract"){
                                  setState(() {
                                    vodafoneSet = true;
                                    vodafone = vodafoneNow - double.parse(value);
                                  });
                                }
                                else{
                                  setState(() {
                                    vodafoneSet = false;
                                  });
                                }
                              }
                            },
                            readOnly: _currentSelectedVodafoneAction == "Select Action" ? true : false,
                            controller: _vodafoneEcashController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("Vodafone  = ${vodafoneNow.toString()}"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  vodafoneSet ? Padding(
                    padding: const EdgeInsets.only(top:8.0,bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vodafone now is =>"),
                        const SizedBox(width: 10,),
                        Text(vodafone.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ): Container(),

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
                        updateAccountsToday();
                      },child: const Text("Update Account",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
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

  void _onDropDownItemSelectedPhysicalAction(newValueSelected) {
    setState(() {
      _currentSelectedPhysicalAction = newValueSelected;
    });
  }
  void _onDropDownItemSelectedMtnAction(newValueSelected) {
    setState(() {
      _currentSelectedMtnAction = newValueSelected;
    });
  }
  void _onDropDownItemSelectedAirtelTigoAction(newValueSelected) {
    setState(() {
      _currentSelectedTigoAirtelAction = newValueSelected;
    });
  }
  void _onDropDownItemSelectedVodafoneAction(newValueSelected) {
    setState(() {
      _currentSelectedVodafoneAction = newValueSelected;
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
