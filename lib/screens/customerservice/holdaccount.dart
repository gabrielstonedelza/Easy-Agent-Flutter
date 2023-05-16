import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
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
  late String uToken = "";
  final storage = GetStorage();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _customerPhoneNumberController;
  late final TextEditingController _reasonController;
  late final TextEditingController _merchantIdController;
  late final TextEditingController _transactionIdController;
  FocusNode amountFocusNode = FocusNode();
  FocusNode customerPhoneNumberFocusNode = FocusNode();
  FocusNode reasonFocusNode = FocusNode();

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
      "merchant_id": _merchantIdController.text.trim(),
      "transaction_id": _transactionIdController.text.trim()
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "Your request was sent",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      sendSms.sendMySms("+233550222888", "EasyAgent","Made a wrong transaction of amount GHC${_amountController.text} to this number ${_customerPhoneNumberController.text},my agent id is ${_merchantIdController.text.trim()} and the transaction id is ${_transactionIdController.text.trim()}can you please hold that account for me?Thank you.");
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
    _merchantIdController = TextEditingController();
    _transactionIdController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _customerPhoneNumberController.dispose();
    _reasonController.dispose();
    _merchantIdController.dispose();
    _transactionIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request to hold accounts"),
        backgroundColor: secondaryColor,
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
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      maxLines: 3,
                      controller: _merchantIdController,
                      focusNode: reasonFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Agent Id"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter agent id";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      maxLines: 3,
                      controller: _merchantIdController,
                      focusNode: reasonFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Transaction Id"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter transaction id";
                        }
                      },
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
                        requestToHoldAccount();
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

