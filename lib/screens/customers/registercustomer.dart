
import 'dart:math';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../sendsms.dart';

class CustomerRegistration extends StatefulWidget {
  const CustomerRegistration({Key? key}) : super(key: key);

  @override
  State<CustomerRegistration> createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  final _formKey = GlobalKey<FormState>();
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
  late List allCustomers = [];
  bool isLoading = true;
  bool isInSystem = false;


  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late DateTime _dateTime;


  late final TextEditingController name;
  late final TextEditingController phoneController;

  late TextEditingController dob = TextEditingController();
  final SendSmsController sendSms = SendSmsController();
  FocusNode nameFocusNode = FocusNode();

  FocusNode phoneControllerFocusNode = FocusNode();
  String getRandom(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  late String customerCode = "";

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    name = TextEditingController();

    phoneController = TextEditingController();
    controller.getAllCustomers(uToken);

    setState(() {
      customerCode = getRandom(15);
    });
  }

  @override
  void dispose(){
    super.dispose();
    name.dispose();
    phoneController.dispose();
  }


  registerCustomer()async{
    const registerUrl = "https://fnetagents.xyz/register_customer/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "name": name.text,
      "phone": phoneController.text,
      "unique_code": customerCode,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Customer was created successfully",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
      String telnum = phoneController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum,"Easy Agent",
          "Welcome ${name.text}, you are now registered on Easy Agent App.Your unique code for transactions is ($customerCode),please do not share this code with anyone,store it somewhere on your phone and delete this messages.For more information please kindly call 0244950505.");
      Get.offAll(()=>const Dashboard());
    }
    else{
      Get.snackbar("Error", "Something went wrong",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new customer"),
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
                          Get.snackbar("Sorry", "Customer is already in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackBackground);
                          setState(() {
                            isInSystem = true;
                          });
                        }
                        else if(value.length == 10 && !controller.customersNumbers.contains(value)){
                          Get.snackbar("New Customer", "Customer is not in the system",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: warning);
                          setState(() {
                            isInSystem = false;
                          });
                        }
                      },
                      controller: phoneController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Phone"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer phone number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: name,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Name"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer's name";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  !isInSystem ? isPosting  ? const LoadingUi() :NeoPopTiltedButton(
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

                        registerCustomer();
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
                  ) :Container(),
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