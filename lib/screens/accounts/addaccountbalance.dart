import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';

class AddAccountBalance extends StatefulWidget {
  const AddAccountBalance({Key? key}) : super(key: key);

  @override
  State<AddAccountBalance> createState() => _AddAccountBalanceState();
}

class _AddAccountBalanceState extends State<AddAccountBalance> {
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

  late String uToken = "";
  final storage = GetStorage();

  addAccountsToday() async {
    const accountUrl = "https://fnetagents.xyz/add_balance_to_start/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physicalController.text,
      "mtn_e_cash": _mtnEcashController.text,
      "tigo_airtel_e_cash": _tigoAirtelEcashController.text,
      "vodafone_e_cash": _vodafoneEcashController.text,
      "isStarted": "True",
      "agent" : controller.userId
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You have added accounts for today",
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
        title: const Text("Add accounts today"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0,left: 10),
                    child: TextFormField(
                      controller: physicalController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Physical Cash"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter your physical cash";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      controller: _mtnEcashController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Mtn Ecash"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter your mtn ecash";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            controller: _tigoAirtelEcashController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("Tigo Airtel Ecash"),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if(value!.isEmpty){
                                return "Please enter your tigoairtel ecash";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            controller: _vodafoneEcashController,
                            cursorColor: secondaryColor,
                            cursorRadius: const Radius.elliptical(10, 10),
                            cursorWidth: 10,
                            decoration: buildInputDecoration("Voda Ecash"),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if(value!.isEmpty){
                                return "Please enter your voda ecash";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

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
                        if (!_formKey.currentState!.validate()) {
                          return;
                        } else {
                          addAccountsToday();
                        }
                      },child: const Text("Save",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
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
