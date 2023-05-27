import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../widgets/loadingui.dart';

class CloseAccountBalance extends StatefulWidget {
  const CloseAccountBalance({Key? key}) : super(key: key);

  @override
  State<CloseAccountBalance> createState() => _CloseAccountBalanceState();
}

class _CloseAccountBalanceState extends State<CloseAccountBalance> {
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

  late String uToken = "";
  final storage = GetStorage();

  late List accountBalanceDetailsToday = [];
  late List lastItem = [];
  late List firstItem = [];
  late double physical = 0.0;
  late double mtn = 0.0;
  late double airteltigo = 0.0;
  late double vodafone = 0.0;
  late double mtnNow = 0.0;
  late double airtelTigoNow = 0.0;
  late double vodafoneNow = 0.0;
  late double physicalNow = 0.0;
  late double mtnStarted = 0.0;
  late double airtelTigoStarted = 0.0;
  late double vodafoneStarted = 0.0;
  late double physicalStarted = 0.0;
  bool isLoading = true;
  bool physicalSet = false;
  bool mtnSet = false;
  bool airtelTigoSet = false;
  bool vodafoneSet = false;
  late double total = 0.0;

  closeAccountsToday() async {
    const accountUrl = "https://fnetagents.xyz/close_balance/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physicalNow.toString(),
      "mtn_e_cash": mtnNow.toString(),
      "tigo_airtel_e_cash": airtelTigoNow.toString(),
      "vodafone_e_cash": vodafoneNow.toString(),
      "isClosed": "True",
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You have closed accounts for today",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {

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
        firstItem.assign(accountBalanceDetailsToday.first);
        physicalNow = double.parse(lastItem[0]['physical']);
        mtnNow = double.parse(lastItem[0]['mtn_e_cash']);
        airtelTigoNow = double.parse(lastItem[0]['tigo_airtel_e_cash']);
        vodafoneNow = double.parse(lastItem[0]['vodafone_e_cash']);

        physicalStarted = double.parse(firstItem[0]['physical']);
        mtnStarted = double.parse(firstItem[0]['mtn_e_cash']);
        airtelTigoStarted = double.parse(firstItem[0]['tigo_airtel_e_cash']);
        vodafoneStarted = double.parse(firstItem[0]['vodafone_e_cash']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Close accounts for today"),
      ),
      body:isLoading ? const LoadingUi() : ListView(
        children: [
          const SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.only(left:10.0,right: 10),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text("Started With"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 10),
                      child: Row(
                        children: [
                          const Text("Physical : "),
                          Text(physicalStarted.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 10),
                      child: Row(
                        children: [
                          const Text("MTN : "),
                          Text(mtnStarted.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("AirtelTigo : "),
                          Text(airtelTigoStarted.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("Vodafone : "),
                          Text(vodafoneStarted.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("Working Capital : "),
                          Text("${physicalNow + mtnNow + airtelTigoNow + vodafoneNow}",style:const TextStyle(fontWeight: FontWeight.bold,color: warning)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:10.0,right: 10),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text("Now"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 10),
                      child: Row(
                        children: [
                          const Text("Physical : "),
                          Text(physicalNow.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 10),
                      child: Row(
                        children: [
                          const Text("MTN : "),
                          Text(mtnNow.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("AirtelTigo : "),
                          Text(airtelTigoNow.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("Vodafone : "),
                          Text(vodafoneNow.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Text("Working Capital : "),
                          Text("${physicalNow + mtnNow + airtelTigoNow + vodafoneNow}",style:const TextStyle(fontWeight: FontWeight.bold,color: warning)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),
          isPosting  ? const LoadingUi() :
          NeoPopTiltedButton(
            isFloating: true,
            onTapUp: () {
              _startPosting();
              closeAccountsToday();
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
              child: Text('Close Account',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white)),
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Form(
          //     key: _formKey,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.only(bottom: 10.0,left: 10),
          //           child: TextFormField(
          //             onChanged: (value){
          //               if(value!.isNotEmpty){
          //                 setState(() {
          //                   physicalSet = true;
          //                   physical = physicalNow + double.parse(value);
          //                 });
          //
          //               }
          //               else{
          //                 setState(() {
          //                   physicalSet = false;
          //                 });
          //               }
          //             },
          //             controller: physicalController,
          //             cursorColor: secondaryColor,
          //             cursorRadius: const Radius.elliptical(10, 10),
          //             cursorWidth: 10,
          //             decoration: buildInputDecoration("Physical Cash = ${physicalNow.toString()}"),
          //             keyboardType: TextInputType.number,
          //             validator: (value) {
          //               if(value!.isEmpty){
          //                 return "Please enter your physical cash";
          //               }
          //             },
          //           ),
          //         ),
          //         physicalSet ? Padding(
          //           padding: const EdgeInsets.only(top:8.0,bottom: 8),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               const Text("Physical now is =>"),
          //               const SizedBox(width: 10,),
          //               Text(physical.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
          //             ],
          //           ),
          //         ): Container(),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 10.0),
          //           child: TextFormField(
          //             onChanged: (value){
          //               if(value!.isNotEmpty){
          //                 setState(() {
          //                   mtnSet = true;
          //                   mtn = mtnNow + double.parse(value);
          //                 });
          //
          //               }
          //               else{
          //                 setState(() {
          //                   mtnSet = false;
          //                 });
          //               }
          //             },
          //             controller: _mtnEcashController,
          //             cursorColor: secondaryColor,
          //             cursorRadius: const Radius.elliptical(10, 10),
          //             cursorWidth: 10,
          //             decoration: buildInputDecoration("Mtn Ecash = ${mtnNow.toString()}"),
          //             keyboardType: TextInputType.number,
          //             validator: (value) {
          //               if(value!.isEmpty){
          //                 return "Please enter your mtn ecash";
          //               }
          //             },
          //           ),
          //         ),
          //         mtnSet ? Padding(
          //           padding: const EdgeInsets.only(top:8.0,bottom: 8),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               const Text("Mtn now is =>"),
          //               const SizedBox(width: 10,),
          //               Text(mtn.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
          //             ],
          //           ),
          //         ): Container(),
          //         const SizedBox(height: 10,),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 10.0),
          //           child: TextFormField(
          //             onChanged: (value){
          //               if(value!.isNotEmpty){
          //                 setState(() {
          //                   airtelTigoSet = true;
          //                   airteltigo = airtelTigoNow + double.parse(value);
          //                 });
          //
          //               }
          //               else{
          //                 setState(() {
          //                   airtelTigoSet = false;
          //                 });
          //               }
          //             },
          //             controller: _tigoAirtelEcashController,
          //             cursorColor: secondaryColor,
          //             cursorRadius: const Radius.elliptical(10, 10),
          //             cursorWidth: 10,
          //             decoration: buildInputDecoration("Tigo Airtel Ecash = ${airtelTigoNow.toString()}"),
          //             keyboardType: TextInputType.number,
          //             validator: (value) {
          //               if(value!.isEmpty){
          //                 return "Please enter your tigoairtel ecash";
          //               }
          //             },
          //           ),
          //         ),
          //         airtelTigoSet ? Padding(
          //           padding: const EdgeInsets.only(top:8.0,bottom: 8),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               const Text("AirtelTigo now is =>"),
          //               const SizedBox(width: 10,),
          //               Text(airteltigo.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
          //             ],
          //           ),
          //         ): Container(),
          //         const SizedBox(height: 10,),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 10.0),
          //           child: TextFormField(
          //             onChanged: (value){
          //               if(value!.isNotEmpty){
          //                 setState(() {
          //                   vodafoneSet = true;
          //                   vodafone = vodafoneNow + double.parse(value);
          //                 });
          //
          //               }
          //               else{
          //                 setState(() {
          //                   vodafoneSet = false;
          //                 });
          //               }
          //             },
          //             controller: _vodafoneEcashController,
          //             cursorColor: secondaryColor,
          //             cursorRadius: const Radius.elliptical(10, 10),
          //             cursorWidth: 10,
          //             decoration: buildInputDecoration("Voda Ecash  = ${vodafoneNow.toString()}"),
          //             keyboardType: TextInputType.number,
          //             validator: (value) {
          //               if(value!.isEmpty){
          //                 return "Please enter your voda ecash";
          //               }
          //             },
          //           ),
          //         ),
          //         vodafoneSet ? Padding(
          //           padding: const EdgeInsets.only(top:8.0,bottom: 8),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               const Text("Vodafone now is =>"),
          //               const SizedBox(width: 10,),
          //               Text(vodafone.toString(),style: const TextStyle(color: warning,fontWeight: FontWeight.bold),),
          //             ],
          //           ),
          //         ): Container(),
          //
          //         const SizedBox(height: 30,),
          //         isPosting  ? const LoadingUi() :
          //         NeoPopTiltedButton(
          //           isFloating: true,
          //           onTapUp: () {
          //             _startPosting();
          //             FocusScopeNode currentFocus = FocusScope.of(context);
          //
          //             if (!currentFocus.hasPrimaryFocus) {
          //               currentFocus.unfocus();
          //             }
          //             if (!_formKey.currentState!.validate()) {
          //               return;
          //             } else {
          //               closeAccountsToday();
          //             }
          //           },
          //           decoration: const NeoPopTiltedButtonDecoration(
          //             color: secondaryColor,
          //             plunkColor: Color.fromRGBO(255, 235, 52, 1),
          //             shadowColor: Color.fromRGBO(36, 36, 36, 1),
          //             showShimmer: true,
          //           ),
          //           child: const Padding(
          //             padding: EdgeInsets.symmetric(
          //               horizontal: 70.0,
          //               vertical: 15,
          //             ),
          //             child: Text('Close Account',style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 20,
          //                 color: Colors.white)),
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
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
