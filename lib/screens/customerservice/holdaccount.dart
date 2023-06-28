import 'package:easy_agent/constants.dart';
import 'package:easy_agent/controllers/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class HoldAccount extends StatefulWidget {
  const HoldAccount({Key? key}) : super(key: key);

  @override
  State<HoldAccount> createState() => _HoldAccountState();
}

class _HoldAccountState extends State<HoldAccount> {
  final SendSmsController sendSms = SendSmsController();
  final ProfileController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneNumberController;
  late final TextEditingController _reasonController;
  late final TextEditingController _agentPhoneNumberController;
  late final TextEditingController _transactionIdController;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneNumberFocusNode = FocusNode();
  FocusNode reasonFocusNode = FocusNode();
  FocusNode agentPhoneNumberFocusNode = FocusNode();
  FocusNode transactionIdFocusNode = FocusNode();

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

  requestToHoldAccount() async {
    const accountUrl = "https://fnetagents.xyz/request_to_hold_account/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "amount": _amountController.text.trim(),
      "customer_number": _customerPhoneNumberController.text.trim(),
      "reason": _reasonController.text.trim(),
      "merchant_id": _agentPhoneNumberController.text.trim(),
      "transaction_id": _transactionIdController.text.trim()
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "Your request was sent",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      sendSms.sendMySms("+233550222888", "EasyAgent","Made a wrong transaction of amount GHC${_amountController.text} to this number ${_customerPhoneNumberController.text},my agent number is ${_agentPhoneNumberController.text.trim()} and the transaction id is ${_transactionIdController.text.trim()},can you please hold that account for me?Thank you.");
      Get.offAll(() => const Dashboard());
    } else {

      Get.snackbar("Error", "something happened",
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
    _customerPhoneNumberController = TextEditingController();
    _reasonController = TextEditingController();
    _agentPhoneNumberController = TextEditingController(text: controller.agentPhone);
    _transactionIdController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _customerPhoneNumberController.dispose();
    _reasonController.dispose();
    _agentPhoneNumberController.dispose();
    _transactionIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request to hold accounts"),
      ),
      body: ListView(
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
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(

                      controller: _customerPhoneNumberController,
                      focusNode: customerPhoneNumberFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Customer Phone number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter number";
                        }
                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      readOnly: true,
                      controller: _agentPhoneNumberController,
                      focusNode: agentPhoneNumberFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Your number"),
                      keyboardType: TextInputType.text,
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return "Please enter agent id";
                      //   }
                      // },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _transactionIdController,
                      focusNode: transactionIdFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Transaction Id"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter transaction id";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      maxLines: 3,
                      controller: _reasonController,
                      focusNode: reasonFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Reason"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter reason";
                        }
                        return null;
                      },
                    ),
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
                          requestToHoldAccount();
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

